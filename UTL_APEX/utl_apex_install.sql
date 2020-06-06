-- Parameters:
-- 1: Owner of UTL_APEX, into which UTL_APEX will be installed
-- 2: Default Language of PIT (if present), to decide which message language to install

@init.sql &1. &2.

alter session set current_schema=sys;
prompt
prompt &section.
prompt &h1.Checking whether required users exist
@check_users_exist.sql
prompt &h1.Checking whether required database objects exist
@check_prerequisites.sql

prompt &h2.grant user rights
@set_grants.sql

alter session set current_schema=&INSTALL_USER.;
@set_compiler_flags.sql

prompt
prompt &section.
prompt &h1.UTL_APEX Installation at user &INSTALL_USER.
prompt
prompt &section.
prompt &h1.Remove existing installation
@core/uninstall.sql

@check_unit_test_exists.sql "unit_test/uninstall.sql" "deinstallation"

prompt
prompt &section.
prompt &h1.Install UTL_APEX core functionality
@core/install.sql

@check_unit_test_exists.sql "unit_test/install.sql" "installation"

prompt
prompt &section.
prompt &h1.Finalize installation
prompt &h2.Revoke user rights
@revoke_grants.sql

prompt &h1.Finished UTL_APEX Installation

exit