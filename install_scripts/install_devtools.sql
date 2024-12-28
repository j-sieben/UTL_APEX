-- Parameters:
-- None, UTL_APEX will be installed into the actually connected user, using the
-- default language of PIT

@install_scripts/init.sql

@tools/set_compiler_flags.sql

prompt
prompt &section.
prompt &h1.UTL_APEX Installation

@devtools/install.sql


prompt &h1.Finished UTL_APEX Installation
