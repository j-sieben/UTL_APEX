#!/bin/bash
# Sourced by the launchers. ROOT must identify the distribution root.
version_error() { printf 'UTL_APEX: %s\n' "$*" >&2; return 1; }
version_git() { GIT_NO_REPLACE_OBJECTS=1 GIT_NO_LAZY_FETCH=1 git -C "$ROOT" "$@"; }
version_clean() {
  local changes
  changes=$(version_git diff --name-only "$UTL_APEX_GIT_COMMIT" --) || return 1
  [ -z "$changes" ] || { version_error 'Local changes found. Commit or remove them before installation/export.'; return 1; }
  changes=$(version_git diff --cached --name-only "$UTL_APEX_GIT_COMMIT" --) || return 1
  [ -z "$changes" ] || { version_error 'Staged changes found. Commit them before installation/export.'; return 1; }
  changes=$(version_git ls-files --others --exclude-standard) || return 1
  [ -z "$changes" ] || { version_error 'Untracked files found. Commit or remove them before installation/export.'; return 1; }
}
resolve_version() {
  ROOT=$(cd -- "$ROOT" && pwd -P) || return 1
  local top base count grafts partial status line
  top=$(version_git rev-parse --show-toplevel 2>/dev/null) || top=''
  if [ -e "$ROOT/.git" ] || [ "$top" = "$ROOT" ]; then
    [ "$top" = "$ROOT" ] || { version_error 'Invalid Git checkout.'; return 1; }
    UTL_APEX_GIT_COMMIT=$(version_git rev-parse --verify 'HEAD^{commit}') || return 1
    [ "$(version_git rev-parse --is-shallow-repository)" = false ] || { version_error 'Incomplete Git history (shallow clone). Fetch the full history first.'; return 1; }
    status=0
    partial=$(version_git config --get-regexp '^(extensions\.partialclone|remote\..*\.promisor)$') || status=$?
    [ "$status" -le 1 ] || { version_error 'Cannot read Git configuration.'; return 1; }
    [ -z "$partial" ] || { version_error 'Partial clones are not supported. Use a complete clone.'; return 1; }
    grafts=$(version_git rev-parse --git-path info/grafts) || return 1
    [ ! -s "$grafts" ] || { version_error 'Git grafts are not supported.'; return 1; }
    version_clean || return 1
    version_git rev-list --objects --missing=error "$UTL_APEX_GIT_COMMIT" >/dev/null || { version_error 'Incomplete Git objects/history.'; return 1; }
    base=$(version_git show "$UTL_APEX_GIT_COMMIT:VERSION") || return 1
    count=$(version_git rev-list --count "$UTL_APEX_GIT_COMMIT") || return 1
    [[ "$base" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || { version_error 'VERSION must contain Major.Minor (for example 1.0).'; return 1; }
    UTL_APEX_VERSION="$base.$count"
    version_clean || return 1
  else
    [ -f "$ROOT/install_scripts/version.properties" ] || { version_error 'No Git checkout or prepared release metadata. Use a complete clone or a prepared release.'; return 1; }
    # Parse data only; never source/execute distribution metadata.
    local lines=()
    while IFS= read -r line || [ -n "$line" ]; do lines+=("${line%$'\r'}"); done < "$ROOT/install_scripts/version.properties"
    [ "${#lines[@]}" = 2 ] && [[ "${lines[0]}" = UTL_APEX_VERSION=* ]] && [[ "${lines[1]}" = UTL_APEX_GIT_COMMIT=* ]] || { version_error 'Malformed release metadata.'; return 1; }
    UTL_APEX_VERSION=${lines[0]#*=}
    UTL_APEX_GIT_COMMIT=${lines[1]#*=}
    base=$(cat "$ROOT/VERSION") || return 1
    [ "${UTL_APEX_VERSION%.*}" = "$base" ] || { version_error 'Release metadata does not match VERSION.'; return 1; }
  fi
  [ "${#UTL_APEX_VERSION}" -le 100 ] && [[ "$UTL_APEX_VERSION" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] &&
    [[ "$UTL_APEX_GIT_COMMIT" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]] || { version_error 'Invalid version or full Git commit hash.'; return 1; }
}
