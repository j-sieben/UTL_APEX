-- Parameters:
-- 1: Owner of UTL_APEX
-- 2: Remote user UTL_APEX is granted to

@init_client.sql &1. &2.

prompt &h1.Granting access to UTL_APEX to &REMOTE_USER.

alter session set current_schema=&INSTALL_USER.;
prompt &h3.Grant user rights
prompt &s1.Grant execute on UTL_APEX
grant execute on &INSTALL_USER..utl_apex to &REMOTE_USER.;
prompt &s1.Grant execute on UTL_APEX_DDL
grant execute on &INSTALL_USER..utl_apex_ddl to &REMOTE_USER.;


alter session set current_schema=&REMOTE_USER.;
prompt &h3.Create synonyms
prompt &s1.Create synonym for UTL_APEX
create or replace synonym utl_apex for &INSTALL_USER..utl_apex;
prompt &s1.Create synonym for UTL_APEX_DDL
create or replace synonym utl_apex_ddl for &INSTALL_USER..utl_apex_ddl;

prompt &h1.UTL_APEX granted to &REMOTE_USER.

exit
