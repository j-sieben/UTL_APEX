set define off
set sqlprefix off

begin
  utl_text.merge_template(
    p_uttm_name => 'COLUMN_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{#COLUMN_FROM_COLLECTION# #COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COPY_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{g_#PAGE_ALIAS#_row.#COLUMN_NAME# := #CONVERT_FROM_ITEM#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VIEW',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{create or replace force view #VIEW_NAME# as\CR\}' || 
q'{select seq_id,\CR\}' || 
q'{       #COLUMN_LIST#\CR\}' || 
q'{  from apex_collections\CR\}' || 
q'{ where collection_name = '#VIEW_NAME#'\CR\}' || 
q'{}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'PACKAGE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{create or replace package #PAGE_ALIAS#_ui\CR\}' || 
q'{  authid definer\CR\}' || 
q'{as\CR\}' || 
q'{\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean;\CR\}' || 
q'{    \CR\}' || 
q'{  procedure process_#PAGE_ALIAS#;\CR\}' || 
q'{\CR\}' || 
q'{end #PAGE_ALIAS#_ui;\CR\}' || 
q'{/\CR\}' || 
q'{\CR\}' || 
q'{create or replace package body #PAGE_ALIAS#_ui\CR\}' || 
q'{as\CR\}' || 
q'{\CR\}' || 
q'{  \CR\}' || 
q'{  g_page_values utl_apex.page_value_t;\CR\}' || 
q'{  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  \CR\}' || 
q'{  procedure copy_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    g_page_values := utl_apex.get_page_values;\CR\}' || 
q'{    #COPY_LIST#;\CR\}' || 
q'{  end copy_#PAGE_ALIAS#;\CR\}' || 
q'{  \CR\}' || 
q'{  \CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    -- copy_#PAGE_ALIAS#;\CR\}' || 
q'{    -- TODO: validation logic goes here. If it exists, uncomment COPY function\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{    return true;\CR\}' || 
q'{  end validate_#PAGE_ALIAS#;\CR\}' || 
q'{  \CR\}' || 
q'{    \CR\}' || 
q'{  procedure process_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{    c_collection_name constant varchar2(30 byte) := '#COLLECTION_NAME#';\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    copy_#PAGE_ALIAS#;  \CR\}' || 
q'{    case\CR\}' || 
q'{    when utl_apex.INSERTING then\CR\}' || 
q'{      apex_collection.add_member(\CR\}' || 
q'{        p_collection_name => c_collection_name,\CR\}' || 
q'{        #PARAM_LIST#,\CR\}' || 
q'{        p_generate_md5 => c_no);\CR\}' || 
q'{    when utl_apex.UPDATING then\CR\}' || 
q'{      apex_collection.update_member(\CR\}' || 
q'{        p_seq => g_#PAGE_ALIAS#_row.seq_id,\CR\}' || 
q'{        p_collection_name => c_collection_name,\CR\}' || 
q'{        #PARAM_LIST#);\CR\}' || 
q'{    when utl_apex.DELETING then\CR\}' || 
q'{      apex_collection.delete_member(\CR\}' || 
q'{        p_seq => g_#PAGE_ALIAS#_row.seq_id,\CR\}' || 
q'{        p_collection_name => c_collection_name);\CR\}' || 
q'{    else\CR\}' || 
q'{      null;\CR\}' || 
q'{    end case;\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end process_#PAGE_ALIAS#;\CR\}' || 
q'{\CR\}' || 
q'{end #PAGE_ALIAS#_ui;\CR\}' || 
q'{/}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'PARAMETER_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{p_#COLLECTION_NAME# => #COLUMN_TO_COLLECTION#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#)}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{rawtohex(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{xmltype(utl_apex.get(g_#PAGE_ALIAS#_row, #COLUMN_NAME#))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_date(#COLLECTION_NAME#, '#DATE_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{hextoraw(#COLLECTION_NAME#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_date(#COLLECTION_NAME#, '#TIMESTAMP_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{to_blob(utl_apex.get(g_page_values, '#COLUMN_NAME#'))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get(g_page_values, '#COLUMN_NAME#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get(g_page_values, '#COLUMN_NAME#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{to_date(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#DATE_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{to_number(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#NUMBER_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{hextoraw(utl_apex.get(g_page_values, '#COLUMN_NAME#'))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{to_timestamp(utl_apex.get(g_page_values, '#COLUMN_NAME#'), '#TIMESTAMP_FORMAT#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get(g_page_values, '#COLUMN_NAME#')}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{xmltype(utl_apex.get(g_page_values, '#COLUMN_NAME#'))}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{BLOB}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{C}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{CLOB}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{D}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{N}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{N}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{C}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{D}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{C}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{XMLTYPE}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on
set sqlprefix on