
prompt &h3.Grant SYSTEM privileges
prompt &s1.create session, create procedure to &INSTALL_USER.
@check_has_system_privilege "create session"
@check_has_system_privilege "create procedure"

prompt &h3.Grant OBJECT privileges

declare
  l_apex_user varchar2(128 byte);
begin
  $IF dbms_db_version.ver_le_11 $THEN
  null;
  $ELSE
  dbms_output.put_line('&s1.INHERIT PRIVILEGES from &SYS_USER. to public granted');
  execute immediate 'grant inherit privileges on user &SYS_USER. to public';
  $END
  
  dbms_output.put_line('&s1.EXECUTE on &APEX_USER..wwv_flow_error granted as a workaround');
  execute immediate 'grant execute on &APEX_USER..wwv_flow_error to &INSTALL_USER.';
end;
/

alter session set current_schema
