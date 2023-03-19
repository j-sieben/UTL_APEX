set termout on

column script new_value SCRIPT
select case when '&PIT_INSTALLED.' = 'true'
            then '&1.' 
            else 'tools/null.sql' end script
  from dual;

set termout on
@&script.