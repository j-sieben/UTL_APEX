create or replace view utl_apex_fetch_row_columns as
select i.application_id,
       i.page_id,
       null static_id,
       utl_apex_page_item(lower(c.table_name), lower(i.item_source), i.item_name, c.data_type, i.format_mask) page_items,
       case when c.column_name is not null then &C_TRUE. else &C_FALSE. end is_column_based
  from apex_application_page_items i
  join apex_application_page_proc pr
    on i.application_id = pr.application_id
   and i.page_id = pr.page_id
  left join user_tab_columns c
    on pr.attribute_02 = c.table_name
   and i.item_source = c.column_name
 where pr.process_type_code = 'DML_FETCH_ROW';
