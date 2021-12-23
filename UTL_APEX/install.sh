#!/bin/bash
echo -n "Enter APEX workspace schema for UTL_APEX [ENTER] "
read OWNER
echo ${OWNER}

echo -n "Enter password for ${OWNER} [ENTER] "
read PWD

echo -n "Enter service name for the database or PDB [ENTER] "
read SERVICE
echo ${SERVICE}

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG

echo @install_scripts/install.sql | sqlplus ${OWNER}/${PWD}@${SERVICE}

pause
EOF

