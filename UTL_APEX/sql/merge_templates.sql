merge into code_generator_templates t
using (select 'VIEW' cgtm_name,
              'APEX_COLLECTION' cgtm_type,
              'DEFAULT' cgtm_mode,
              q'^create or replace view force #VIEW_NAME# as
select seq_id,
       #COLUMN_LIST#
  from apex_collections
 where collection_name = '#VIEW_NAME#'
^' cgtm_text
         from dual
        union all
       select 'COLUMN_LIST', 'APEX_COLLECTION', 'DEFAULT', q'^#COLUMN_FROM_COLLECTION# #COLUMN_NAME#^' from dual union all
       select 'COPY_LIST', 'APEX_COLLECTION', 'DEFAULT', q'^g_#PAGE_ALIAS#_row.#COLUMN_NAME# := #CONVERT_FROM_ITEM#^' from dual union all
       select 'PACKAGE', 'APEX_COLLECTION', 'DEFAULT',
q'^create or replace package #PAGE_ALIAS#_ui_pkg^' || chr(10) ||
q'^  authid definer^' || chr(10) ||
q'^as^' || chr(10) ||
q'^^' || chr(10) ||
q'^  function validate_#PAGE_ALIAS#^' || chr(10) ||
q'^    return boolean;^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  procedure process_#PAGE_ALIAS#;^' || chr(10) ||
q'^^' || chr(10) ||
q'^end #PAGE_ALIAS#_ui_pkg;^' || chr(10) ||
q'^/^' || chr(10) ||
q'^^' || chr(10) ||
q'^create or replace package body emp_ui_pkg^' || chr(10) ||
q'^as^' || chr(10) ||
q'^^' || chr(10) ||
q'^  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;^' || chr(10) ||
q'^  c_yes constant varchar2(3 byte) := 'YES';^' || chr(10) ||
q'^  c_no constant varchar2(3 byte) := 'NO';^' || chr(10) ||
q'^  ^' || chr(10) ||
q'^  g_page_values utl_apex.page_value_t;^' || chr(10) ||
q'^  g_#PAGE_ALIAS#_row app_ui_emp_main%rowtype;^' || chr(10) ||
q'^  ^' || chr(10) ||
q'^  procedure copy_emp^' || chr(10) ||
q'^  as^' || chr(10) ||
q'^  begin^' || chr(10) ||
q'^    g_page_values := utl_apex.get_page_values;^' || chr(10) ||
q'^    #COPY_LIST#;^' || chr(10) ||
q'^  end copy_emp;^' || chr(10) ||
q'^  ^' || chr(10) ||
q'^  ^' || chr(10) ||
q'^  function validate_emp^' || chr(10) ||
q'^    return boolean^' || chr(10) ||
q'^  as^' || chr(10) ||
q'^  begin^' || chr(10) ||
q'^    -- copy_emp;^' || chr(10) ||
q'^    -- TODO: Validierungslogik implementieren^' || chr(10) ||
q'^    return true;^' || chr(10) ||
q'^  end validate_emp;^' || chr(10) ||
q'^  ^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  procedure process_emp^' || chr(10) ||
q'^  as^' || chr(10) ||
q'^    c_collection_name constant varchar2(30 byte) := '#COLLECTION_NAME#';^' || chr(10) ||
q'^  begin^' || chr(10) ||
q'^    copy_emp;  ^' || chr(10) ||
q'^    case^' || chr(10) ||
q'^    when utl_apex.INSERTING then^' || chr(10) ||
q'^      apex_collection.add_member(^' || chr(10) ||
q'^        p_collection_name => c_collection_name,^' || chr(10) ||
q'^        #PARAM_LIST#,^' || chr(10) ||
q'^        p_generate_md5 => c_no);^' || chr(10) ||
q'^    when utl_apex.UPDATING then^' || chr(10) ||
q'^      apex_collection.update_member(^' || chr(10) ||
q'^        p_seq => g_emp_row.seq_id,^' || chr(10) ||
q'^        p_collection_name => c_collection_name,^' || chr(10) ||
q'^        #PARAM_LIST#);^' || chr(10) ||
q'^    when utl_apex.DELETING then^' || chr(10) ||
q'^      apex_collection.delete_member(^' || chr(10) ||
q'^        p_seq => g_emp_row.seq_id,^' || chr(10) ||
q'^        p_collection_name => c_collection_name);^' || chr(10) ||
q'^    else^' || chr(10) ||
q'^      null;^' || chr(10) ||
q'^    end case;^' || chr(10) ||
q'^  end process_emp;^' || chr(10) ||
q'^^' || chr(10) ||
q'^end;/^' from dual union all
       select 'PARAMETER_LIST', 'APEX_COLLECTION', 'DEFAULT', q'^p_#COLLECTION_NAME# => #COLUMN_TO_COLLECTION#^' from dual union all
       select 'BLOB', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)^' from dual union all
       select 'CHAR', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)^' from dual union all
       select 'CLOB', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)^' from dual union all
       select 'DATE', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')^' from dual union all
       select 'INTEGER', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))^' from dual union all
       select 'NUMBER', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))^' from dual union all
       select 'ROWID', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^rawtohex(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))^' from dual union all
       select 'TIMESTAMP', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')^' from dual union all
       select 'VARCHAR2', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^#COLUMN_NAME#^' from dual union all
       select 'XMLTYPE', 'APEX_COLLECTION', 'CONVERT_TO_COLLECTION', q'^xmltype(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))^' from dual union all
       select 'BLOB', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^#COLLECTION_NAME#^' from dual union all
       select 'CHAR', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^#COLLECTION_NAME#^' from dual union all
       select 'CLOB', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^#COLLECTION_NAME#^' from dual union all
       select 'DATE', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^to_date(#COLLECTION_NAME#, '#DATE_FORMAT#')^' from dual union all
       select 'INTEGER', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')^' from dual union all
       select 'NUMBER', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')^' from dual union all
       select 'ROWID', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^hextoraw(#COLLECTION_NAME#')^' from dual union all
       select 'TIMESTAMP', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^to_date(#COLLECTION_NAME#, '#TIMESTAMP_FORMAT#')^' from dual union all
       select 'VARCHAR2', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^#COLLECTION_NAME#^' from dual union all
       select 'XMLTYPE', 'APEX_COLLECTION', 'CONVERT_FROM_COLLECTION', q'^#COLLECTION_NAME#^' from dual union all
       select 'BLOB', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^to_blob(utl_apex.get(g_page_values, '#COLUMN_NAME#'))^' from dual union all
       select 'CHAR', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^utl_apex.get(g_page_values, '#COLUMN_NAME#')^' from dual union all
       select 'CLOB', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^utl_apex.get(g_page_values, '#COLUMN_NAME#')^' from dual union all
       select 'DATE', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^to_date(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#DATE_FORMAT#')^' from dual union all
       select 'INTEGER', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')^' from dual union all
       select 'NUMBER', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')^' from dual union all
       select 'ROWID', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^hextoraw(utl_apex.get(g_page_values, '#COLUMN_NAME#'))^' from dual union all
       select 'TIMESTAMP', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^to_timestamp(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#TIMESTAMP_FORMAT#')^' from dual union all
       select 'VARCHAR2', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^utl_apex.get(g_page_values, '#COLUMN_NAME#')^' from dual union all
       select 'XMLTYPE', 'APEX_COLLECTION', 'CONVERT_FROM_ITEM', q'^xmltype(utl_apex.get(g_page_values, '#COLUMN_NAME#'))^' from dual union all
       select 'BLOB', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^BLOB^' from dual union all
       select 'CHAR', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^C^' from dual union all
       select 'CLOB', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^CLOB^' from dual union all
       select 'DATE', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^D^' from dual union all
       select 'INTEGER', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^N^' from dual union all
       select 'NUMBER', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^N^' from dual union all
       select 'ROWID', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^C^' from dual union all
       select 'TIMESTAMP', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^D^' from dual union all
       select 'VARCHAR2', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^C^' from dual union all
       select 'XMLTYPE', 'APEX_COLLECTION', 'COLLECTION_DATA_TYPE', q'^XMLTYPE^' from dual union all
       select 'GRID_DATA_TYPE', 'APEX_IG', 'NUMBER', q'^  g_#STATIC_ID#_row.#COLUMN_NAME# := to_number(v('#COLUMN_NAME_UPPER#')#FORMAT_MASK|, '|'|#);^' from dual union all
       select 'GRID_DATA_TYPE', 'APEX_IG', 'DATE', q'^  g_#STATIC_ID#_row.#COLUMN_NAME# := to_date(v('#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');^' from dual union all
       select 'GRID_DATA_TYPE', 'APEX_IG', 'DEFAULT', q'^  g_#STATIC_ID#_row.#COLUMN_NAME# := v('#COLUMN_NAME_UPPER#');^' from dual union all
       select 'GRID_PROCEDURE', 'APEX_IG', 'DYNAMIC', q'^declare#CR#  g_#STATIC_ID#_row #TABLE_NAME#%rowtype;#CR#begin#CR##COLUMN_LIST##CR#  :x := g_row;#CR#end;^' from dual union all
       select 'GRID_PROCEDURE', 'APEX_IG', 'STATIC', q'^  g_#STATIC_ID#_row #TABLE_NAME#%rowtype;#CR##CR#begin#CR##COLUMN_LIST##CR#end;^' from dual union all
       select 'COLUMN', 'APEX_FORM', 'DATE', q'^g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_date(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');^' from dual union all
       select 'COLUMN', 'APEX_FORM', 'DEFAULT', q'^g_#PAGE_ALIAS#_row.#COLUMN_NAME# := utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#');^' from dual union all
       select 'COLUMN', 'APEX_FORM', 'NUMBER', q'^g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_number(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');^' from dual union all
       select 'METHODS', 'APEX_FORM', 'DEFAULT', q'^-- UI_PACKAGE-Body^' || chr(10) || 
q'^-- Globale Variablen^' || chr(10) || 
q'^  g_page_values utl_apex.page_value_t;^' || chr(10) || 
q'^  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^-- COPY_ROW-Methode^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^  /* Hilfsfunktion zur Uebernahme der Seitenelementwerte ^' || chr(10) || 
q'^   * %usage  Wird aufgerufen, um fuer die aktuell ausgefuehrte APEX-Seite den Sessionstatus^' || chr(10) || 
q'^   *         zu kopieren und in einer PL/SQL-Tabelle verfuegbar zu machen^' || chr(10) || 
q'^   */^' || chr(10) || 
q'^  procedure copy_#PAGE_ALIAS#^' || chr(10) || 
q'^  as^' || chr(10) || 
q'^  begin^' || chr(10) || 
q'^    g_page_values := utl_apex.get_page_values;^' || chr(10) || 
q'^    #COLUMN_LIST#^' || chr(10) || 
q'^  end copy_#PAGE_ALIAS#;^' || chr(10) || 
q'^    ^' || chr(10) || 
q'^-- METHOD IMPELEMENTATON^' || chr(10) || 
q'^^' || chr(10) || 
q'^  function validate_#PAGE_ALIAS#^' || chr(10) || 
q'^    return boolean^' || chr(10) || 
q'^  as^' || chr(10) || 
q'^  begin^' || chr(10) || 
q'^    -- copy_#PAGE_ALIAS#;^' || chr(10) || 
q'^    -- Validierungen. Falls keine Validierung, copy-Methode auskommentiert lassen^' || chr(10) || 
q'^    return true;^' || chr(10) || 
q'^  end validate_#PAGE_ALIAS#;^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^  procedure process_#PAGE_ALIAS#^' || chr(10) || 
q'^  as^' || chr(10) || 
q'^  begin^' || chr(10) || 
q'^    copy_#PAGE_ALIAS#;^' || chr(10) || 
q'^    case when utl_apex.inserting then^' || chr(10) || 
q'^      #INSERT_METHOD#(g_#PAGE_ALIAS#_row);^' || chr(10) || 
q'^    case when utl_apex.updating then^' || chr(10) || 
q'^      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);^' || chr(10) || 
q'^    else^' || chr(10) || 
q'^      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);^' || chr(10) || 
q'^    end case;^' || chr(10) || 
q'^  end process_#PAGE_ALIAS#;^' from dual union all
       select 'METHODS', 'APEX_FORM', 'MERGE', q'^-- UI_PACKAGE-Body^' || chr(10) || 
q'^-- Globale Variablen^' || chr(10) || 
q'^  g_page_values utl_apex.page_value_t;^' || chr(10) || 
q'^  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^-- COPY_ROW-Methode^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^  /* Hilfsfunktion zur Uebernahme der Seitenelementwerte ^' || chr(10) || 
q'^   * %usage  Wird aufgerufen, um fuer die aktuell ausgefuehrte APEX-Seite den Sessionstatus^' || chr(10) || 
q'^   *         zu kopieren und in einer PL/SQL-Tabelle verfuegbar zu machen^' || chr(10) || 
q'^   */^' || chr(10) || 
q'^  procedure copy_#PAGE_ALIAS#^' || chr(10) || 
q'^  as^' || chr(10) || 
q'^  begin^' || chr(10) || 
q'^    g_page_values := utl_apex.get_page_values;^' || chr(10) || 
q'^    #COLUMN_LIST#^' || chr(10) || 
q'^  end copy_#PAGE_ALIAS#;^' || chr(10) || 
q'^    ^' || chr(10) || 
q'^-- METHOD IMPELEMENTATON^' || chr(10) || 
q'^^' || chr(10) || 
q'^  function validate_#PAGE_ALIAS#^' || chr(10) || 
q'^    return boolean^' || chr(10) || 
q'^  as^' || chr(10) || 
q'^  begin^' || chr(10) || 
q'^    -- copy_#PAGE_ALIAS#;^' || chr(10) || 
q'^    -- Validierungen. Falls keine Validierung, copy-Methode auskommentiert lassen^' || chr(10) || 
q'^    return true;^' || chr(10) || 
q'^  end validate_#PAGE_ALIAS#;^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^  ^' || chr(10) || 
q'^  procedure process_#PAGE_ALIAS#^' || chr(10) || 
q'^  as^' || chr(10) || 
q'^  begin^' || chr(10) || 
q'^    copy_#PAGE_ALIAS#;^' || chr(10) || 
q'^    case when utl_apex.inserting or utl_apex.updating then^' || chr(10) || 
q'^      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);^' || chr(10) || 
q'^    else^' || chr(10) || 
q'^      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);^' || chr(10) || 
q'^    end case;^' || chr(10) || 
q'^  end process_#PAGE_ALIAS#;^' from dual union all
      select 'METHODS', 'TABLE_API', 'DEFAULT', 
q'^  -- SPEC^' || chr(10) ||
q'^  procedure delete_#SHORT_NAME#(^' || chr(10) ||
q'^    p_row #TABLE_NAME#%rowtype);^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  procedure merge_#SHORT_NAME#(^' || chr(10) ||
q'^    p_row #TABLE_NAME#%rowtype);^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  procedure merge_#SHORT_NAME#(^' || chr(10) ||
q'^    #PARAM_LIST#);^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  -- IMPLEMENTATION^' || chr(10) ||
q'^  procedure delete_#SHORT_NAME#(^' || chr(10) ||
q'^    p_row #TABLE_NAME#%rowtype)^' || chr(10) ||
q'^  as^' || chr(10) ||
q'^  begin^' || chr(10) ||
q'^    delete from #TABLE_NAME#^' || chr(10) ||
q'^     where #PK_LIST#;^' || chr(10) ||
q'^  end delete_#SHORT_NAME#;^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  procedure merge_#SHORT_NAME#(^' || chr(10) ||
q'^    p_row #TABLE_NAME#%rowtype)^' || chr(10) ||
q'^  as^' || chr(10) ||
q'^  begin^' || chr(10) ||
q'^    #MERGE_STMT#^' || chr(10) ||
q'^  end merge_#SHORT_NAME#;^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^  procedure merge_#SHORT_NAME#(^' || chr(10) ||
q'^    #PARAM_LIST#) ^' || chr(10) ||
q'^  as^' || chr(10) ||
q'^    l_row #TABLE_NAME#%rowtype;^' || chr(10) ||
q'^  begin^' || chr(10) ||
q'^    #RECORD_LIST#;^' || chr(10) ||
q'^    ^' || chr(10) ||
q'^    merge_#SHORT_NAME#(l_row);^' || chr(10) ||
q'^  end merge_#SHORT_NAME#;^' from dual union all 
       select 'COLUMN', 'TABLE_API', 'PARAM_LIST', q'^p_#COLUMN_NAME_RPAD# in #TABLE_NAME#.#COLUMN_NAME#%type^' from dual union all
       select 'COLUMN', 'TABLE_API', 'PK_LIST', q'^#COLUMN_NAME# = p_row.#COLUMN_NAME#^' from dual union all
       select 'COLUMN', 'TABLE_API', 'UPDATE_LIST', q'^t.#COLUMN_NAME# = s.#COLUMN_NAME#^' from dual union all
       select 'COLUMN', 'TABLE_API', 'RECORD_LIST', q'^l_row.#COLUMN_NAME# := p_#COLUMN_NAME#^' from dual union all
       select 'COLUMN', 'TABLE_API', 'USING_LIST', q'^p_row.#COLUMN_NAME# #COLUMN_NAME#^' from dual union all
       select 'COLUMN', 'TABLE_API', 'ON_LIST', q'^t.#COLUMN_NAME# = s.#COLUMN_NAME#^' from dual union all
       select 'COLUMN', 'TABLE_API', 'INSERT_LIST', q'^s.#COLUMN_NAME#^' from dual union all
       select 'COLUMN', 'TABLE_API', 'COL_LIST', q'^t.#COLUMN_NAME#^' from dual union all
       select 'MERGE', 'TABLE_API', 'DEFAULT', q'^merge into #TABLE_NAME# t^' || chr(10) ||
q'^    using (select #USING_LIST#^' || chr(10) ||
q'^             from dual) s^' || chr(10) ||
q'^       on (#ON_LIST#)^' || chr(10) ||
q'^     when matched then update set^' || chr(10) ||
q'^            #UPDATE_LIST#^' || chr(10) ||
q'^     when not matched then insert(^' || chr(10) ||
q'^            #COL_LIST#)^' || chr(10) ||
q'^          values(^' || chr(10) ||
q'^            #INSERT_LIST#);^' from dual
      ) s
   on (t.cgtm_name = s.cgtm_name and t.cgtm_type = s.cgtm_type and t.cgtm_mode = s.cgtm_mode)
 when matched then update set
      t.cgtm_text = s.cgtm_text
 when not matched then insert (cgtm_name, cgtm_type, cgtm_mode, cgtm_text)
      values (s.cgtm_name, s.cgtm_type, s.cgtm_mode, s.cgtm_text);
      
commit;

