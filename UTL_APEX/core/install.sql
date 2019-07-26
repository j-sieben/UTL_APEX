define core_dir=core/
define pkg_dir=&CORE_DIR.packages/
define script_dir=&CORE_DIR.scripts/
define type_dir=&CORE_DIR.types/
define view_dir=&CORE_DIR.views/
define msg_dir=&CORE_DIR.messages/&DEFAULT_LANGUAGE./

prompt
prompt &section.
prompt &h2.Messages
@&MSG_DIR.create_messages.sql

prompt
prompt &section.
prompt &h2.Templates
@&SCRIPT_DIR.merge_templates.sql

prompt
prompt &section.
prompt &h2.Types
prompt &s1.Type UTL_APEX_DDL_COL_T
@&TYPE_DIR.utl_apex_ddl_col_t.tps

prompt &s1.Type UTL_APEX_DDL_COL_TAB
@&TYPE_DIR.utl_apex_ddl_col_tab.tps

prompt &s1.Type UTL_APEX_PAGE_ITEM
@&TYPE_DIR.utl_apex_page_item.tps

prompt &s1.Type UTL_APEX_PAGE_ITEM_T
@&TYPE_DIR.utl_apex_page_item_t.tps

prompt
prompt &section.
prompt &h2.Views
prompt &s1.View CODE_GEN_APEX_COLLECTION
@&VIEW_DIR.code_gen_apex_collection.vw

prompt &s1.View UTL_APEX_FETCH_ROW_COLUMNS
@&VIEW_DIR.utl_apex_fetch_row_columns.vw

prompt &s1.View UTL_APEX_FORM_REGION_COLUMNS
--@&VIEW_DIR.utl_apex_form_region_columns.vw

prompt &s1.View UTL_APEX_IG_COLUMNS
--@&VIEW_DIR.utl_apex_ig_columns.vw

prompt
prompt &section.
prompt &h2.Views
prompt &s1.Package UTL_APEX
@&PKG_DIR.utl_apex.pks

prompt &s1.Package UTL_APEX_DDL
@&PKG_DIR.utl_apex_ddl.pks

prompt &s1.Package Body UTL_APEX
@&PKG_DIR.utl_apex.pkb

prompt &s1.Package Body UTL_APEX_DDL
@&PKG_DIR.utl_apex_ddl.pkb

prompt
prompt &section.
prompt &h2.Package dependent Views

prompt &s1.View APEX_UI_LIST_MENU
@&VIEW_DIR.apex_ui_list_menu.vw

prompt
prompt &section.
prompt &h2.Package dependent Scripts
prompt &s1.Script set_parameter
@&SCRIPT_DIR.set_parameters.sql
