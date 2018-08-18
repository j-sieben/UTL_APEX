create or replace package body utl_apex
as

  -- Private type declarations
  -- Private constant declarations
  C_PKG constant ora_name_type := $$PLSQL_UNIT;
  C_APEX_SCHEMA constant ora_name_type := $$PLSQL_UNIT_OWNER;
  C_PIT_APEX_MODULE constant ora_name_type := 'PIT_APEX';

  -- HELPER
  function get_page_element(
    p_affected_id in ora_name_type)
    return varchar2
  as
    l_element ora_name_type;
  begin
    l_element := p_affected_id;
    if not regexp_like(l_element, '^P[0-9]+_') then
      l_element := get_page || l_element;
    end if;
    return l_element;
  end get_page_element;
  
  
  -- INTERFACE
  function user_is_authorized(
    p_authorization_scheme in varchar2)
    return integer
  as
    l_result binary_integer;
  begin
    if apex_authorization.is_authorized(p_authorization_scheme) then
      l_result := c_true;
    else
      l_result := C_FALSE;
    end if;
    return l_result;
  end user_is_authorized;
  
  
  procedure create_apex_session(
    p_apex_user in apex_workspace_activity_log.apex_user%type,
    p_application_id in apex_applications.application_id%type,
    p_page_id in apex_application_pages.page_id%type default 1)
  as
    l_workspace_id apex_applications.workspace_id%type;
    l_param_name owa.vc_arr;
    l_param_val owa.vc_arr;
  begin
    pit.enter_mandatory(C_PKG, 'create_apex_session', msg_params(
      msg_param('p_apex_user', p_apex_user),
      msg_param('p_application_id', to_char(p_application_id)),
      msg_param('p_page_id', to_char(p_page_id))));
      
    htp.init;
    l_param_name(1) := 'REQUEST_PROTOCOL';
    l_param_val(1) := 'HTTP';
  
    owa.init_cgi_env(
      num_params => 1,
      param_name => l_param_name,
      param_val =>l_param_val);
  
    select workspace_id
      into l_workspace_id
      from apex_applications
     where application_id = p_application_id;
  
    wwv_flow_api.set_security_group_id(l_workspace_id);
  
    apex_application.g_instance := 1;
    apex_application.g_flow_id := p_application_id;
    apex_application.g_flow_step_id := p_page_id;
  
    apex_custom_auth.post_login(
      p_uname => p_apex_user,
      p_session_id => apex_custom_auth.get_next_session_id,
      p_app_page => apex_application.g_flow_id || ':' || p_page_id);
      
    pit.leave_mandatory;
  end create_apex_session;


  function get_page_values
    return page_value_t
  as
    cursor page_item_cur(
      p_application_id in number,
      p_page_id in number) is
      select substr(item_name, instr(item_name, '_') + 1) item_name, apex_util.get_session_state(item_name) item_value
        from apex_application_page_items
       where application_id = p_application_id
         and page_id = p_page_id;
    page_values page_value_t;
  begin
    pit.enter_optional(C_PKG, 'get_page_values');
    
    for itm in page_item_cur(v('APP_ID'), v('APP_PAGE_ID')) loop
      page_values(itm.item_name) := itm.item_value;
    end loop;
    
    pit.leave_optional;
    return page_values;
  end get_page_values;


  function get_ig_values(
    p_target_table in ora_name_type,
    p_static_id in ora_name_type,
    p_application_id in binary_integer default null,
    p_page_id in binary_integer default null)
    return varchar2
  as
  $IF utl_apex.ver_le_0500 $THEN
  begin
    return 'APEX version does not support Interactive Grids. Minimum is 5.1';
  $ELSE
    l_result varchar2(32767);
  begin
    select code_generator.generate_text(
             cursor(
               select cgtm_text template,
                      chr(10) cr,
                      lower(p_target_table) table_name,
                      lower(p_static_id) static_id,
                      code_generator.generate_text(cursor(
                          with params as(
                               select coalesce(p_application_id, to_number(v('APP_ID'))) app_id,
                                      coalesce(p_page_id, to_number(v('APP_PAGE_ID'))) page_id,
                                      lower(p_static_id) static_id
                                 from dual)
                        select /*+ NO_MERGE (p) */
                               cgtm_text template,
                               lower(name) column_name,
                               name column_name_upper,
                               case data_type
                               when 'DATE' then coalesce(format_mask, a.date_format)
                               when 'NUMBER' then format_mask
                               else null end format_mask
                          from apex_appl_page_ig_columns ig
                          join params p
                            on ig.application_id = p.app_id
                           and ig.page_id = p.page_id
                          join apex_application_page_regions r
                            on ig.region_id = r.region_id
                          join apex_applications a
                            on r.application_id = a.application_id
                          join code_generator_templates t
                            on case when data_type in ('NUMBER', 'DATE') then data_type else 'DEFAULT' end = cgtm_mode
                         where ig.source_type_code = 'DB_COLUMN'
                           and t.cgtm_name = 'GRID_DATA_TYPE'
                           and t.cgtm_type = 'APEX_IG')) column_list
                 from code_generator_templates
                where cgtm_name = 'GRID_PROCEDURE'
                  and cgtm_type = 'APEX_IG'
                  and cgtm_mode = case when p_application_id is null then 'DYNAMIC' else 'STATIC' end)) resultat
      into l_result
      from dual;
    return l_result;
  $END
  end get_ig_values;
  
  
  function get(
    p_page_values in page_value_t,
    p_element_name in ora_name_type)
    return varchar2
  as
  begin
    return p_page_values(p_element_name);
  exception
    when no_data_found then
      pit.fatal(msg.UTL_APEX_MISSING_ITEM, msg_args(p_element_name, v('APP_PAGE_ID')));
      return null;
  end get;
  
  
  function validate_simple_sql_name(
    p_name in varchar2)
    return varchar2
  as
    c_umlaut_regex constant varchar2(25) := '^[A-Z][_A-Z0-9#$]*$';
    l_position binary_integer;
    l_name ora_name_type;
    c_max_length constant number := 26;
  begin
    pit.enter(C_PKG, 'validate_simple_sql_name', msg_params(
      msg_param('p_name', p_name)));
      
    -- exclude names with double quotes
    l_name := upper(replace(p_name, '"'));
  
    -- exclude names with umlauts
    pit.assert(
       p_condition => regexp_like(l_name, c_umlaut_regex), 
       p_message_name => msg.UTL_NAME_CONTAINS_UMLAUT,
       p_arg_list => msg_args(l_name));
  
    -- Laenge gemaess Namenskonventionen
    pit.assert(
       p_condition => length(l_name) <= c_max_length,
       p_message_name => msg.UTL_NAME_TOO_LONG,
       p_arg_list => msg_args(l_name, to_char(c_max_length)));
  
    -- erlaubter Oracle-Name
    begin
       l_name := dbms_assert.simple_sql_name(l_name);
    exception
       when others then
          pit.fatal(msg.UTL_NAME_INVALID, msg_args(l_name));
    end;
  
    pit.leave;
    return null;
  exception
    when others then
      pit.leave;
      return substr(sqlerrm, 12);
  end validate_simple_sql_name;
  
  
  procedure set_error(
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null)
  as
    l_message max_char;
    l_page_item ora_name_type;
  begin
    pit.enter_detailed(C_PKG, 'set_error', msg_params(
      msg_param('p_page_item', p_page_item),
      msg_param('p_message', p_message)));
    if p_message is not null then
      begin
        l_message := pit.get_message_text(p_message, p_msg_args);
      exception
        when others then
           l_message := p_message;
      end;
      if p_page_item is not null then 
        l_page_item := get_page || replace(p_page_item, get_page);
        apex_error.add_error(
          p_message => l_message,
          p_display_location => apex_error.c_inline_with_field_and_notif,
          p_page_item_name => l_page_item);
      else
        apex_error.add_error(
          p_message => l_message,
          p_display_location => apex_error.c_inline_in_notification);
      end if;
    end if;
    pit.leave_detailed;
  end set_error;
  
  
  procedure set_error(
    p_test in boolean,
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null)
  as
    l_page_item ora_name_type;
  begin
    if not p_test then
      l_page_item := get_page || replace(p_page_item, get_page);
      set_error(l_page_item, p_message, p_msg_args);
    end if;
  end set_error;
  
  
  function get_page
   return varchar2
  is
    c_page_template constant varchar2(10) := 'P#PAGE#_';
  begin
    return replace(c_page_template, '#PAGE#', v('APP_PAGE_ID'));
  end get_page;
  
  
  function inserting
   return boolean
  is
  begin
    return v('REQUEST') in ('CREATE');
  end inserting;
  
  
  function updating
   return boolean
  is
  begin
    return v('REQUEST') in ('SAVE');
  end updating;
  
  
  function deleting
   return boolean
  is
  begin
    return v('REQUEST') in ('DELETE');
  end deleting;


  function request_is(
    p_request in varchar2)
    return boolean
  as
  begin
    return upper(v('REQUEST')) = upper(p_request);
  end request_is;
  

  procedure unhandled_request
  as
  begin
    pit.error(msg.UTL_INVALID_REQUEST, msg_args(v('REQUEST')));
  end unhandled_request;
  
  
  procedure create_modal_dialog_url(
      p_param_items in varchar2,
      p_value_items in varchar2,
      p_hidden_item in varchar2,
      p_url_template in varchar2)
  as
    l_url varchar2 (4000);
    l_param_list wwv_flow_global.vc_arr2;
    l_value_list wwv_flow_global.vc_arr2;
    l_item_param varchar2(32767);
    l_value_param varchar2(32767);
  begin
    pit.enter_optional(C_PKG, 'create_modal_dialog_url', msg_params(
      msg_param('p_param_items', p_param_items),
      msg_param('p_value_items', p_value_items),
      msg_param('p_hidden_item', p_hidden_item),
      msg_param('p_url_template', p_url_template)));
      
    l_param_list := apex_util.string_to_table(p_param_items, ':');
    l_value_list := apex_util.string_to_table(p_value_items, ':');
    for i in l_param_list.first .. l_param_list.last loop
      l_item_param := l_item_param || case when i > 1 then ',' end || l_param_list(i);
      l_value_param := l_value_param || case when i > 1 then ',' end || v(l_value_list(i));
    end loop;
    l_url := apex_util.prepare_url(
               p_url => 'f?p=' || p_url_template || ':' ||  v('SESSION') || '::::' || l_item_param || ':' || l_value_param,
               p_triggering_element => 'apex.jQuery("#' || p_hidden_item || '")');
    apex_util.set_session_state(p_hidden_item, l_url);
    
    pit.leave_optional;
  end create_modal_dialog_url;

  
  function clob_to_blob(
    p_clob in clob) 
    return blob 
  as
    C_CHUNK_SIZE constant integer := 4096;
    l_blob blob;
    l_offset number default 1;
    l_amount number default C_CHUNK_SIZE;
    l_offsetwrite number default 1;
    l_amountwrite number;
    l_buffer max_char;
  begin
    if p_clob is not null then
    dbms_lob.createtemporary(l_blob, true);
      loop
        dbms_lob.read (lob_loc => p_clob,
          amount => l_amount,
          offset => l_offset,
          buffer => l_buffer);
  
        l_amountwrite := utl_raw.length (utl_raw.cast_to_raw(l_buffer));
  
        dbms_lob.write (lob_loc => l_blob,
          amount => l_amountwrite,
          offset => l_offsetwrite,
          buffer => utl_raw.cast_to_raw(l_buffer));
  
        l_offsetwrite := l_offsetwrite + l_amountwrite;
  
        l_offset := l_offset + l_amount;
        l_amount := C_CHUNK_SIZE;
      end loop;
    end if;
    return l_blob;
  end clob_to_blob;
  

  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_mandatory(C_PKG, 'download_blob', msg_params(
      msg_param('p_blob.length', to_char(dbms_lob.getlength(p_blob))),
      msg_param('p_file_name', p_file_name)));
      
    htp.init;
    owa_util.mime_header('application/octet-stream', false, 'UTF-8');
    htp.p('Content-length: ' || dbms_lob.getlength(p_blob));
    htp.p('Content-Disposition: inline; filename="' || p_file_name || '"');
    owa_util.http_header_close;
    wpg_docload.download_file(p_blob);
    apex_application.stop_apex_engine;
    
    pit.leave_mandatory;
  exception when others then
    htp.p('error: ' || sqlerrm);
    pit.leave_mandatory;
    apex_application.stop_apex_engine;
  end download_blob;


  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2)
  as
    l_blob blob;
  begin
    l_blob := clob_to_blob(p_clob);
    download_blob(l_blob, p_file_name);
  end download_clob;
  

  procedure assert(
    p_condition in boolean,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  is
  begin
    pit.assert(
      p_condition => p_condition);
  exception
    when msg.ASSERT_TRUE_ERR then
      
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert;
    
    
  procedure assert_is_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_is_null(p_condition);
  exception
    when msg.ASSERT_IS_NULL_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_is_null;
    
    
  procedure assert_is_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_is_null(p_condition);
  exception
    when msg.ASSERT_IS_NULL_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_is_null;
    
    
  procedure assert_is_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_is_null(p_condition);
  exception
    when msg.ASSERT_IS_NULL_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_is_null;
  
  
  procedure assert_not_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_IS_NOT_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_not_null(p_condition);
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_not_null;
    
    
  procedure assert_not_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.ASSERT_IS_NOT_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_not_null(p_condition);
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_not_null;
    
    
  procedure assert_not_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.ASSERT_IS_NOT_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_not_null(p_condition);
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_not_null;
    
    
  procedure assert_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  is
  begin
    pit.assert_exists(
      p_stmt => p_stmt);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_exists;
    
  
  procedure assert_not_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  is
  begin
    pit.assert_not_exists(
      p_stmt => p_stmt);
  exception
    when msg.ASSERT_NOT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_not_exists;

end utl_apex;
/