create or replace view utl_apex_form_region_columns as
select r.application_id,
       r.page_id,
       r.static_id,
       utl_apex_page_item(lower(r.table_name), lower(i.item_source), i.item_source, i.item_source_data_type, i.format_mask) page_items,
       &C_TRUE. is_column_based
  from apex_application_page_regions r
  join apex_application_page_items i
    on r.application_id = i.application_id
   and r.page_id = i.page_id
   and r.region_id = i.data_source_region_id
 where r.source_type_code = 'NATIVE_FORM';
