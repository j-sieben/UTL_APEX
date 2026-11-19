param(
    [ValidateSet('Install', 'DevTools', 'Export', 'Resolve')]
    [string]$Action = 'Install',
    [string]$Destination
)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location -LiteralPath $root
$env:GIT_NO_REPLACE_OBJECTS = '1'
$env:GIT_NO_LAZY_FETCH = '1'
function Invoke-VersionGit {
    param([string[]]$GitArgs)
    $result = & git -C $root @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($GitArgs -join ' ')" }
    return $result
}
function Assert-Clean {
    if ((Invoke-VersionGit @('diff', '--name-only', $script:commit, '--')) -or
        (Invoke-VersionGit @('diff', '--cached', '--name-only', $script:commit, '--')) -or
        (Invoke-VersionGit @('ls-files', '--others', '--exclude-standard'))) {
        throw 'Local/staged/untracked changes found. Commit or remove them before installation/export.'
    }
}
try {
    $top = $null
    $atRoot = $false
    if (Get-Command git -ErrorAction SilentlyContinue) {
        # An exported folder may live inside another repository; only its own
        # Git root counts. --show-prefix also handles symlinked parent paths.
        $ErrorActionPreference = 'Continue'
        $top = & git -C $root rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -ne 0) { $top = $null }
        $ErrorActionPreference = 'Stop'
        if ($top) {
            $prefix = Invoke-VersionGit @('rev-parse', '--show-prefix')
            $atRoot = -not $prefix
        }
    }
    $hasGit = (Test-Path -LiteralPath (Join-Path $root '.git')) -or $atRoot
    if ($hasGit) {
        if (-not $atRoot) { throw 'Invalid Git checkout.' }
        $script:commit = Invoke-VersionGit @('rev-parse', '--verify', 'HEAD^{commit}')
        if ((Invoke-VersionGit @('rev-parse', '--is-shallow-repository')) -ne 'false') {
            throw 'Incomplete Git history (shallow clone). Fetch the full history first.'
        }
        $partial = & git -C $root config --get-regexp '^(extensions\.partialclone|remote\..*\.promisor)$'
        if ($LASTEXITCODE -gt 1) { throw 'Cannot read Git configuration.' }
        if ($partial) { throw 'Partial clones are not supported. Use a complete clone.' }
        $grafts = Invoke-VersionGit @('rev-parse', '--git-path', 'info/grafts')
        if ((Test-Path -LiteralPath $grafts) -and (Get-Item -LiteralPath $grafts).Length -gt 0) { throw 'Git grafts are not supported.' }
        Assert-Clean
        $null = Invoke-VersionGit @('rev-list', '--objects', '--missing=error', $commit)
        $base = Invoke-VersionGit @('show', "${commit}:VERSION")
        $count = Invoke-VersionGit @('rev-list', '--count', $commit)
        if ($base -cnotmatch '\A(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\z') { throw 'VERSION must contain Major.Minor (for example 1.0).' }
        $version = "$base.$count"
        Assert-Clean
    } else {
        $metadata = Join-Path $root 'install_scripts/version.properties'
        if (-not (Test-Path -LiteralPath $metadata)) { throw 'No Git checkout or prepared release metadata. Use a complete clone or a prepared release.' }
        $lines = @(Get-Content -LiteralPath $metadata)
        if ($lines.Count -ne 2 -or -not $lines[0].StartsWith('UTL_APEX_VERSION=') -or -not $lines[1].StartsWith('UTL_APEX_GIT_COMMIT=')) {
            throw 'Malformed release metadata.'
        }
        $version = $lines[0].Substring('UTL_APEX_VERSION='.Length)
        $script:commit = $lines[1].Substring('UTL_APEX_GIT_COMMIT='.Length)
        $base = [IO.File]::ReadAllText((Join-Path $root 'VERSION')).TrimEnd("`r", "`n")
        if ($version.Substring(0, [Math]::Max(0, $version.LastIndexOf('.'))) -cne $base) { throw 'Release metadata does not match VERSION.' }
    }
    if ($version.Length -gt 100 -or $version -cnotmatch '\A(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\z' -or
        $commit -cnotmatch '\A([0-9a-f]{40}|[0-9a-f]{64})\z') { throw 'Invalid product version or full Git commit hash.' }
    Write-Host "UTL_APEX $version (Git $commit)"
    if ($Action -eq 'Resolve') { exit 0 }
    if ($Action -eq 'Export') {
        if (-not $hasGit) { throw 'Export requires a Git checkout.' }
        if (-not $Destination) { throw 'Export requires -Destination pointing to a new directory outside the checkout.' }
        if (-not [IO.Path]::IsPathRooted($Destination)) { $Destination = Join-Path $root $Destination }
        $target = [IO.Path]::GetFullPath($Destination)
        if (-not (Test-Path -LiteralPath ([IO.Path]::GetDirectoryName($target)) -PathType Container)) { throw 'Export destination parent must already exist.' }
        if ($target -eq $root -or $target.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Export destination must be outside the checkout.'
        }
        if (Test-Path -LiteralPath $target) { throw 'Export destination already exists.' }
        $stage = Join-Path ([IO.Path]::GetDirectoryName($target)) ('.utl-apex-release-' + [Guid]::NewGuid())
        $null = New-Item -ItemType Directory -Path $stage
        try {
            $zip = Join-Path $stage 'source.zip'
            $null = Invoke-VersionGit @('archive', '--format=zip', "--output=$zip", $commit)
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $release = Join-Path $stage 'release'
            [IO.Compression.ZipFile]::ExtractToDirectory($zip, $release)
            [IO.File]::WriteAllText((Join-Path $release 'install_scripts/version.properties'), "UTL_APEX_VERSION=$version`nUTL_APEX_GIT_COMMIT=$commit`n", [Text.Encoding]::ASCII)
            Move-Item -LiteralPath $release -Destination $target
            Write-Host "Exported to $target"
        } finally { Remove-Item -LiteralPath $stage -Recurse -Force }
        exit 0
    }
    $owner = Read-Host 'Enter APEX workspace schema for UTL_APEX'
    $secure = Read-Host "Enter password for $owner" -AsSecureString
    $service = Read-Host 'Enter service name for the database or PDB'
    if ($hasGit) { Assert-Clean }
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
        $env:NLS_LANG = 'GERMAN_GERMANY.AL32UTF8'
        $sql = if ($Action -eq 'DevTools') { '@install_scripts/install_devtools.sql' } else { '@install_scripts/install.sql' }
        & sqlplus -L "${owner}/${password}@${service}" $sql $version $commit
        $result = $LASTEXITCODE
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
        $password = $null
    }
    exit $result
} catch {
    [Console]::Error.WriteLine("UTL_APEX: $($_.Exception.Message)")
    exit 1
}
