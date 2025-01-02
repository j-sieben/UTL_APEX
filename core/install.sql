define core_dir=core/
define pkg_dir=&CORE_DIR.packages/
define script_dir=&CORE_DIR.scripts/
define type_dir=&CORE_DIR.types/
define view_dir=&CORE_DIR.views/
define msg_dir=&CORE_DIR.messages/&DEFAULT_LANGUAGE./

prompt &h2.Messages
prompt &s1.Message Group UTL_APEX
@&MSG_DIR.MessageGroup_UTL_APEX

prompt &h2.Types
prompt &s1.Type UTL_APEX_PAGE_ITEM_T
@&TYPE_DIR.utl_apex_page_item_t.tps

prompt &s1.Type UTL_APEX_PAGE_ITEM_TAB
@&TYPE_DIR.utl_apex_page_item_tab.tps

prompt &h2.Package specifications
prompt &s1.Package UTL_APEX
@&PKG_DIR.utl_apex.pks

prompt &h2.Package dependent Views

prompt &s1.View APEX_UI_LIST_MENU
@&VIEW_DIR.apex_ui_list_menu.vw

prompt &s1.View UTL_APEX_FETCH_ROW_COLUMNS
@&VIEW_DIR.utl_apex_fetch_row_columns.vw

prompt &s1.View UTL_APEX_FORM_REGION_COLUMNS
@&VIEW_DIR.utl_apex_form_region_columns.vw

prompt &s1.View UTL_APEX_IG_COLUMNS
@&VIEW_DIR.utl_apex_ig_columns.vw

prompt &h2.Package bodies
prompt &s1.Package Body UTL_APEX
@&PKG_DIR.utl_apex.pkb

prompt &h2.Package dependent Scripts
prompt &s1.Script set_parameter
@&SCRIPT_DIR.ParameterGroup_UTL_APEX.sql


prompt &h2.Recompiling invalid objects
declare
  cursor obj_cur is
    select object_type, object_name,
           case when instr(object_type, 'BODY') = 0 then 1 else 2 end recompile_order
      from user_objects
     where status = 'INVALID'
       and object_name in ('UTL_APEX', 'APEX_UI_LIST_MENU')
     order by recompile_order;
  l_invalid_objects binary_integer;
begin
  for o in obj_cur loop
    if o.recompile_order = 1 then
      execute immediate 'alter ' || o.object_type || ' compile';
    else
      execute immediate 'alter ' || o.object_type || ' compile body';
    end if;
  end loop;
  
  select count(*)
    into l_invalid_objects
    from user_objects
   where status = 'INVALID';
   
  dbms_output.put_line(l_invalid_objects || ' invalid objects found');
end;
/
prompt &h1.Finished UTL_APEX Installation

exit

