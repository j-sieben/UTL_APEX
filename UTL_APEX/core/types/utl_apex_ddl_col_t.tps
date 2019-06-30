create or replace type utl_apex_ddl_col_t as object(
  column_name varchar2(128 byte),
  max_length number(3,0),
  is_pk char(1 byte));
/
