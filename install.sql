-- Parameters:
-- 1: Owner of UTL_APEX, into which UTL_APEX will be installed
-- 2: Default Language of PIT (if present), to decide which message language to install

@init.sql &1. &2.

alter session set current_schema=sys;
prompt
prompt &section.
prompt &h1.Checking whether required users exist
@check_users_exist.sql
prompt &h1.Checking whether required dtabase objects exist
@check_prerequisites.sql

prompt &h2.grant user rights
@set_grants.sql

alter session set current_schema=&INSTALL_USER.;
@set_compiler_flags.sql

prompt
prompt &section.
prompt &h1.State UTL_APEX Installation at user &INSTALL_USER.
prompt
prompt &section.
prompt &h1.Remove existing installation
@clean_up_install.sql

prompt
prompt &section.
prompt &h1.Messages
@utl_apex/messages/&DEFAULT_LANGUAGE./create_messages.sql

prompt
prompt &section.
prompt &h1.Templates
@utl_apex/sql/merge_templates.sql

prompt
prompt &section.
prompt &h1.Views
prompt &h2.View CODE_GEN_APEX_COLLECTION
@utl_apex/sql/views/code_gen_apex_collection.vw

prompt
prompt &section.
prompt &h1.Package UTL_APEX
@utl_apex/plsql/utl_apex.pks
prompt &h1.Package UTL_APEX_DDL
@utl_apex/plsql/utl_apex_ddl.pks

prompt &h1.Package Body UTL_APEX
@utl_apex/plsql/utl_apex.pkb
prompt &h1.Package Body UTL_APEX_DDL
@utl_apex/plsql/utl_apex_ddl.pkb

prompt
prompt &section.
prompt &h1.Finalize installation
prompt &h2.Revoke user rights
@revoke_grants.sql

prompt &h1.Finished UTL_APEX-Installation

exit
