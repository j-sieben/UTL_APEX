-- Parameters:
-- None, UTL_APEX will be installed into the actually connected user, using the
-- default language of PIT

@install_scripts/init.sql
@tools/set_compiler_flags.sql

prompt
prompt &section.
prompt &h1.UTL_APEX Installation
prompt
prompt &section.
prompt &h1.Remove existing installation
@core/uninstall.sql

@tools/check_unit_test_exists.sql "unit_test/uninstall.sql" "deinstallation"

prompt
prompt &section.
prompt &h1.Install UTL_APEX core functionality
@core/install.sql

@tools/check_unit_test_exists.sql "unit_test/install.sql" "installation"

prompt &h1.Finished UTL_APEX Installation
