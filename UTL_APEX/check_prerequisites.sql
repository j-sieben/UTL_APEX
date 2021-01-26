
declare
  l_is_installed pls_integer;
begin
  select count(*)
    into l_is_installed
	  from dba_tab_privs
   where '&INSTALL_USER.' in (grantee, owner)
     and type = 'PACKAGE'
	   and table_name in ('PIT', 'UTL_TEXT');
  if l_is_installed < 2 then
    -- Maybe INSTALL_USER is the owner of the pacakges
    select count(*)
      into l_is_installed
      from dba_objects
     where owner = '&INSTALL_USER.'
       and object_type = 'PACKAGE'
       and object_name in ('PIT', 'UTL_TEXT');
  end if;
  if l_is_installed < 2 then
    raise_application_error(-20000, 'Installation of PIT and UTL_TEXT is required to install UTL_APEX. Please make sure that these packages are installed and accessible by &INSTALL_USER..');
  else
    dbms_output.put_line('&s1.Installation prerequisites checked succesfully.');
  end if;
end;
/
