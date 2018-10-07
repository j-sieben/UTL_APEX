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
  function get_true
    return varchar2
  as
  begin
    return C_TRUE;
  end get_true;
  
    
  function get_false
    return varchar2
  as
  begin
    return C_FALSE;
  end get_false;
    
    
  function user_is_authorized(
    p_authorization_scheme in varchar2)
    return flag_type
  as
    l_result flag_type;
  begin
    if apex_authorization.is_authorized(p_authorization_scheme) then
      l_result := C_TRUE;
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


  function get_page_values(
    p_format in varchar2 default null)
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
      case p_format
      when FORMAT_JSON then
        page_values(itm.item_name) := apex_escape.json(itm.item_value);
      when FORMAT_HTML then
        page_values(itm.item_name) := apex_escape.html(itm.item_value);
      else
        page_values(itm.item_name) := itm.item_value;
      end case;
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
    select utl_text.generate_text(
             cursor(
               select uttm_text template,
                      chr(10) cr,
                      lower(p_target_table) table_name,
                      lower(p_static_id) static_id,
                      utl_text.generate_text(cursor(
                          with params as(
                               select coalesce(p_application_id, to_number(v('APP_ID'))) app_id,
                                      coalesce(p_page_id, to_number(v('APP_PAGE_ID'))) page_id,
                                      lower(p_static_id) static_id
                                 from dual)
                        select /*+ NO_MERGE (p) */
                               uttm_text template,
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
                          join utl_text_templates t
                            on case when data_type in ('NUMBER', 'DATE') then data_type else 'DEFAULT' end = uttm_mode
                         where ig.source_type_code = 'DB_COLUMN'
                           and t.uttm_name = 'GRID_DATA_TYPE'
                           and t.uttm_type = 'APEX_IG')) column_list
                 from utl_text_templates
                where uttm_name = 'GRID_PROCEDURE'
                  and uttm_type = 'APEX_IG'
                  and uttm_mode = case when p_application_id is null then 'DYNAMIC' else 'STATIC' end)) resultat
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
    c_max_length constant number := pit_util.C_MAX_LENGTH - 4;
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
    return v('REQUEST') in ('CREATE') or v('APEX$ROW_STATUS') in ('I', 'C');
  end inserting;
  
  
  function updating
   return boolean
  is
  begin
    return v('REQUEST') in ('SAVE') or v('APEX$ROW_STATUS') in ('U');
  end updating;
  
  
  function deleting
   return boolean
  is
  begin
    return v('REQUEST') in ('DELETE') or v('APEX$ROW_STATUS') in ('D');
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
  

  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_mandatory(C_PKG, 'download_blob', msg_params(
      msg_param('p_blob.length', to_char(dbms_lob.getlength(p_blob))),
      msg_param('p_file_name', p_file_name)));
    
    pit.assert(p_blob is not null);
    
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
    pit.assert(p_clob is not null);
    l_blob := utl_text.clob_to_blob(p_clob);
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
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
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
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_not_null;
    
    
  procedure assert_not_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
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
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
        p_log_threshold => pit.level_error,
        p_log_modules => C_PIT_APEX_MODULE);
  end assert_not_null;
    
    
  procedure assert_not_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
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
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
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