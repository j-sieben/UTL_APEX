#!/bin/bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd -- "$ROOT"
source "$ROOT/tools/version.sh"
resolve_version
printf 'UTL_APEX %s (Git %s)\n' "$UTL_APEX_VERSION" "$UTL_APEX_GIT_COMMIT"
read -r -p 'Enter APEX workspace schema for UTL_APEX: ' OWNER
read -r -s -p "Enter password for ${OWNER}: " INSTALL_PASSWORD
printf '\n'
read -r -p 'Enter service name for the database or PDB: ' SERVICE
export NLS_LANG=GERMAN_GERMANY.AL32UTF8
# Check once more after interactive input, before opening a database connection.
if [ -e "$ROOT/.git" ]; then version_clean; fi
sqlplus -L "${OWNER}/${INSTALL_PASSWORD}@${SERVICE}" "@install_scripts/$1.sql" "$UTL_APEX_VERSION" "$UTL_APEX_GIT_COMMIT"
