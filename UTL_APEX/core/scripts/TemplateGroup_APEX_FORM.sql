set define off

begin
  utl_text_admin.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'MERGE',
    p_uttm_text => q'{-- UI_PACKAGE-Body\CR\}' || 
q'{-- SPEC\CR\}' || 
q'{  /** Methods to maintain page #PAGE_ALIAS#\CR\}' || 
q'{   */\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean;\CR\}' || 
q'{\CR\}' || 
q'{  procedure process_#PAGE_ALIAS#;\CR\}' || 
q'{\CR\}' || 
q'{-- BODY\CR\}' || 
q'{-- COPY_ROW method\CR\}' || 
q'{  \CR\}' || 
q'{  /* Helper method to copy session state values from an APEX page \CR\}' || 
q'{   * %usage  Is called to copy the actual session state of an APEX page into a PL/SQL table\CR\}' || 
q'{   */\CR\}' || 
q'{  procedure copy_#PAGE_ALIAS#(\CR\}' || 
q'{    p_row out nocopy #VIEW_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_detailed('copy_#PAGE_ALIAS#');\CR\}' || 
q'{  \CR\}' || 
q'{    #COLUMN_LIST#\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_detailed;\CR\}' || 
q'{    return l_row;\CR\}' || 
q'{  end copy_#PAGE_ALIAS#;\CR\}' || 
q'{    \CR\}' || 
q'{-- METHOD IMPLEMENTATIONS\CR\}' || 
q'{\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean\CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{  \CR\}' || 
q'{    copy_#PAGE_ALIAS#(l_row);\CR\}' || 
q'{    \CR\}' || 
q'{    pit.start_message_collection;\CR\}' || 
q'{    #CHECK_METHOD#(l_row);\CR\}' || 
q'{    pit.stop_message_collection;\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  exception\CR\}' || 
q'{    when msg.PIT_BULK_ERROR_ERR or msg.PIT_BULK_FATAL_ERR then\CR\}' || 
q'{      utl_apex.handle_bulk_error(char_table(\CR\}' || 
q'{        'ERROR_CODE', 'ASSIGNED_ITEM'));\CR\}' || 
q'{      return true;\CR\}' || 
q'{  end validate_#PAGE_ALIAS#;\CR\}' || 
q'{  \CR\}' || 
q'{  \CR\}' || 
q'{  procedure process_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{    \CR\}' || 
q'{    copy_#PAGE_ALIAS#(l_row);\CR\}' || 
q'{    case when utl_apex.inserting or utl_apex.updating then\CR\}' || 
q'{      #UPDATE_METHOD#(l_row);\CR\}' || 
q'{    else\CR\}' || 
q'{      #DELETE_METHOD#(l_row);\CR\}' || 
q'{    end case;\CR\}' || 
q'{    \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end process_#PAGE_ALIAS#;\CR\}' || 
q'{}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VIEW_TO_TABLE',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{  procedure copy_row_to_#TABLE_SHORTCUT#_record(\CR\}' || 
q'{    p_row in #VIEW_NAME#%rowtype,\CR\}' || 
q'{    p_rec out nocopy #TABLE_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{#COLUMN_LIST#}' || 
q'{  end copy_row_to_#TABLE_SHORTCUT#_record;\CR\}' || 
q'{}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'VIEW_TO_TABLE',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'COLUMN',
    p_uttm_text => q'{    p_rec.#COLUMN_NAME# := p_row.#COLUMN_NAME#;\CR\}' || 
q'{}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'FORM_COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'NUMBER',
    p_uttm_text => q'{  #RECORD_NAME#.#COLUMN_NAME# := utl_apex.get_number('#SOURCE_NAME#');}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'FORM_COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DATE',
    p_uttm_text => q'{  #RECORD_NAME#.#COLUMN_NAME# := utl_apex.get_date('#SOURCE_NAME#');}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'FORM_COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{  #RECORD_NAME#.#COLUMN_NAME# := utl_apex.get_string('#SOURCE_NAME#');}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'FORM_FRAME',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DYNAMIC',
    p_uttm_text => q'{declare\CR\}' || 
q'{  #RECORD_NAME# #TABLE_NAME#%rowtype;\CR\}' || 
q'{begin\CR\}' || 
q'{#COLUMN_LIST#\CR\}' || 
q'{  :x := #RECORD_NAME#;\CR\}' || 
q'{end;}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'FORM_FRAME',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'STATIC',
    p_uttm_text => q'{  #RECORD_NAME# #TABLE_NAME#%rowtype;\CR\}' || 
q'{\CR\}' || 
q'{begin\CR\}' || 
q'{#COLUMN_LIST#\CR\}' || 
q'{end;}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DATE',
    p_uttm_text => q'{p_row.#COLUMN_NAME# := utl_apex.get_date('#COLUMN_NAME_LOWER#');}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{p_row.#COLUMN_NAME# := utl_apex.get_string('#COLUMN_NAME_LOWER#');}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'NUMBER',
    p_uttm_text => q'{p_row.#COLUMN_NAME# := utl_apex.get_number('#COLUMN_NAME_LOWER#');}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{-- UI_PACKAGE-Body\CR\}' || 
q'{-- SPEC\CR\}' || 
q'{  /** Methods to maintain page #PAGE_ALIAS#\CR\}' || 
q'{   */\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean;\CR\}' || 
q'{\CR\}' || 
q'{  procedure process_#PAGE_ALIAS#;\CR\}' || 
q'{\CR\}' || 
q'{-- BODY  \CR\}' || 
q'{-- COPY_ROW method\CR\}' || 
q'{  \CR\}' || 
q'{  /* Helper method to copy session state values from an APEX page \CR\}' || 
q'{   * %usage  Is called to copy the actual session state of an APEX page into a type save record\CR\}' || 
q'{   */\CR\}' || 
q'{  procedure copy_#PAGE_ALIAS#(\CR\}' || 
q'{    p_row out nocopy #VIEW_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_detailed('copy_#PAGE_ALIAS#');\CR\}' || 
q'{  \CR\}' || 
q'{    #COLUMN_LIST#\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_detailed;\CR\}' || 
q'{  end copy_#PAGE_ALIAS#;\CR\}' || 
q'{    \CR\}' || 
q'{-- METHOD IMPELEMENTATON\CR\}' || 
q'{\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean\CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{  \CR\}' || 
q'{    copy_#PAGE_ALIAS#(l_row);\CR\}' || 
q'{    \CR\}' || 
q'{    pit.start_message_collection;\CR\}' || 
q'{    #CHECK_METHOD#(l_row);\CR\}' || 
q'{    pit.stop_message_collection;\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{    return true;\CR\}' || 
q'{  exception\CR\}' || 
q'{    when msg.PIT_BULK_ERROR_ERR or msg.PIT_BULK_FATAL_ERR then\CR\}' || 
q'{      utl_apex.handle_bulk_error(char_table(\CR\}' || 
q'{        'ERROR_CODE', 'ASSIGNED_ITEM'));\CR\}' || 
q'{      return true;\CR\}' || 
q'{  end validate_#PAGE_ALIAS#;\CR\}' || 
q'{  \CR\}' || 
q'{  \CR\}' || 
q'{  procedure process_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{  \CR\}' || 
q'{    copy_#PAGE_ALIAS#(l_row);\CR\}' || 
q'{    case when utl_apex.inserting then\CR\}' || 
q'{      #INSERT_METHOD#(l_row);\CR\}' || 
q'{    case when utl_apex.updating then\CR\}' || 
q'{      #UPDATE_METHOD#(l_row);\CR\}' || 
q'{    else\CR\}' || 
q'{      #DELETE_METHOD#(l_row);\CR\}' || 
q'{    end case;\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end process_#PAGE_ALIAS#;}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on