set define off
set sqlprefix off

begin
  utl_text_admin.merge_template(
    p_uttm_name => 'COLUMN_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{#COLUMN_FROM_COLLECTION# #COLUMN_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'COPY_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{l_row.#COLUMN_NAME# := #CONVERT_FROM_ITEM#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VIEW',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{create or replace force view #VIEW_NAME# as\CR\}' || 
q'{select seq_id,\CR\}' || 
q'{       #COLUMN_LIST#\CR\}' || 
q'{  from apex_collections\CR\}' || 
q'{ where collection_name = '#VIEW_NAME#'\CR\}' || 
q'{}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'PACKAGE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{create or replace package #APP_ALIAS#_ui_#PAGE_ALIAS#\CR\}' || 
q'{  authid definer\CR\}' || 
q'{as\CR\}' || 
q'{\CR\}' || 
q'{  /**\CR\}' || 
q'{    Function: validate_#FORM_ID#\CR\}' || 
q'{      Method to validate page #FORM_ID#\CR\}' || 
q'{    \CR\}' || 
q'{    Returns: Always true, exceptions are integrated into the APEX exception stack\CR\}' || 
q'{   */\CR\}' || 
q'{  function validate_#FORM_ID#\CR\}' || 
q'{    return boolean;\CR\}' || 
q'{    \CR\}' || 
q'{  /**\CR\}' || 
q'{    Procedure: process_#FORM_ID#\CR\}' || 
q'{      Persists entered data into APEX collection #COLLECTION_NAME#\CR\}' || 
q'{   */\CR\}' || 
q'{  procedure process_#FORM_ID#;\CR\}' || 
q'{\CR\}' || 
q'{end #APP_ALIAS#_ui_#PAGE_ALIAS#;\CR\}' || 
q'{/\CR\}' || 
q'{\CR\}' || 
q'{create or replace package body #APP_ALIAS#_ui_#PAGE_ALIAS#\CR\}' || 
q'{as\CR\}' || 
q'{  C_YES constant varchar2(10 byte) := 'YES';\CR\}' || 
q'{  C_NO constant varchar2(10 byte) := 'NO';\CR\}' || 
q'{\CR\}' || 
q'{  function copy_#FORM_ID#\CR\}' || 
q'{    return #VIEW_NAME#%rowtype\CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_optional('copy_#FORM_ID#');\CR\}' || 
q'{\CR\}' || 
q'{    #COPY_LIST#;\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_optional;\CR\}' || 
q'{    return l_row;\CR\}' || 
q'{  end copy_#FORM_ID#;\CR\}' || 
q'{  \CR\}' || 
q'{  \CR\}' || 
q'{  function validate_#FORM_ID#\CR\}' || 
q'{    return boolean\CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    -- l_row := copy_#FORM_ID#;\CR\}' || 
q'{    -- TODO: validation logic goes here. If it exists, uncomment COPY function\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{    return true;\CR\}' || 
q'{  end validate_#FORM_ID#;\CR\}' || 
q'{  \CR\}' || 
q'{    \CR\}' || 
q'{  procedure process_#FORM_ID#\CR\}' || 
q'{  as\CR\}' || 
q'{    C_COLLECTION_NAME constant varchar2(30 byte) := '#COLLECTION_NAME#';\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    l_row := copy_#FORM_ID#;  \CR\}' || 
q'{    case\CR\}' || 
q'{    when utl_apex.INSERTING then\CR\}' || 
q'{      apex_collection.add_member(\CR\}' || 
q'{        p_collection_name => C_COLLECTION_NAME,\CR\}' || 
q'{        #PARAM_LIST#,\CR\}' || 
q'{        p_generate_md5 => C_YES);\CR\}' || 
q'{    when utl_apex.UPDATING then\CR\}' || 
q'{      apex_collection.update_member(\CR\}' || 
q'{        p_seq => l_row.seq_id,\CR\}' || 
q'{        p_collection_name => C_COLLECTION_NAME,\CR\}' || 
q'{        #PARAM_LIST#,\CR\}' || 
q'{        p_c050 => apex_collection.get_member_md5(C_COLLECTION_NAME, l_row.seq_id));\CR\}' || 
q'{    when utl_apex.DELETING then\CR\}' || 
q'{      apex_collection.delete_member(\CR\}' || 
q'{        p_seq => l_row.seq_id,\CR\}' || 
q'{        p_collection_name => C_COLLECTION_NAME);\CR\}' || 
q'{    else\CR\}' || 
q'{      null;\CR\}' || 
q'{    end case;\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end process_#FORM_ID#;\CR\}' || 
q'{\CR\}' || 
q'{end #APP_ALIAS#_ui_#PAGE_ALIAS#;\CR\}' || 
q'{/}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'PARAMETER_LIST',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{p_#COLLECTION_NAME# => #COLUMN_TO_COLLECTION#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{utl_apex.get(l_row, #COLUMN_NAME#)}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{utl_apex.get(l_row, #COLUMN_NAME#)}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{utl_apex.get(l_row, #COLUMN_NAME#)}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(l_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(l_row, #COLUMN_NAME#))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(l_row, #COLUMN_NAME#))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{rawtohex(utl_apex.get(l_row, #COLUMN_NAME#))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{to_char(utl_apex.get(l_row, #COLUMN_NAME#), 'yyyy-mm-dd hh24:mi:ss')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{#COLUMN_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_TO_COLLECTION',
    p_uttm_text => q'{xmltype(utl_apex.get(l_row, #COLUMN_NAME#))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_date(#COLLECTION_NAME#, '#DATE_FORMAT#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_number(#COLLECTION_NAME#, '#NUMBER_FORMAT#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{hextoraw(#COLLECTION_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{to_date(#COLLECTION_NAME#, '#TIMESTAMP_FORMAT#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_COLLECTION',
    p_uttm_text => q'{#COLLECTION_NAME#}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{to_blob(utl_apex.get_string('#COLUMN_NAME#'))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_string('#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_string('#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_date('#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_number('#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_number('#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{hextoraw(utl_apex.get_string('#COLUMN_NAME#'))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_timestamp'#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{utl_apex.get_string('#COLUMN_NAME#')}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'CONVERT_FROM_ITEM',
    p_uttm_text => q'{xmltype(utl_apex.get_string('#COLUMN_NAME#'))}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'BLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{BLOB}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CHAR',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{C}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'CLOB',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{CLOB}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'DATE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{D}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'INTEGER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{N}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'NUMBER',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{N}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'ROWID',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{C}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'TIMESTAMP',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{D}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VARCHAR2',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{C}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'XMLTYPE',
    p_uttm_type => 'APEX_COLLECTION',
    p_uttm_mode => 'COLLECTION_DATA_TYPE',
    p_uttm_text => q'{XMLTYPE}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on
set sqlprefix on