-- Parameters:
-- 1: Owner of UTL_APEX, into which UTL_APEX will be installed
-- 2: Default Language of PIT (if present), to decide which message language to install


@init.sql

prompt &h2.grant user rights
@set_grants.sql

alter session set current_schema=&INSTALL_USER.;

prompt &h1.State UTL_APEX Deinstallation
@core/clean_up_install.sql

prompt
prompt &section.
prompt &h1.Finalize installation
prompt &h2.Revoke user rights
@revoke_grants.sql

prompt &h1.Finished UTL_APEX De-Installation

exit
