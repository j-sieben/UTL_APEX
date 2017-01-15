
prompt &h3.Grant SYSTEM privileges
prompt &s1.create session, create procedure to &INSTALL_USER.
grant create session, create procedure to &INSTALL_USER.;

prompt &h3.Grant OBJECT privileges

begin
  $IF dbms_db_version.ver_le_11 $THEN
  null;
  $ELSE
  dbms_output.put_line('&s1.INHERIT PRIVILEGES from ' || user || ' to &INSTALL_USER. granted');
  execute immediate 'grant inherit privileges on user ' || user || ' to &INSTALL_USER.';
  $END
end;
/
