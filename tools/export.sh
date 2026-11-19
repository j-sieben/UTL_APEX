#!/bin/bash
# Produce a distribution directory from one immutable commit, including metadata.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd -- "$ROOT"
source "$ROOT/tools/version.sh"
resolve_version
[ -e "$ROOT/.git" ] || { version_error 'Export requires a Git checkout.'; exit 1; }
[ "$#" = 1 ] || { version_error 'Usage: bash tools/export.sh /path/to/new-release-directory'; exit 1; }
parent=$(cd -- "$(dirname -- "$1")" && pwd -P)
destination="$parent/$(basename -- "$1")"
case "$destination/" in "$ROOT/"*) version_error 'Export destination must be outside the checkout.'; exit 1;; esac
[ ! -e "$destination" ] || { version_error 'Export destination already exists.'; exit 1; }
staging=$(mktemp -d "$parent/.utl-apex-release.XXXXXX")
trap 'rm -rf -- "$staging"' EXIT
version_git archive --format=tar "$UTL_APEX_GIT_COMMIT" > "$staging/source.tar"
mkdir "$staging/release"
tar -xf "$staging/source.tar" -C "$staging/release"
printf 'UTL_APEX_VERSION=%s\nUTL_APEX_GIT_COMMIT=%s\n' "$UTL_APEX_VERSION" "$UTL_APEX_GIT_COMMIT" > "$staging/release/install_scripts/version.properties"
mv -- "$staging/release" "$destination"
printf 'Exported UTL_APEX %s (Git %s) to %s\n' "$UTL_APEX_VERSION" "$UTL_APEX_GIT_COMMIT" "$destination"
