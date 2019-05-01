create or replace package body utl_apex
as

  -- Private type declarations
  -- Private constant declarations
  C_PKG constant ora_name_type := $$PLSQL_UNIT;
  C_APEX_SCHEMA constant ora_name_type := $$PLSQL_UNIT_OWNER;
  C_PIT_APEX_MODULE constant ora_name_type := 'PIT_APEX:PIT_CONSOLE';
  C_ROW_STATUS constant ora_name_type := 'APEX$ROW_STATUS';

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
    return flag_type
  as
  begin
    return C_TRUE;
  end get_true;
  
    
  function get_false
    return flag_type
  as
  begin
    return C_FALSE;
  end get_false;
    
    
  function get_bool(
    p_bool in boolean)
    return flag_type
  as
  begin
    if p_bool then
      return C_TRUE;
    else
      return C_TRUE;
    end if;
  end get_bool;
    
    
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
    pit.enter_mandatory(p_params => msg_params(
      msg_param('p_apex_user', p_apex_user),
      msg_param('p_application_id', to_char(p_application_id)),
      msg_param('p_page_id', to_char(p_page_id))));

    $IF UTL_APEX.VER_LE_0500 $THEN
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

    $ELSE
    apex_session.create_session (
      p_app_id => p_application_id,
      p_page_id => p_page_id,
      p_username => p_apex_user);
    $END

    pit.leave_mandatory;
  end create_apex_session;


  function get_page_values(
    p_format in varchar2 default null)
    return page_value_t
  as
    cursor page_item_cur is
        with params as(
             select apex_application.g_flow_id application_id,
                    apex_application.g_flow_step_id page_id,
                    -- calculate starting point after Pnn_ prefix to extract item name without page prefix
                    length(to_char(apex_application.g_flow_step_id)) + 3 item_name_start, 
                    -- If IG_FLAG is set, then page item values are accessible via item source, not element name
                    case when v(C_ROW_STATUS) is not null then C_TRUE else C_FALSE end ig_flag
                from dual)
      select /*+ no_merge (params) */ 
             case ig_flag 
               when C_TRUE then item_source
               else substr(item_name, item_name_start)
             end item_name, 
             apex_util.get_session_state(
               case ig_flag 
                 when C_TRUE then item_source 
                 else item_name 
               end) item_value
        from apex_application_page_items
     natural join params
       where case ig_flag 
               when C_TRUE then item_source
               else item_name
             end is not null;
    page_values page_value_t;
  begin
    pit.enter_optional;
    
    for itm in page_item_cur loop
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
                               select coalesce(p_application_id, apex_application.g_flow_id) app_id,
                                      coalesce(p_page_id, apex_application.g_flow_step_id) page_id,
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
      pit.fatal(msg.UTL_APEX_MISSING_ITEM, msg_args(p_element_name, to_char(apex_application.g_flow_step_id)));
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
    pit.enter(p_params => msg_params(
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
    pit.enter_detailed(p_params => msg_params(
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
    return replace(c_page_template, '#PAGE#', to_char(apex_application.g_flow_step_id));
  end get_page;


  function inserting
   return boolean
  is
    c_insert_whitelist constant char_table := char_table('CREATE', 'CREATE_AGAIN', 'INSERT', 'CREATEAGAIN');
    c_insert_flag constant char(1 byte) := 'C';
    l_result boolean := false;
  begin
    $IF utl_apex.ver_le_0500 $THEN
    l_result := apex_application.g_request member of C_INSERT_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_STATUS in interactive Grid or Form regions (>= 19.1)
    if v(C_ROW_STATUS) = C_INSERT_FLAG or apex_application.g_request member of C_INSERT_WHITELIST then
      l_result := true;
    end if;
    $END
    return l_result;
  end inserting;


  function updating
   return boolean
  is
    c_update_whitelist constant char_table := char_table('SAVE', 'APPLY CHANGES', 'UPDATE', 'UPDATE ROW', 'CHANGE', 'APPLY');
    c_update_flag constant char(1 byte) := 'U';
    l_result boolean := false;
  begin
    $IF utl_apex.ver_le_0500 $THEN
    l_result := apex_application.g_request member of C_UPDATE_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_STATUS in interactive Grid or Form regions (>= 19.1)
    if v(C_ROW_STATUS) = C_UPDATE_FLAG or apex_application.g_request member of C_UPDATE_WHITELIST then
      l_result := true;
    end if;
    $END
    return l_result;
  end updating;


  function deleting
   return boolean
  is
    c_delete_whitelist constant char_table := char_table('DELETE', 'REMOVE', 'DELETE ROW', 'DROP');
    c_delete_flag constant char(1 byte) := 'D';
    l_result boolean := false;
  begin
    $IF utl_apex.ver_le_0500 $THEN
    l_result := apex_application.g_request member of C_DELETE_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_STATUS in interactive Grid or Form regions (>= 19.1)
    if v(C_ROW_STATUS) = C_DELETE_FLAG or apex_application.g_request member of C_DELETE_WHITELIST then
      l_result := true;
    end if;
    $END
    return l_result;
  end deleting;


  function request_is(
    p_request in varchar2)
    return boolean
  as
  begin
    return upper(apex_application.g_request) = upper(p_request);
  end request_is;


  procedure unhandled_request
  as
  begin
    pit.error(msg.UTL_INVALID_REQUEST, msg_args(apex_application.g_request));
  end unhandled_request;
  
  
  function get_page_url(
    p_url_template in varchar2,
    p_param_items in varchar2 default null,
    p_value_items in varchar2 default null,
    p_triggering_element in varchar2 default null,
    p_clear_cache in binary_integer default null)
    return varchar2
  as    
    l_url varchar2 (4000);
    l_value_list wwv_flow_global.vc_arr2;
    l_item_param varchar2(32767);
    l_value_param varchar2(32767);
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_param_items', p_param_items),
                    msg_param('p_value_items', p_value_items),
                    msg_param('p_url_template', p_url_template),
                    msg_param('p_triggering_element', p_triggering_element)));
    
    l_item_param := replace(p_param_items, ':', ',');
    l_value_list := apex_util.string_to_table(p_value_items, ':');
    for i in 1 .. l_value_list.count loop
      l_value_param := l_value_param || case when i > 1 then ',' end || v(l_value_list(i));
    end loop;
    $IF utl_apex.ver_le_05 $THEN
    l_url := apex_util.prepare_url(
               p_url => 'f?p=' || p_url_template || ':' || apex_application.g_instance || ':::' || p_clear_cache || ':' || l_item_param || ':' || l_value_param,
               p_triggering_element => p_triggering_element);
    $ELSE
    l_value_list := apex_util.string_to_table(p_url_template, ':');
    l_url := apex_page.get_url(
      p_application => l_value_list(1),
      p_page => l_value_list(2),
      p_clear_cache => p_clear_cache,
      p_items => l_item_param,
      p_values => l_value_param);
    $END
               
    pit.leave_optional(p_params => msg_params(msg_param('URL', l_url)));
    return l_url;
  end get_page_url;


  procedure create_modal_dialog_url(
    p_param_items in varchar2,
    p_value_items in varchar2,
    p_hidden_item in varchar2,
    p_url_template in varchar2)
  as
    l_url varchar2 (4000);
    l_triggering_element varchar2(100 char) := 'apex.jQuery("#' || p_hidden_item || '")';
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_param_items', p_param_items),
                    msg_param('p_value_items', p_value_items),
                    msg_param('p_hidden_item', p_hidden_item),
                    msg_param('p_url_template', p_url_template)));

    l_url := get_page_url(
      p_param_items => p_param_items,
      p_value_items => p_value_items,
      p_url_template => p_url_template,
      p_triggering_element => l_triggering_element);
    apex_util.set_session_state(p_hidden_item, l_url);

    pit.leave_optional(p_params => msg_params(
                                     msg_param('l_url', l_url)));
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
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_clob.length', to_char(dbms_lob.getlength(p_clob)))));
    
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
    
    pit.leave_optional;
    return l_blob;
  end clob_to_blob;


  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
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
    pit.enter_optional;
    pit.assert(
      p_condition => p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_TRUE_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert;


  procedure assert_is_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.enter_optional;
    pit.assert_is_null(p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NULL_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert_is_null;


  procedure assert_is_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.enter_optional;
    pit.assert_is_null(p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NULL_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert_is_null;


  procedure assert_is_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.enter_optional;
    pit.assert_is_null(p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NULL_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
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
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
        p_log_threshold => pit.level_error,
        p_module_list => C_PIT_APEX_MODULE);
  end assert_not_null;


  procedure assert_not_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.enter_optional;
    pit.assert_not_null(p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert_not_null;


  procedure assert_not_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.enter_optional;
    pit.assert_not_null(p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert_not_null;


  procedure assert_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  is
  begin
    pit.enter_optional;
    pit.assert_exists(p_stmt => p_stmt);
    pit.leave_optional;
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert_exists;


  procedure assert_not_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null)
  is
  begin
    pit.enter_optional;
    pit.assert_not_exists(p_stmt => p_stmt);
    pit.leave_optional;
  exception
    when msg.ASSERT_NOT_EXISTS_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => null,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
  end assert_not_exists;

end utl_apex;
/