set define off

begin
  code_generator.merge_template(
    p_cgtm_name => 'VIEW',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°create or replace view force #VIEW_NAME# as°' ||
q'°select seq_id,°' ||
q'°       #COLUMN_LIST#°' ||
q'°  from apex_collections°' ||
q'° where collection_name = '#VIEW_NAME#'°' ||
q'°°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN_LIST',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°#COLUMN_FROM_COLLECTION# #COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COPY_LIST',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := #CONVERT_FROM_ITEM#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'PACKAGE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°create or replace package #PAGE_ALIAS#_ui_pkg°' ||
q'°  authid definer°' ||
q'°as°' ||
q'°°' ||
q'°  function validate_#PAGE_ALIAS#°' ||
q'°    return boolean;°' ||
q'°    °' ||
q'°  procedure process_#PAGE_ALIAS#;°' ||
q'°°' ||
q'°end #PAGE_ALIAS#_ui_pkg;°' ||
q'°/°' ||
q'°°' ||
q'°create or replace package body emp_ui_pkg°' ||
q'°as°' ||
q'°°' ||
q'°  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;°' ||
q'°  c_yes constant varchar2(3 byte) := 'YES';°' ||
q'°  c_no constant varchar2(3 byte) := 'NO';°' ||
q'°  °' ||
q'°  g_page_values utl_apex.page_value_t;°' ||
q'°  g_#PAGE_ALIAS#_row app_ui_emp_main%rowtype;°' ||
q'°  °' ||
q'°  procedure copy_emp°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    g_page_values := utl_apex.get_page_values;°' ||
q'°    #COPY_LIST#;°' ||
q'°  end copy_emp;°' ||
q'°  °' ||
q'°  °' ||
q'°  function validate_emp°' ||
q'°    return boolean°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    -- copy_emp;°' ||
q'°    -- TODO: Validierungslogik implementieren°' ||
q'°    return true;°' ||
q'°  end validate_emp;°' ||
q'°  °' ||
q'°    °' ||
q'°  procedure process_emp°' ||
q'°  as°' ||
q'°    c_collection_name constant varchar2(30 byte) := '#COLLECTION_NAME#';°' ||
q'°  begin°' ||
q'°    copy_emp;  °' ||
q'°    case°' ||
q'°    when utl_apex.INSERTING then°' ||
q'°      apex_collection.add_member(°' ||
q'°        p_collection_name => c_collection_name,°' ||
q'°        #PARAM_LIST#,°' ||
q'°        p_generate_md5 => c_no);°' ||
q'°    when utl_apex.UPDATING then°' ||
q'°      apex_collection.update_member(°' ||
q'°        p_seq => g_emp_row.seq_id,°' ||
q'°        p_collection_name => c_collection_name,°' ||
q'°        #PARAM_LIST#);°' ||
q'°    when utl_apex.DELETING then°' ||
q'°      apex_collection.delete_member(°' ||
q'°        p_seq => g_emp_row.seq_id,°' ||
q'°        p_collection_name => c_collection_name);°' ||
q'°    else°' ||
q'°      null;°' ||
q'°    end case;°' ||
q'°  end process_emp;°' ||
q'°°' ||
q'°end;/°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'PARAMETER_LIST',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°p_#COLLECTION_NAME# => #COLUMN_TO_COLLECTION#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'BLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CHAR',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'DATE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'INTEGER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'NUMBER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'ROWID',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°rawtohex(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'TIMESTAMP',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'VARCHAR2',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'XMLTYPE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_TO_COLLECTION',
    p_cgtm_text => q'°xmltype(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'BLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°#COLLECTION_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CHAR',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°#COLLECTION_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°#COLLECTION_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'DATE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°to_date(#COLLECTION_NAME#, '#DATE_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'INTEGER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'NUMBER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'ROWID',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°hextoraw(#COLLECTION_NAME#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'TIMESTAMP',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°to_date(#COLLECTION_NAME#, '#TIMESTAMP_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'VARCHAR2',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°#COLLECTION_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'XMLTYPE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_COLLECTION',
    p_cgtm_text => q'°#COLLECTION_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'BLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°to_blob(utl_apex.get(g_page_values, '#COLUMN_NAME#'))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CHAR',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°utl_apex.get(g_page_values, '#COLUMN_NAME#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°utl_apex.get(g_page_values, '#COLUMN_NAME#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'DATE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°to_date(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#DATE_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'INTEGER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'NUMBER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'ROWID',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°hextoraw(utl_apex.get(g_page_values, '#COLUMN_NAME#'))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'TIMESTAMP',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°to_timestamp(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#TIMESTAMP_FORMAT#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'VARCHAR2',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°utl_apex.get(g_page_values, '#COLUMN_NAME#')°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'XMLTYPE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'CONVERT_FROM_ITEM',
    p_cgtm_text => q'°xmltype(utl_apex.get(g_page_values, '#COLUMN_NAME#'))°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'BLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°BLOB°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CHAR',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°C°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'CLOB',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°CLOB°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'DATE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°D°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'INTEGER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°N°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'NUMBER',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°N°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'ROWID',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°C°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'TIMESTAMP',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°D°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'VARCHAR2',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°C°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'XMLTYPE',
    p_cgtm_type => 'APEX_COLLECTION',
    p_cgtm_mode => 'COLLECTION_DATA_TYPE',
    p_cgtm_text => q'°XMLTYPE°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'GRID_DATA_TYPE',
    p_cgtm_type => 'APEX_IG',
    p_cgtm_mode => 'NUMBER',
    p_cgtm_text => q'°  g_#STATIC_ID#_row.#COLUMN_NAME# := to_number(v('#COLUMN_NAME_UPPER#')#FORMAT_MASK|, '|'|#);°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'GRID_DATA_TYPE',
    p_cgtm_type => 'APEX_IG',
    p_cgtm_mode => 'DATE',
    p_cgtm_text => q'°  g_#STATIC_ID#_row.#COLUMN_NAME# := to_date(v('#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'GRID_DATA_TYPE',
    p_cgtm_type => 'APEX_IG',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°  g_#STATIC_ID#_row.#COLUMN_NAME# := v('#COLUMN_NAME_UPPER#');°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'GRID_PROCEDURE',
    p_cgtm_type => 'APEX_IG',
    p_cgtm_mode => 'DYNAMIC',
    p_cgtm_text => q'°declare
  g_#STATIC_ID#_row #TABLE_NAME#%rowtype;
begin
#COLUMN_LIST#
  :x := g_row;
end;°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'GRID_PROCEDURE',
    p_cgtm_type => 'APEX_IG',
    p_cgtm_mode => 'STATIC',
    p_cgtm_text => q'°  g_#STATIC_ID#_row #TABLE_NAME#%rowtype;

begin
#COLUMN_LIST#
end;°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'APEX_FORM',
    p_cgtm_mode => 'DATE',
    p_cgtm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_date(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'APEX_FORM',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#');°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'APEX_FORM',
    p_cgtm_mode => 'NUMBER',
    p_cgtm_text => q'°g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_number(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'METHODS',
    p_cgtm_type => 'APEX_FORM',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°-- UI_PACKAGE-Body°' ||
q'°-- Globale Variablen°' ||
q'°  g_page_values utl_apex.page_value_t;°' ||
q'°  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;°' ||
q'°  °' ||
q'°-- COPY_ROW-Methode°' ||
q'°  °' ||
q'°  /* Hilfsfunktion zur Uebernahme der Seitenelementwerte °' ||
q'°   * %usage  Wird aufgerufen, um fuer die aktuell ausgefuehrte APEX-Seite den Sessionstatus°' ||
q'°   *         zu kopieren und in einer PL/SQL-Tabelle verfuegbar zu machen°' ||
q'°   */°' ||
q'°  procedure copy_#PAGE_ALIAS#°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    g_page_values := utl_apex.get_page_values;°' ||
q'°    #COLUMN_LIST#°' ||
q'°  end copy_#PAGE_ALIAS#;°' ||
q'°    °' ||
q'°-- METHOD IMPELEMENTATON°' ||
q'°°' ||
q'°  function validate_#PAGE_ALIAS#°' ||
q'°    return boolean°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    -- copy_#PAGE_ALIAS#;°' ||
q'°    -- Validierungen. Falls keine Validierung, copy-Methode auskommentiert lassen°' ||
q'°    return true;°' ||
q'°  end validate_#PAGE_ALIAS#;°' ||
q'°  °' ||
q'°  °' ||
q'°  procedure process_#PAGE_ALIAS#°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    copy_#PAGE_ALIAS#;°' ||
q'°    case when utl_apex.inserting then°' ||
q'°      #INSERT_METHOD#(g_#PAGE_ALIAS#_row);°' ||
q'°    case when utl_apex.updating then°' ||
q'°      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);°' ||
q'°    else°' ||
q'°      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);°' ||
q'°    end case;°' ||
q'°  end process_#PAGE_ALIAS#;°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'METHODS',
    p_cgtm_type => 'APEX_FORM',
    p_cgtm_mode => 'MERGE',
    p_cgtm_text => q'°-- UI_PACKAGE-Body°' ||
q'°-- Globale Variablen°' ||
q'°  g_page_values utl_apex.page_value_t;°' ||
q'°  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;°' ||
q'°  °' ||
q'°-- COPY_ROW-Methode°' ||
q'°  °' ||
q'°  /* Hilfsfunktion zur Uebernahme der Seitenelementwerte °' ||
q'°   * %usage  Wird aufgerufen, um fuer die aktuell ausgefuehrte APEX-Seite den Sessionstatus°' ||
q'°   *         zu kopieren und in einer PL/SQL-Tabelle verfuegbar zu machen°' ||
q'°   */°' ||
q'°  procedure copy_#PAGE_ALIAS#°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    g_page_values := utl_apex.get_page_values;°' ||
q'°    #COLUMN_LIST#°' ||
q'°  end copy_#PAGE_ALIAS#;°' ||
q'°    °' ||
q'°-- METHOD IMPELEMENTATON°' ||
q'°°' ||
q'°  function validate_#PAGE_ALIAS#°' ||
q'°    return boolean°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    -- copy_#PAGE_ALIAS#;°' ||
q'°    -- Validierungen. Falls keine Validierung, copy-Methode auskommentiert lassen°' ||
q'°    return true;°' ||
q'°  end validate_#PAGE_ALIAS#;°' ||
q'°  °' ||
q'°  °' ||
q'°  procedure process_#PAGE_ALIAS#°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    copy_#PAGE_ALIAS#;°' ||
q'°    case when utl_apex.inserting or utl_apex.updating then°' ||
q'°      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);°' ||
q'°    else°' ||
q'°      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);°' ||
q'°    end case;°' ||
q'°  end process_#PAGE_ALIAS#;°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'METHODS',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°  -- SPEC°' ||
q'°  procedure delete_#SHORT_NAME#(°' ||
q'°    p_row #TABLE_NAME#%rowtype);°' ||
q'°    °' ||
q'°  procedure merge_#SHORT_NAME#(°' ||
q'°    p_row #TABLE_NAME#%rowtype);°' ||
q'°    °' ||
q'°  procedure merge_#SHORT_NAME#(°' ||
q'°    #PARAM_LIST#);°' ||
q'°    °' ||
q'°  -- IMPLEMENTATION°' ||
q'°  procedure delete_#SHORT_NAME#(°' ||
q'°    p_row #TABLE_NAME#%rowtype)°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    delete from #TABLE_NAME#°' ||
q'°     where #PK_LIST#;°' ||
q'°  end delete_#SHORT_NAME#;°' ||
q'°    °' ||
q'°  procedure merge_#SHORT_NAME#(°' ||
q'°    p_row #TABLE_NAME#%rowtype)°' ||
q'°  as°' ||
q'°  begin°' ||
q'°    #MERGE_STMT#°' ||
q'°  end merge_#SHORT_NAME#;°' ||
q'°    °' ||
q'°  procedure merge_#SHORT_NAME#(°' ||
q'°    #PARAM_LIST#) °' ||
q'°  as°' ||
q'°    l_row #TABLE_NAME#%rowtype;°' ||
q'°  begin°' ||
q'°    #RECORD_LIST#;°' ||
q'°    °' ||
q'°    merge_#SHORT_NAME#(l_row);°' ||
q'°  end merge_#SHORT_NAME#;°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'PARAM_LIST',
    p_cgtm_text => q'°p_#COLUMN_NAME_RPAD# in #TABLE_NAME#.#COLUMN_NAME#%type°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'PK_LIST',
    p_cgtm_text => q'°#COLUMN_NAME# = p_row.#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'UPDATE_LIST',
    p_cgtm_text => q'°t.#COLUMN_NAME# = s.#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'RECORD_LIST',
    p_cgtm_text => q'°l_row.#COLUMN_NAME# := p_#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'USING_LIST',
    p_cgtm_text => q'°p_row.#COLUMN_NAME# #COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'ON_LIST',
    p_cgtm_text => q'°t.#COLUMN_NAME# = s.#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'INSERT_LIST',
    p_cgtm_text => q'°s.#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'COLUMN',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'COL_LIST',
    p_cgtm_text => q'°t.#COLUMN_NAME#°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'MERGE',
    p_cgtm_type => 'TABLE_API',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°merge into #TABLE_NAME# t°' ||
q'°    using (select #USING_LIST#°' ||
q'°             from dual) s°' ||
q'°       on (#ON_LIST#)°' ||
q'°     when matched then update set°' ||
q'°            #UPDATE_LIST#°' ||
q'°     when not matched then insert(°' ||
q'°            #COL_LIST#)°' ||
q'°          values(°' ||
q'°            #INSERT_LIST#);°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => 70
  );

  code_generator.merge_template(
    p_cgtm_name => 'RULE_EXPRESSION',
    p_cgtm_type => 'REDACT',
    p_cgtm_mode => 'DEFAULT',
    p_cgtm_text => q'°SYS_CONTEXT('USERENV','OS_USER') != '#EXPRESSION#'°',
    p_cgtm_log_text => q'°°',
    p_cgtm_log_severity => null
  );
  commit;
end;
/
set define on