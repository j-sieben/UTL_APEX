create or replace force view utl_apex_fetch_row_columns as
with params as(
       select length(utl_apex.get_page_prefix) + 1 prefix
         from dual)
select /*+ no_merge (p) */
       i.application_id,
       i.page_id,
       null static_id,
       utl_apex_page_item_t(lower(c.table_name), lower(substr(i.item_name, p.prefix)), i.item_name, i.label, c.data_type, i.format_mask) page_items,
       case when c.column_name is not null then utl_apex.C_TRUE else utl_apex.C_FALSE end is_column_based
  from apex_application_page_items i
  join apex_application_page_proc pr
    on i.application_id = pr.application_id
   and i.page_id = pr.page_id
  left join user_tab_columns c
    on pr.attribute_02 = c.table_name
   and i.item_source = c.column_name
 cross join params p
 where pr.process_type_code = 'DML_FETCH_ROW';
