create or replace view utl_apex_ui_home_main as
select rowid row_id, rpad('.', 100, '.') string_item, date '2019-01-01' date_item
  from dual;
