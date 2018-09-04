
declare
  l_is_installed pls_integer;
begin
  select count(*)
    into l_is_installed
	  from dba_objects
   where owner = '&INSTALL_USER.'
     and object_type = 'PACKAGE'
	   and object_name in ('PIT', 'UTL_TEXT');
  if l_is_installed < 2 then
    raise_application_error(-20000, 'Installation of PIT and UTL_TEXT is required to install UTL_APEX. Please make sure that these packages are installed.');
  else
    dbms_output.put_line('&s1.Installation prerequisites checked succesfully.');
  end if;
end;
/
