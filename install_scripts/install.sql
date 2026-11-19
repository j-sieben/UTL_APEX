-- Parameters:
-- 1: validated UTL_APEX product version
-- 2: validated full Git commit hash
-- Install into the connected user, using the default language of PIT

set define &
set concat .
set verify off
@@version_args.sql "&1." "&2."

@@init.sql

@tools/set_compiler_flags.sql

prompt
prompt &section.
prompt &h1.UTL_APEX Installation

@core/install.sql

@tools/check_unit_test_exists.sql "unit_test/install.sql" "installation"

@tools/check_version.sql

prompt &h1.Finished UTL_APEX Installation

exit success
