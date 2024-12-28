column script new_value script
column msg new_value msg
set termout off

select case when count(*) = 0
         then '&table_dir.&1..tbl'
         else '&std_dir.null.sql'
       end script,
       case when count(*) = 0
         then '&s1.Create Table &1.'
         else '&s1.Table &1. already exists'
       end msg
  from user_objects
 where object_type = 'TABLE'
   and object_name = upper('&1.');
set termout on

prompt &MSG.
@&script.


