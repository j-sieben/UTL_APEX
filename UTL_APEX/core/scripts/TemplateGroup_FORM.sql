set define off
set sqlprefix off

begin
  utl_text.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{-- UI_PACKAGE-Body\CR\}' || 
q'{-- global variables\CR\}' || 
q'{  g_page_values utl_apex.page_value_t;\CR\}' || 
q'{  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  \CR\}' || 
q'{-- COPY_ROW method\CR\}' || 
q'{  \CR\}' || 
q'{  /* Helper method to copy session state values from an APEX page \CR\}' || 
q'{   * %usage  Is called to copy the actual session state of an APEX page into a PL/SQL table\CR\}' || 
q'{   */\CR\}' || 
q'{  procedure copy_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    g_page_values := utl_apex.get_page_values#STATIC_ID|('|')|#;\CR\}' || 
q'{    #COLUMN_LIST#\CR\}' || 
q'{  end copy_#PAGE_ALIAS#;\CR\}' || 
q'{    \CR\}' || 
q'{-- METHOD IMPELEMENTATON\CR\}' || 
q'{\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{  \CR\}' || 
q'{    -- copy_#PAGE_ALIAS#;\CR\}' || 
q'{    -- validation logic goes here. If it exists, uncomment COPY function\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{    return true;\CR\}' || 
q'{  end validate_#PAGE_ALIAS#;\CR\}' || 
q'{  \CR\}' || 
q'{  \CR\}' || 
q'{  procedure process_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{  \CR\}' || 
q'{    copy_#PAGE_ALIAS#;\CR\}' || 
q'{    case when utl_apex.inserting then\CR\}' || 
q'{      #INSERT_METHOD#(g_#PAGE_ALIAS#_row);\CR\}' || 
q'{    case when utl_apex.updating then\CR\}' || 
q'{      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);\CR\}' || 
q'{    else\CR\}' || 
q'{      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);\CR\}' || 
q'{    end case;\CR\}' || 
q'{  \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end process_#PAGE_ALIAS#;}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'MERGE',
    p_uttm_text => q'{-- UI_PACKAGE-Body\CR\}' || 
q'{-- Global Variables\CR\}' || 
q'{  g_page_values utl_apex.page_value_t;\CR\}' || 
q'{  g_#PAGE_ALIAS#_row #VIEW_NAME#%rowtype;\CR\}' || 
q'{  \CR\}' || 
q'{-- COPY_ROW method\CR\}' || 
q'{  \CR\}' || 
q'{  /* Helper method to copy session state values from an APEX page \CR\}' || 
q'{   * %usage  Is called to copy the actual session state of an APEX page into a PL/SQL table\CR\}' || 
q'{   */\CR\}' || 
q'{  procedure copy_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    g_page_values := utl_apex.get_page_values#STATIC_ID|('|')|#;\CR\}' || 
q'{    #COLUMN_LIST#\CR\}' || 
q'{  end copy_#PAGE_ALIAS#;\CR\}' || 
q'{    \CR\}' || 
q'{-- METHOD IMPLEMENTATIONS\CR\}' || 
q'{\CR\}' || 
q'{  function validate_#PAGE_ALIAS#\CR\}' || 
q'{    return boolean\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{    \CR\}' || 
q'{    -- copy_#PAGE_ALIAS#;\CR\}' || 
q'{    -- validation logic goes here. If it exists, uncomment COPY function\CR\}' || 
q'{    \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{    return true;\CR\}' || 
q'{  end validate_#PAGE_ALIAS#;\CR\}' || 
q'{  \CR\}' || 
q'{  \CR\}' || 
q'{  procedure process_#PAGE_ALIAS#\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{    \CR\}' || 
q'{    copy_#PAGE_ALIAS#;\CR\}' || 
q'{    case when utl_apex.inserting or utl_apex.updating then\CR\}' || 
q'{      #UPDATE_METHOD#(g_#PAGE_ALIAS#_row);\CR\}' || 
q'{    else\CR\}' || 
q'{      #DELETE_METHOD#(g_#PAGE_ALIAS#_row);\CR\}' || 
q'{    end case;\CR\}' || 
q'{    \CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end process_#PAGE_ALIAS#;}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VIEW_TO_TABLE',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{  procedure copy_row_to_#TABLE_SHORTCUT#_record(\CR\}' || 
q'{    p_row in #VIEW_NAME#%rowtype,\CR\}' || 
q'{    p_rec out nocopy #TABLE_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{#COLUMN_LIST#  end copy_row_to_#TABLE_SHORTCUT#_record;\CR\}' || 
q'{}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'VIEW_TO_TABLE',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'COLUMN',
    p_uttm_text => q'{    p_rec.#COLUMN_NAME# := p_row.#COLUMN_NAME#;\CR\}' || 
q'{}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'FORM_COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'NUMBER',
    p_uttm_text => q'{  #RECORD_NAME#.#COLUMN_NAME# := to_number(v('#SOURCE_NAME#')#FORMAT_MASK|, '|'|#);}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'FORM_COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DATE',
    p_uttm_text => q'{  #RECORD_NAME#.#COLUMN_NAME# := to_date(v('#SOURCE_NAME#'), '#FORMAT_MASK#');}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'FORM_COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{  #RECORD_NAME#.#COLUMN_NAME# := v('#SOURCE_NAME#');}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'FORM_FRAME',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DYNAMIC',
    p_uttm_text => q'{declare\CR\}' || 
q'{  #RECORD_NAME# #TABLE_NAME#%rowtype;\CR\}' || 
q'{begin\CR\}' || 
q'{#COLUMN_LIST#\CR\}' || 
q'{  :x := #RECORD_NAME#;\CR\}' || 
q'{end;}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'FORM_FRAME',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'STATIC',
    p_uttm_text => q'{  #RECORD_NAME# #TABLE_NAME#%rowtype;\CR\}' || 
q'{\CR\}' || 
q'{begin\CR\}' || 
q'{#COLUMN_LIST#\CR\}' || 
q'{end;}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DATE',
    p_uttm_text => q'{g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_date(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{g_#PAGE_ALIAS#_row.#COLUMN_NAME# := utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#');}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'APEX_FORM',
    p_uttm_mode => 'NUMBER',
    p_uttm_text => q'{g_#PAGE_ALIAS#_row.#COLUMN_NAME# := to_number(utl_apex.get(g_page_values, '#COLUMN_NAME_UPPER#'), '#FORMAT_MASK#');}',
    p_uttm_log_text => ,
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on
set sqlprefix on