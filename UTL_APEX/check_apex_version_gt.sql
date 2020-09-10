define VERSION=&1.
define SCRIPT=&2.
var run_script varchar2(128 byte);
var msg varchar2(200 byte);

set termout off
declare
  l_version number;
  l_script varchar2(128 byte);
begin

    with params as(
         select '&SCRIPT.' script,
                coalesce(instr('&SCRIPT.', '/', -1) + 1, 1) idx_start,
                instr('&SCRIPT.', '.', -1) idx_end
           from dual),
         apex_users as (
         select to_number(substr(username, 6,2)) + to_number(substr(username, 8,2))/10 apex_version
           from all_users
          where username like 'APEX_______'
            and oracle_maintained = 'Y')
  select max(apex_version),
         upper(substr(script, idx_start, idx_end - idx_start))
    into l_version, l_script
    from apex_users
   cross join params
   group by upper(substr(script, idx_start, idx_end - idx_start));
     
  if l_version >= to_number('&VERSION.', '99.9') then
    :msg := '&s1.APEX version >= &VERSION., installing ' || l_script;
    :run_script := '&SCRIPT.';
  else
    :msg := '&s1.APEX version < &VERSION., skipping ' || l_script;
    :run_script := 'null.sql';
  end if;
end;
/

column script new_value script noprint
column message new_value message noprint
select :run_script script, :msg message from dual;
set termout on
prompt &MESSAGE.
@&script.