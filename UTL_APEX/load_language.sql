-- Parameters:
-- 1: Owner of UTL_APEX, into which the translated messages will be installed
-- 2: Default Language to install

@init.sql &1. &2.

prompt &h2.grant user rights
@set_grants.sql

alter session set current_schema=&INSTALL_USER.;
@set_compiler_flags.sql

prompt
prompt &section.
prompt &h1.Messages
@utl_apex/messages/&DEFAULT_LANGUAGE./create_messages.sql

prompt
prompt &section.
prompt &h1.Finalize installation
prompt &h2.Revoke user rights
@revoke_grants.sql

prompt &h1.Finished UTL_APEX-Installation

exit
