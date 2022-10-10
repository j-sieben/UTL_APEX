define core_dir=core/
define pkg_dir=&CORE_DIR.packages/
define script_dir=&CORE_DIR.scripts/
define type_dir=&CORE_DIR.types/
define view_dir=&CORE_DIR.views/
define msg_dir=&CORE_DIR.messages/&DEFAULT_LANGUAGE./

prompt
prompt &section.
prompt &h2.Messages
prompt &s1.Message Group UTL_APEX
@&MSG_DIR.MessageGroup_UTL_APEX.sql

prompt
prompt &section.
prompt &h2.Templates
prompt &s1.Template Group APEX_COLLECTION
@&SCRIPT_DIR.TemplateGroup_APEX_COLLECTION.sql

prompt &s1.Template Group APEX_FORM
@&SCRIPT_DIR.TemplateGroup_APEX_FORM.sql

prompt &s1.Template Group TABLE_API
@&SCRIPT_DIR.TemplateGroup_TABLE_API.sql

prompt
prompt &section.
prompt &h2.Types
prompt &s1.Type UTL_DEV_APEX_COL_T
@&TYPE_DIR.utl_dev_apex_col_t.tps

prompt &s1.Type UTL_DEV_APEX_COL_TAB
@&TYPE_DIR.utl_dev_apex_col_tab.tps

prompt &s1.Type UTL_APEX_PAGE_ITEM_T
@&TYPE_DIR.utl_apex_page_item_t.tps

prompt &s1.Type UTL_APEX_PAGE_ITEM_TAB
@&TYPE_DIR.utl_apex_page_item_tab.tps

prompt
prompt &section.
prompt &h2.Views

prompt
prompt &section.
prompt &h2.Package specifications
prompt &s1.Package UTL_APEX
@&PKG_DIR.utl_apex.pks

prompt &s1.Package UTL_DEV_APEX
@&PKG_DIR.utl_dev_apex.pks

prompt
prompt &section.
prompt &h2.Package dependent Views

prompt &s1.View APEX_UI_LIST_MENU
@&VIEW_DIR.apex_ui_list_menu.vw

prompt &s1.View UTL_APEX_FETCH_ROW_COLUMNS
@tools/check_apex_version_gt.sql 5.1 "&VIEW_DIR.utl_apex_fetch_row_columns.vw"

prompt &s1.View UTL_APEX_FORM_REGION_COLUMNS
@tools/check_apex_version_gt.sql 19 "&VIEW_DIR.utl_apex_form_region_columns.vw"

prompt &s1.View UTL_APEX_IG_COLUMNS
@&VIEW_DIR.utl_apex_ig_columns.vw

prompt &s1.View UTL_DEV_APEX_COLLECTION
@tools/check_apex_version_gt.sql 5.1 "&VIEW_DIR.utl_dev_apex_collection.vw"

prompt &s1.View UTL_DEV_APEX_FORM_COLLECTION
@tools/check_apex_version_gt.sql 19 "&VIEW_DIR.utl_dev_apex_form_collection.vw"

prompt
prompt &section.
prompt &h2.Package bodies
prompt &s1.Package Body UTL_APEX
@&PKG_DIR.utl_apex.pkb

prompt &s1.Package Body UTL_DEV_APEX
@&PKG_DIR.utl_dev_apex.pkb

prompt
prompt &section.
prompt &h2.Package dependent Scripts
prompt &s1.Script set_parameter
@&SCRIPT_DIR.ParameterGroup_UTL_APEX.sql

