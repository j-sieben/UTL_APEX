set termout off

variable script_name varchar2(100);
variable comments varchar2(1000);

declare
  l_pkg_exists pls_integer;
  C_NULL_SCRIPT constant varchar2(10) := 'null.sql';
begin
  select case when ut.version >= '&MIN_UT_VERSION.' 
         then '&1.'
         else C_NULL_SCRIPT end
    into :script_name
    from dual;
  
  if :script_name = C_NULL_SCRIPT then
    :comments := '&s1.utPLSQL too old, skipping Unit Test &2.. Minim,um Version required is &MIN_UT_VERSION.';
  end if;
exception
  when others then
    dbms_output.put_line(sqlerrm);
    :comments := '&s1.utPLSQL not installed, skipping Unit Test &2..';
    :script_name := C_NULL_SCRIPT;
end;
/

column script new_value SCRIPT
select :script_name script
  from dual;

set termout on

begin
  if :comments is not null then
    dbms_output.put_line(:comments);
  end if;
end;
/
  
@&script.