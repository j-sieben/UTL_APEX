set define off
set sqlprefix off

begin
  utl_text.merge_template(
    p_uttm_name => 'METHODS',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{  -- SPEC\CR\}' || 
q'{  procedure check_#SHORT_NAME#(\CR\}' || 
q'{    p_row in #TABLE_NAME#%rowtype);\CR\}' || 
q'{\CR\}' || 
q'{  procedure delete_#SHORT_NAME#(\CR\}' || 
q'{    p_row in #TABLE_NAME#%rowtype);\CR\}' || 
q'{    \CR\}' || 
q'{  procedure merge_#SHORT_NAME#(\CR\}' || 
q'{    p_row in out nocopy #TABLE_NAME#%rowtype);\CR\}' || 
q'{    \CR\}' || 
q'{  procedure merge_#SHORT_NAME#(\CR\}' || 
q'{    #PARAM_LIST#);\CR\}' || 
q'{    \CR\}' || 
q'{  -- IMPLEMENTATION\CR\}' || 
q'{  procedure check_#SHORT_NAME#(\CR\}' || 
q'{    p_row in #TABLE_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    -- TODO: Add tests here\CR\}' || 
q'{    null;\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end check_#SHORT_NAME#;\CR\}' || 
q'{\CR\}' || 
q'{\CR\}' || 
q'{  procedure delete_#SHORT_NAME#(\CR\}' || 
q'{    p_row in #TABLE_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    delete from #TABLE_NAME#\CR\}' || 
q'{     where #PK_LIST#;\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end delete_#SHORT_NAME#;\CR\}' || 
q'{\CR\}' || 
q'{    \CR\}' || 
q'{  procedure merge_#SHORT_NAME#(\CR\}' || 
q'{    p_row in out nocopy #TABLE_NAME#%rowtype)\CR\}' || 
q'{  as\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    #MERGE_STMT#\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end merge_#SHORT_NAME#;\CR\}' || 
q'{    \CR\}' || 
q'{  procedure merge_#SHORT_NAME#(\CR\}' || 
q'{    #PARAM_LIST#) \CR\}' || 
q'{  as\CR\}' || 
q'{    l_row #TABLE_NAME#%rowtype;\CR\}' || 
q'{  begin\CR\}' || 
q'{    pit.enter_mandatory;\CR\}' || 
q'{\CR\}' || 
q'{    #RECORD_LIST#;\CR\}' || 
q'{    \CR\}' || 
q'{    merge_#SHORT_NAME#(l_row);\CR\}' || 
q'{\CR\}' || 
q'{    pit.leave_mandatory;\CR\}' || 
q'{  end merge_#SHORT_NAME#;}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'PARAM_LIST',
    p_uttm_text => q'{p_#COLUMN_NAME_RPAD# in #TABLE_NAME#.#COLUMN_NAME#%type}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'PK_LIST',
    p_uttm_text => q'{#COLUMN_NAME# = p_row.#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'UPDATE_LIST',
    p_uttm_text => q'{t.#COLUMN_NAME# = s.#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'RECORD_LIST',
    p_uttm_text => q'{l_row.#COLUMN_NAME# := p_#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'USING_LIST',
    p_uttm_text => q'{p_row.#COLUMN_NAME# #COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'ON_LIST',
    p_uttm_text => q'{t.#COLUMN_NAME# = s.#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'INSERT_LIST',
    p_uttm_text => q'{s.#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'COL_LIST',
    p_uttm_text => q'{t.#COLUMN_NAME#}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'MERGE',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'DEFAULT',
    p_uttm_text => q'{merge into #TABLE_NAME# t\CR\}' || 
q'{    using (select #USING_LIST#\CR\}' || 
q'{             from dual) s\CR\}' || 
q'{       on (#ON_LIST#)\CR\}' || 
q'{     when matched then update set\CR\}' || 
q'{            #UPDATE_LIST#\CR\}' || 
q'{     when not matched then insert(\CR\}' || 
q'{            #COL_LIST#)\CR\}' || 
q'{          values(\CR\}' || 
q'{            #INSERT_LIST#);}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );

  utl_text.merge_template(
    p_uttm_name => 'COLUMN',
    p_uttm_type => 'TABLE_API',
    p_uttm_mode => 'PIT_LIST',
    p_uttm_text => q'{msg_param('p_#COLUMN_NAME#', p_#COLUMN_NAME#)}',
    p_uttm_log_text => null,
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on
set sqlprefix on