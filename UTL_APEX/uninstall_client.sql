-- Parameters:
-- 1: Owner of UTL_APEX
-- 2: Remote user UTL_APEX is granted to

@init_client.sql &1. &2.

prompt &h1.Revoking access to UTL_APEX from &REMOTE_USER.

alter session set current_schema=&INSTALL_USER.;
prompt &h3.Revoke user rights
prompt &s1.Revoke execute on UTL_APEX
revoke execute on &INSTALL_USER..utl_apex from &REMOTE_USER.;
prompt &s1.Revoke execute on UTL_APEX_DDL
revoke execute on &INSTALL_USER..utl_apex_ddl from &REMOTE_USER.;


alter session set current_schema=&REMOTE_USER.;
prompt &h3.Drop synonyms
prompt &s1.Drop synonym for UTL_APEX
drop synonym utl_apex;
prompt &s1.Drop synonym for UTL_APEX_DDL
drop synonym utl_apex_ddl;

prompt &h1.UTL_APEX revoked from &REMOTE_USER.

exit
