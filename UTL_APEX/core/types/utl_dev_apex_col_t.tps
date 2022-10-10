create or replace type utl_dev_apex_col_t as object(
  column_name varchar2(128 byte),
  max_length number(3,0),
  is_pk &FLAG_TYPE.);
/
