create or replace force view apex_ui_list_menu as
 with params as(
        select  /*+ no_merge */ utl_apex.get_application_id(utl_apex.C_FALSE) p_application_id
          from dual)
 select level level_value,
        l1.list_name,
        l1.display_sequence,
        l1.parent_entry_text,
        l2.parent_page_alias,
        l1.entry_text label_value,
        l1.entry_target target_value,
        'NO' is_current,
        l1.entry_image image_value,
        l1.entry_image_attributes image_attr_value,
        l1.entry_image_alt_attribute image_alt_value,
        l1.entry_attribute_01 attribute_01,
        l1.entry_attribute_02 attribute_02,
        l1.entry_attribute_03 attribute_03,
        l1.entry_attribute_04 attribute_04,
        l1.entry_attribute_05 attribute_05,
        l1.entry_attribute_06 attribute_06,
        l1.entry_attribute_07 attribute_07,
        l1.entry_attribute_08 attribute_08,
        l1.entry_attribute_09 attribute_09,
        l1.entry_attribute_10 attribute_10
   from apex_application_list_entries l1
   join params p
     on l1.application_id = p_application_id
   left join (
        select l.application_id, l.list_name, l.entry_text, lower(p.page_alias) parent_page_alias
          from apex_application_list_entries l
          join apex_application_pages p
            on l.application_id = p.application_id
          join params p
            on p.application_id = p_application_id
           and upper(substr(entry_target, instr(entry_target, ':') + 1, instr(entry_target, ':', 1, 2) - instr(entry_target, ':') - 1)) = p.page_alias) l2
     on l1.parent_entry_text = l2.entry_text
    and l1.list_name = l2.list_name
   left join apex_application_build_options o
     on l1.application_id = o.application_id
    and l1.build_option = o.build_option_name
  where coalesce(o.build_option_status, 'Include') = 'Include'
    and utl_apex.user_is_authorized(l1.authorization_scheme) = utl_apex.c_true
  start with list_entry_parent_id is null
connect by prior list_entry_id = list_entry_parent_id;
