set termout off

column script new_value SCRIPT
select case when '&PIT_INSTALLED.' = 'true'
            then '&1.' 
            else '&tool_dir.null.sql' end script
  from dual;

set termout on
@&script.