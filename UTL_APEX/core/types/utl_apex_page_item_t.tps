create or replace type utl_apex_page_item_t
  authid definer
as object
(
  table_name &ORA_NAME_TYPE.,
  column_name &ORA_NAME_TYPE.,
  source_name &ORA_NAME_TYPE.,
  label &ORA_NAME_TYPE.,
  data_type &ORA_NAME_TYPE.,
  format_mask &ORA_NAME_TYPE.
);
/