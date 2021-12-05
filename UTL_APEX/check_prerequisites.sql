
declare
  l_is_installed pls_integer;
begin
  
  select count(*)
    into l_is_installed
    from all_users
   where username like 'APEX_______'
     and oracle_maintained = 'Y';
   
  if l_is_installed < 1 then
    raise_application_error(-20000, 'Installation of Oracle APEX is required to install UTL_APEX.');
  end if;
  
  select count(*)
    into l_is_installed
	  from user_tab_privs
   where user in (grantee, owner)
     and type = 'PACKAGE'
	   and table_name in ('PIT', 'UTL_TEXT');
     
  -- Check whether the pacakges are owned by USER
  if l_is_installed < 2 then
    select count(*)
      into l_is_installed
      from user_objects
     where object_type = 'PACKAGE'
       and object_name in ('PIT', 'UTL_TEXT');
  end if;
  
  if l_is_installed < 2 then
    raise_application_error(-20000, 'Installation of PIT and UTL_TEXT is required to install UTL_APEX. Please make sure that these packages are installed and accessible.');
  end if;
  
  -- Al tests passed.
  dbms_output.put_line('Installation prerequisites checked succesfully.');
  
end;
/
