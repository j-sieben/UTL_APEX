define core_dir=core/
define pkg_dir=&CORE_DIR.packages/
define script_dir=&CORE_DIR.scripts/
define type_dir=&CORE_DIR.types/
define view_dir=&CORE_DIR.views/
define msg_dir=&CORE_DIR.messages/&DEFAULT_LANGUAGE./

prompt &h2.Messages
prompt &s1.Message Group UTL_APEX
@&MSG_DIR.MessageGroup_UTL_APEX

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
  l_invalid_objects binary_integer;
begin
  dbms_utility.compile_schema(
    schema => user,
    compile_all => false);
    
  select count(*)
    into l_invalid_objects
    from user_objects
   where status = 'INVALID';
   
  dbms_output.put_line(l_invalid_objects || ' invalid objects found');
end;
/
prompt &h1.Finished UTL_APEX Installation

exit

