set define &
set concat .
set verify off
set serveroutput on
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
declare
  l_valid_objects pls_integer;
  l_version varchar2(100);
  l_commit varchar2(64);
begin
  select count(*)
    into l_valid_objects
    from user_objects
   where object_name = 'UTL_APEX'
     and object_type in ('PACKAGE', 'PACKAGE BODY')
     and status = 'VALID';
  if l_valid_objects != 2 then
    raise_application_error(-20000, 'UTL_APEX specification/body is missing or INVALID. Inspect USER_ERRORS.');
  end if;

  -- Dynamic SQL lets the validity check report a compilation failure first.
  execute immediate 'select utl_apex.get_version(), utl_apex.get_git_commit() from dual'
    into l_version, l_commit;
  if l_version is null or l_commit is null
     or l_version != '&UTL_APEX_VERSION.'
     or l_commit != '&UTL_APEX_GIT_COMMIT.' then
    raise_application_error(-20000, 'Installed UTL_APEX version/commit does not match installation metadata.');
  end if;
  dbms_output.put_line('Verified UTL_APEX ' || l_version || ' (Git ' || l_commit || ')');
end;
/
