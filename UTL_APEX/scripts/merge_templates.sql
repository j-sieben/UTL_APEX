set define off
set sqlprefix off

begin
  utl_text.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°  -- SPEC\CR\°' || 
q'°  procedure delete_#SHORT_NAME#(\CR\°' || 
q'°    p_row in #TABLE_NAME#%rowtype);\CR\°' || 
q'°    \CR\°' || 
q'°  procedure merge_#SHORT_NAME#(\CR\°' || 
q'°    p_row in out nocopy #TABLE_NAME#%rowtype);\CR\°' || 
q'°    \CR\°' || 
q'°  procedure merge_#SHORT_NAME#(\CR\°' || 
q'°    #PARAM_LIST#);\CR\°' || 
q'°    \CR\°' || 
q'°  -- IMPLEMENTATION\CR\°' || 
q'°  procedure delete_#SHORT_NAME#(\CR\°' || 
q'°    p_row in #TABLE_NAME#%rowtype)\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    delete from #TABLE_NAME#\CR\°' || 
q'°     where #PK_LIST#;\CR\°' || 
q'°  end delete_#SHORT_NAME#;\CR\°' || 
q'°    \CR\°' || 
q'°  procedure merge_#SHORT_NAME#(\CR\°' || 
q'°    p_row in out nocopy #TABLE_NAME#%rowtype)\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    #MERGE_STMT#\CR\°' || 
q'°  end merge_#SHORT_NAME#;\CR\°' || 
q'°    \CR\°' || 
q'°  procedure merge_#SHORT_NAME#(\CR\°' || 
q'°    #PARAM_LIST#) \CR\°' || 
q'°  as\CR\°' || 
q'°    l_row #TABLE_NAME#%rowtype;\CR\°' || 
q'°  begin\CR\°' || 
q'°    #RECORD_LIST#;\CR\°' || 
q'°    \CR\°' || 
q'°    merge_#SHORT_NAME#(l_row);\CR\°' || 
q'°  end merge_#SHORT_NAME#;°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'PARAM_LIST',
    p_uttm_text => q'°p_#COLUMN_NAME_RPAD# in #TABLE_NAME#.#COLUMN_NAME#%type°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'PK_LIST',
    p_uttm_text => q'°#COLUMN_NAME# = p_row.#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'UPDATE_LIST',
    p_uttm_text => q'°t.#COLUMN_NAME# = s.#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'RECORD_LIST',
    p_uttm_text => q'°l_row.#COLUMN_NAME# := p_#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'USING_LIST',
    p_uttm_text => q'°p_row.#COLUMN_NAME# #COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'ON_LIST',
    p_uttm_text => q'°t.#COLUMN_NAME# = s.#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'INSERT_LIST',
    p_uttm_text => q'°s.#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'COL_LIST',
    p_uttm_text => q'°t.#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'MERGE',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°merge into #TABLE_NAME# t\CR\°' || 
q'°    using (select #USING_LIST#\CR\°' || 
q'°             from dual) s\CR\°' || 
q'°       on (#ON_LIST#)\CR\°' || 
q'°     when matched then update set\CR\°' || 
q'°            #UPDATE_LIST#\CR\°' || 
q'°     when not matched then insert(\CR\°' || 
q'°            #COL_LIST#)\CR\°' || 
q'°          values(\CR\°' || 
q'°            #INSERT_LIST#);°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'RULE_EXPRESSION',
    p_uttm_type => 'REDACT',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°SYS_CONTEXT('USERENV','OS_USER') != '#EXPRESSION#'°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => null
  );

  utl_text.merge_template(
    p_uttm_name => 'VIEW',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°create or replace view force #VIEW_NAME# as\CR\°' || 
q'°select seq_id,\CR\°' || 
q'°       #COLUMN_LIST#\CR\°' || 
q'°  from apex_collections\CR\°' || 
q'° where collection_name = '#VIEW_NAME#'\CR\°' || 
q'°°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°#COLUMN_FROM_COLLECTION# #COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COPY_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := #CONVERT_FROM_ITEM#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'PACKAGE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°create or replace package #PAGE_ALIAS#_ui_pkg\CR\°' || 
q'°  authid definer\CR\°' || 
q'°as\CR\°' || 
q'°\CR\°' || 
q'°  function validate_#PAGE_ALIAS#\CR\°' || 
q'°    return boolean;\CR\°' || 
q'°    \CR\°' || 
q'°  procedure process_#PAGE_ALIAS#;\CR\°' || 
q'°\CR\°' || 
q'°end #PAGE_ALIAS#_ui_pkg;\CR\°' || 
q'°/\CR\°' || 
q'°\CR\°' || 
q'°create or replace package body emp_ui_pkg\CR\°' || 
q'°as\CR\°' || 
q'°\CR\°' || 
q'°  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;\CR\°' || 
q'°  c_yes constant varchar2(3 byte) := 'YES';\CR\°' || 
q'°  c_no constant varchar2(3 byte) := 'NO';\CR\°' || 
q'°  \CR\°' || 
q'°  g_page_values utl_apex.page_value_t;\CR\°' || 
q'°  g_#PAGE_ALIAS#_row app_ui_emp_main%rowtype;\CR\°' || 
q'°  \CR\°' || 
q'°  procedure copy_emp\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    g_page_values := utl_apex.get_page_values;\CR\°' || 
q'°    #COPY_LIST#;\CR\°' || 
q'°  end copy_emp;\CR\°' || 
q'°  \CR\°' || 
q'°  \CR\°' || 
q'°  function validate_emp\CR\°' || 
q'°    return boolean\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    -- copy_emp;\CR\°' || 
q'°    -- TODO: Validierungslogik implementieren\CR\°' || 
q'°    return true;\CR\°' || 
q'°  end validate_emp;\CR\°' || 
q'°  \CR\°' || 
q'°    \CR\°' || 
q'°  procedure process_emp\CR\°' || 
q'°  as\CR\°' || 
q'°    c_collection_name constant varchar2(30 byte) := '#COLLECTION_NAME#';\CR\°' || 
q'°  begin\CR\°' || 
q'°    copy_emp;  \CR\°' || 
q'°    case\CR\°' || 
q'°    when utl_apex.INSERTING then\CR\°' || 
q'°      apex_collection.add_member(\CR\°' || 
q'°        p_collection_name => c_collection_name,\CR\°' || 
q'°        #PARAM_LIST#,\CR\°' || 
q'°        p_generate_md5 => c_no);\CR\°' || 
q'°    when utl_apex.UPDATING then\CR\°' || 
q'°      apex_collection.update_member(\CR\°' || 
q'°        p_seq => g_emp_row.seq_id,\CR\°' || 
q'°        p_collection_name => c_collection_name,\CR\°' || 
q'°        #PARAM_LIST#);\CR\°' || 
q'°    when utl_apex.DELETING then\CR\°' || 
q'°      apex_collection.delete_member(\CR\°' || 
q'°        p_seq => g_emp_row.seq_id,\CR\°' || 
q'°        p_collection_name => c_collection_name);\CR\°' || 
q'°    else\CR\°' || 
q'°      null;\CR\°' || 
q'°    end case;\CR\°' || 
q'°  end process_emp;\CR\°' || 
q'°\CR\°' || 
q'°end;/°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'PARAMETER_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°p_#COLLECTION_NAME# => #COLUMN_TO_COLLECTION#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°rawtohex(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°#COLUMN_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'°xmltype(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°#COLLECTION_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°#COLLECTION_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°#COLLECTION_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°to_date(#COLLECTION_NAME#, '#DATE_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°hextoraw(#COLLECTION_NAME#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°to_date(#COLLECTION_NAME#, '#TIMESTAMP_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°#COLLECTION_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'°#COLLECTION_NAME#°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°to_blob(utl_apex.get(g_page_values, '#COLUMN_NAME#'))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°utl_apex.get(g_page_values, '#COLUMN_NAME#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°utl_apex.get(g_page_values, '#COLUMN_NAME#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°to_date(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#DATE_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°hextoraw(utl_apex.get(g_page_values, '#COLUMN_NAME#'))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°to_timestamp(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#TIMESTAMP_FORMAT#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°utl_apex.get(g_page_values, '#COLUMN_NAME#')°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'°xmltype(utl_apex.get(g_page_values, '#COLUMN_NAME#'))°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°BLOB°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°C°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°CLOB°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°D°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°N°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°N°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°C°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°D°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°C°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'°XMLTYPE°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'GRID_DATA_TYPE',
    p_uttm_type => 'APEX_IG',
    p_uttm_mode => 'NUMBER',
    p_uttm_text => q'°  g_#STATIC_ID#_row.#COLUMN_NAME# := to_number(v('#COLUMN_NAME_UPPER#')#FORMAT_MASK|, '|'|#);°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'GRID_DATA_TYPE',
    p_uttm_type => 'APEX_IG',
    p_uttm_mode => 'DATE',
    p_uttm_text => q'°  g_#STATIC_ID#_row.#COLUMN_NAME# := to_date(v('#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'GRID_DATA_TYPE',
    p_uttm_type => 'APEX_IG',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°  g_#STATIC_ID#_row.#COLUMN_NAME# := v('#COLUMN_NAME_UPPER#');°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'GRID_PROCEDURE',
    p_uttm_type => 'APEX_IG',
    p_uttm_mode => 'DYNAMIC',
    p_uttm_text => q'°declare
  g_#STATIC_ID#_row #TABLE_NAME#%rowtype;
begin
#COLUMN_LIST#
  :x := g_row;
end;°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'GRID_PROCEDURE',
    p_uttm_type => 'APEX_IG',
    p_uttm_mode => 'STATIC',
    p_uttm_text => q'°  g_#STATIC_ID#_row #TABLE_NAME#%rowtype;

begin
#COLUMN_LIST#
end;°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DATE',
    p_uttm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_date(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#');°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'NUMBER',
    p_uttm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_number(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'°-- UI_PACKAGE-Body\CR\°' || 
q'°-- Globale Variablen\CR\°' || 
q'°  g_page_values utl_apex.page_value_t;\CR\°' || 
q'°  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;\CR\°' || 
q'°  \CR\°' || 
q'°-- COPY_ROW-Methode\CR\°' || 
q'°  \CR\°' || 
q'°  /* Hilfsfunktion zur Uebernahme der Seitenelementwerte \CR\°' || 
q'°   * %usage  Wird aufgerufen, um fuer die aktuell ausgefuehrte APEX-Seite den Sessionstatus\CR\°' || 
q'°   *         zu kopieren und in einer PL/SQL-Tabelle verfuegbar zu machen\CR\°' || 
q'°   */\CR\°' || 
q'°  procedure copy_#PAGE_ALIAS#\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    g_page_values := utl_apex.get_page_values;\CR\°' || 
q'°    #COLUMN_LIST#\CR\°' || 
q'°  end copy_#PAGE_ALIAS#;\CR\°' || 
q'°    \CR\°' || 
q'°-- METHOD IMPELEMENTATON\CR\°' || 
q'°\CR\°' || 
q'°  function validate_#PAGE_ALIAS#\CR\°' || 
q'°    return boolean\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    -- copy_#PAGE_ALIAS#;\CR\°' || 
q'°    -- Validierungen. Falls keine Validierung, copy-Methode auskommentiert lassen\CR\°' || 
q'°    return true;\CR\°' || 
q'°  end validate_#PAGE_ALIAS#;\CR\°' || 
q'°  \CR\°' || 
q'°  \CR\°' || 
q'°  procedure process_#PAGE_ALIAS#\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    copy_#PAGE_ALIAS#;\CR\°' || 
q'°    case when utl_apex.inserting then\CR\°' || 
q'°      #INSERT_METHOD#(g_#PAGE_ALIAS#_row);\CR\°' || 
q'°    case when utl_apex.updating then\CR\°' || 
q'°      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);\CR\°' || 
q'°    else\CR\°' || 
q'°      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);\CR\°' || 
q'°    end case;\CR\°' || 
q'°  end process_#PAGE_ALIAS#;°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'MERGE',
    p_uttm_text => q'°-- UI_PACKAGE-Body\CR\°' || 
q'°-- Globale Variablen\CR\°' || 
q'°  g_page_values utl_apex.page_value_t;\CR\°' || 
q'°  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;\CR\°' || 
q'°  \CR\°' || 
q'°-- COPY_ROW-Methode\CR\°' || 
q'°  \CR\°' || 
q'°  /* Hilfsfunktion zur Uebernahme der Seitenelementwerte \CR\°' || 
q'°   * %usage  Wird aufgerufen, um fuer die aktuell ausgefuehrte APEX-Seite den Sessionstatus\CR\°' || 
q'°   *         zu kopieren und in einer PL/SQL-Tabelle verfuegbar zu machen\CR\°' || 
q'°   */\CR\°' || 
q'°  procedure copy_#PAGE_ALIAS#\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    g_page_values := utl_apex.get_page_values;\CR\°' || 
q'°    #COLUMN_LIST#\CR\°' || 
q'°  end copy_#PAGE_ALIAS#;\CR\°' || 
q'°    \CR\°' || 
q'°-- METHOD IMPELEMENTATON\CR\°' || 
q'°\CR\°' || 
q'°  function validate_#PAGE_ALIAS#\CR\°' || 
q'°    return boolean\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    -- copy_#PAGE_ALIAS#;\CR\°' || 
q'°    -- Validierungen. Falls keine Validierung, copy-Methode auskommentiert lassen\CR\°' || 
q'°    return true;\CR\°' || 
q'°  end validate_#PAGE_ALIAS#;\CR\°' || 
q'°  \CR\°' || 
q'°  \CR\°' || 
q'°  procedure process_#PAGE_ALIAS#\CR\°' || 
q'°  as\CR\°' || 
q'°  begin\CR\°' || 
q'°    copy_#PAGE_ALIAS#;\CR\°' || 
q'°    case when utl_apex.inserting or utl_apex.updating then\CR\°' || 
q'°      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);\CR\°' || 
q'°    else\CR\°' || 
q'°      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);\CR\°' || 
q'°    end case;\CR\°' || 
q'°  end process_#PAGE_ALIAS#;°',
    p_uttm_log_text => q'°°',
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on
set sqlprefix #