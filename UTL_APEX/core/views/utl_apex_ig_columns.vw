create or replace force view utl_apex_ig_columns as
select c.application_id,
       c.page_id,
       r.static_id,
       utl_apex_page_item_t(null, lower(c.name), c.name, c.heading, c.data_type, c.format_mask) page_items,
       &C_TRUE. is_column_based
  from apex_appl_page_ig_columns c
  join apex_application_page_regions r
    on c.region_id = r.region_id
 where instr(':ROWID:APEX$ROW_ACTION:APEX$ROW_SELECTOR:', ':' || c.name || ':') = 0;
