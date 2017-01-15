begin
  $IF dbms_db_version.ver_le_11 $THEN
  null;
  $ELSE
  dbms_output.put_line('&s1.INHERIT PRIVILEGES from ' || user || ' to DOAG revoked');
  execute immediate 'revoke inherit privileges on user ' || user || ' from &INSTALL_USER.';
  $END
end;
/
