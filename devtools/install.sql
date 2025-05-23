define core_dir=devtools/
define pkg_dir=&CORE_DIR.packages/
define script_dir=&CORE_DIR.scripts/
define type_dir=&CORE_DIR.types/
define view_dir=&CORE_DIR.views/
define msg_dir=&CORE_DIR.messages/&DEFAULT_LANGUAGE./

prompt &h2.Templates
prompt &s1.Template Group APEX_COLLECTION
@&SCRIPT_DIR.TemplateGroup_APEX_COLLECTION.sql

prompt &s1.Template Group APEX_FORM
@&SCRIPT_DIR.TemplateGroup_APEX_FORM.sql

prompt &s1.Template Group TABLE_API
@&SCRIPT_DIR.TemplateGroup_TABLE_API.sql

prompt &h2.Types
prompt &s1.Type UTL_DEV_APEX_COL_T
@&TYPE_DIR.utl_dev_apex_col_t.tps

prompt &s1.Type UTL_DEV_APEX_COL_TAB
@&TYPE_DIR.utl_dev_apex_col_tab.tps

prompt &h2.Packages
prompt &s1.Package UTL_DEV_APEX
@&PKG_DIR.utl_dev_apex.pks

prompt &h2.Views
prompt &s1.View UTL_DEV_APEX_COLLECTION
@&VIEW_DIR.utl_dev_apex_collection.vw

prompt &s1.View UTL_DEV_APEX_FORM_COLLECTION
@&VIEW_DIR.utl_dev_apex_form_collection.vw

prompt &h2.Package bodies
prompt &s1.Package Body UTL_DEV_APEX
@&PKG_DIR.utl_dev_apex.pkb

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
prompt &h1.Finished UTL_APEX DevTools Installation

exit

