set termout off

variable script_name varchar2(100);
variable comments varchar2(1000);

declare
  C_NULL_SCRIPT constant varchar2(10) := 'null.sql';
  l_ut_version varchar2(10);
  x_ut_does_not_exist exception;
  pragma exception_init(x_ut_does_not_exist, -6550);
begin
  execute immediate 'begin :x := ut.version; end;' using out l_ut_version;
  select case when l_ut_version >= '&MIN_UT_VERSION.' 
         then '&1.'
         else C_NULL_SCRIPT end
    into :script_name
    from dual;
  
  if :script_name = C_NULL_SCRIPT then
    :comments := '&s1.utPLSQL too old, skipping Unit Test &2.. Minim,um Version required is &MIN_UT_VERSION.';
  end if;
exception
  when x_ut_does_not_exist then
    dbms_output.put_line(sqlerrm);
    :comments := '&s1.utPLSQL not installed, skipping Unit Test &2..';
    :script_name := C_NULL_SCRIPT;
end;
/

column script new_value SCRIPT
select :script_name script
  from dual;

set termout on
set serveroutput on

begin
  if :comments is not null then
    dbms_output.put_line(:comments);
  end if;
end;
/

@&script.