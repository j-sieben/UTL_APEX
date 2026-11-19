"""Offline installation/provenance tests. No database connection is made."""
import os
from pathlib import Path
import shutil
import shlex
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]
PWSH = shutil.which('pwsh')


class Versioning(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='utl apex tests ')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / 'checkout with spaces'
        self.root.mkdir()
        for folder in ('core', 'devtools', 'unit_test', 'tools', 'install_scripts'):
            shutil.copytree(SOURCE / folder, self.root / folder)
        for name in ('VERSION', 'install.sh', 'install.bat', 'install_devtools.sh', 'install_devtools.bat'):
            shutil.copy2(SOURCE / name, self.root / name)
        self.env = dict(os.environ, GIT_AUTHOR_NAME='Offline Test', GIT_AUTHOR_EMAIL='test@example.invalid',
                        GIT_COMMITTER_NAME='Offline Test', GIT_COMMITTER_EMAIL='test@example.invalid',
                        GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull)
        self.git('init', '-q')
        self.commit('initial')
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        stub = self.bin / 'sqlplus'
        stub.write_text('#!/bin/bash\nprintf "%s\\n" "$@" > "$TRACE_OUTPUT"\nexit "${SQLPLUS_EXIT:-0}"\n')
        stub.chmod(0o755)
        self.trace = self.base / 'sqlplus arguments'
        self.env.update(PATH=str(self.bin) + os.pathsep + self.env['PATH'], TRACE_OUTPUT=str(self.trace))

    def run_command(self, args, *, cwd=None, ok=True, input=None):
        result = subprocess.run(args, cwd=cwd or self.base, env=self.env, input=input,
                                text=True, capture_output=True)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def git(self, *args):
        return self.run_command(['git', '-C', str(self.root), *args]).stdout.strip()

    def commit(self, message):
        self.git('add', '.')
        self.git('commit', '-qm', message)

    def resolve(self, root=None, ok=True):
        return self.run_command(['bash', '-c',
            'ROOT="$1"; cd "$ROOT"; source tools/version.sh; resolve_version || exit; printf "%s %s\\n" "$UTL_APEX_VERSION" "$UTL_APEX_GIT_COMMIT"',
            'resolve', str(root or self.root)], ok=ok)

    def ps(self, root=None, action='Resolve', destination=None, ok=True):
        args = [PWSH, '-NoProfile', '-File', str((root or self.root) / 'tools/install.ps1'), '-Action', action]
        if destination:
            args += ['-Destination', str(destination)]
        return self.run_command(args, ok=ok)

    def install(self, root=None, dev=False, ok=True):
        return self.run_command(['bash', str((root or self.root) / ('install_devtools.sh' if dev else 'install.sh'))],
                                input='TEST\npassword\nSERVICE\n', ok=ok)

    def test_full_history_merge_and_major_minor(self):
        branch = self.git('branch', '--show-current')
        self.git('checkout', '-qb', 'side')
        (self.root / 'side.txt').write_text('side')
        self.commit('side')
        self.git('checkout', '-q', branch)
        (self.root / 'main.txt').write_text('main')
        self.commit('main')
        self.git('merge', '--no-ff', '-qm', 'merge', 'side')
        self.assertEqual(self.resolve().stdout.strip(), '1.0.4 ' + self.git('rev-parse', 'HEAD'))
        (self.root / 'VERSION').write_text('2.3\n')
        self.commit('new major minor')
        self.assertTrue(self.resolve().stdout.startswith('2.3.5 '))
        if PWSH:
            self.assertIn('UTL_APEX 2.3.5 (Git ' + self.git('rev-parse', 'HEAD') + ')', self.ps().stdout)

    def test_install_paths_and_error_propagation(self):
        for dev in (False, True):
            self.install(dev=dev)
            args = self.trace.read_text().splitlines()
            self.assertEqual(args[-2:], ['1.0.1', self.git('rev-parse', 'HEAD')])
            self.assertEqual(args[-3], '@install_scripts/install_devtools.sql' if dev else '@install_scripts/install.sql')
        self.env['SQLPLUS_EXIT'] = '9'
        self.assertEqual(self.install(ok=False).returncode, 9)

    def test_dirty_states_stop_before_database(self):
        source = self.root / 'VERSION'
        source.write_text('9.9\n')
        self.install(ok=False)
        self.assertFalse(self.trace.exists())
        if PWSH:
            self.ps(ok=False)
        self.git('add', 'VERSION')
        source.write_text('1.0\n')  # worktree equals commit, index differs
        self.resolve(ok=False)
        self.git('reset', '--hard', '-q')
        (self.root / 'untracked.sql').write_text('select 1 from dual;')
        self.install(ok=False)
        self.assertFalse(self.trace.exists())

    def test_shallow_and_partial_rejected(self):
        clone = self.base / 'shallow clone'
        self.run_command(['git', 'clone', '-q', '--depth=1', self.root.as_uri(), str(clone)])
        self.resolve(clone, ok=False)
        if PWSH:
            self.ps(clone, ok=False)
        self.git('config', 'remote.origin.promisor', 'true')
        self.resolve(ok=False)
        if PWSH:
            self.ps(ok=False)
        self.assertFalse(self.trace.exists())

    def test_export_and_archive_install(self):
        release = self.base / 'export with spaces'
        self.run_command(['bash', str(self.root / 'tools/export.sh'), str(release)])
        self.assertFalse((release / '.git').exists())
        expected = self.resolve().stdout
        self.assertEqual(self.resolve(release).stdout, expected)
        self.install(release)
        if PWSH:
            self.assertIn('1.0.1', self.ps(release).stdout)
        metadata = release / 'install_scripts/version.properties'
        original = metadata.read_text()
        metadata.write_text(original.replace('1.0.1', "1.0.1'; DROP TABLE X;--"))
        self.trace.unlink()
        self.install(release, ok=False)
        self.assertFalse(self.trace.exists())
        if PWSH:
            self.ps(release, ok=False)
        metadata.unlink()
        self.resolve(release, ok=False)
        if PWSH:
            self.ps(release, ok=False)

    def test_prepared_metadata_never_overrides_checkout(self):
        metadata = self.root / 'install_scripts/version.properties'
        metadata.write_text('UTL_APEX_VERSION=9.9.999\nUTL_APEX_GIT_COMMIT=' + 'a' * 40 + '\n')
        self.commit('stale metadata')
        self.assertTrue(self.resolve().stdout.startswith('1.0.2 '))
        if PWSH:
            self.assertIn('UTL_APEX 1.0.2 ', self.ps().stdout)

    def test_worktree_and_corrupt_git(self):
        worktree = self.base / 'linked worktree'
        self.git('worktree', 'add', '-q', '--detach', str(worktree))
        self.assertEqual(self.resolve(worktree).stdout, self.resolve().stdout)
        if PWSH:
            self.assertIn('1.0.1', self.ps(worktree).stdout)
        (worktree / '.git').write_text('gitdir: /does/not/exist\n')
        (worktree / 'install_scripts/version.properties').write_text(
            'UTL_APEX_VERSION=1.0.1\nUTL_APEX_GIT_COMMIT=' + 'a' * 40 + '\n')
        self.resolve(worktree, ok=False)
        if PWSH:
            self.ps(worktree, ok=False)

    def test_invalid_versions_and_missing_history_objects(self):
        (self.root / 'VERSION').write_text('1.0.123\n')
        self.commit('invalid version file')
        self.resolve(ok=False)
        if PWSH:
            self.ps(ok=False)
        (self.root / 'VERSION').write_text('1.0\n')
        self.commit('valid version')
        parent = self.git('rev-parse', 'HEAD^')
        (self.root / '.git/objects' / parent[:2] / parent[2:]).unlink()
        self.resolve(ok=False)
        if PWSH:
            self.ps(ok=False)
        self.assertFalse(self.trace.exists())

    def test_prepared_metadata_validation_and_parent_repository(self):
        release = self.base / 'release'
        self.run_command(['bash', str(self.root / 'tools/export.sh'), str(release)])
        self.run_command(['git', '-C', str(self.base), 'init', '-q'])
        self.assertTrue(self.resolve(release).stdout.startswith('1.0.1 '))
        if PWSH:
            self.assertIn('1.0.1', self.ps(release).stdout)
        metadata = release / 'install_scripts/version.properties'
        for text in (
            'UTL_APEX_VERSION=1.0.1\nUTL_APEX_GIT_COMMIT=abc\n',
            'UTL_APEX_VERSION=1.0.1\nUTL_APEX_GIT_COMMIT=' + 'z' * 40 + '\n',
            'UTL_APEX_VERSION=2.0.1\nUTL_APEX_GIT_COMMIT=' + 'a' * 40 + '\n',
            'UTL_APEX_VERSION=1.0.1\n',
        ):
            metadata.write_text(text)
            self.resolve(release, ok=False)
            if PWSH:
                self.ps(release, ok=False)
        metadata.unlink()
        self.resolve(release, ok=False)

    def test_one_pinned_commit_even_when_head_moves(self):
        first = self.git('rev-parse', 'HEAD')
        self.git('commit', '--allow-empty', '-qm', 'same tree later commit')
        later = self.git('rev-parse', 'HEAD')
        self.git('reset', '--hard', '-q', first)
        real_git = shutil.which('git')
        wrapper = self.bin / 'git'
        wrapper.write_text('#!/bin/bash\n' + shlex.quote(real_git) + ' "$@"\nresult=$?\n'
                           'case "$*" in *"rev-parse --verify HEAD^{commit}"*) '
                           + shlex.quote(real_git) + ' -C ' + shlex.quote(str(self.root))
                           + ' update-ref HEAD ' + later + ';; esac\nexit "$result"\n')
        wrapper.chmod(0o755)
        self.assertEqual(self.resolve().stdout.strip(), '1.0.1 ' + first)
        self.assertEqual(self.git('rev-parse', 'HEAD'), later)
        if PWSH:
            self.git('reset', '--hard', '-q', first)
            self.assertIn('UTL_APEX 1.0.1 (Git ' + first + ')', self.ps().stdout)

    @unittest.skipUnless(PWSH, 'PowerShell unavailable')
    def test_powershell_install_arguments_and_failure(self):
        command = """function Read-Host {
            param([string]$Prompt, [switch]$AsSecureString)
            if ($AsSecureString) { return (ConvertTo-SecureString 'password' -AsPlainText -Force) }
            if ($Prompt -like '*service*') { return 'SERVICE' }
            return 'TEST'
        }
        & $env:INSTALL_TEST_SCRIPT -Action $env:INSTALL_TEST_ACTION
        exit $LASTEXITCODE
        """
        self.env['INSTALL_TEST_SCRIPT'] = str(self.root / 'tools/install.ps1')
        for action in ('Install', 'DevTools'):
            self.env['INSTALL_TEST_ACTION'] = action
            self.run_command([PWSH, '-NoProfile', '-Command', command])
            args = self.trace.read_text().splitlines()
            self.assertEqual(args[-2:], ['1.0.1', self.git('rev-parse', 'HEAD')])
            self.assertEqual(args[1], 'TEST/password@SERVICE')
        self.env['SQLPLUS_EXIT'] = '9'
        self.assertEqual(self.run_command([PWSH, '-NoProfile', '-Command', command], ok=False).returncode, 9)

    @unittest.skipUnless(PWSH, 'PowerShell unavailable')
    def test_powershell_export(self):
        release = self.base / 'PS export with spaces'
        self.ps(action='Export', destination=release)
        self.assertEqual(self.resolve(release).stdout, self.resolve().stdout)
        self.assertIn('1.0.1', self.ps(release).stdout)


if __name__ == '__main__':
    unittest.main()
