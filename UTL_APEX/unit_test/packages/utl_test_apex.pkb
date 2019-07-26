create or replace package body utl_test_apex
as

  g_da_type apex_plugin.t_dynamic_action;
  g_plugin_type apex_plugin.t_plugin;
  g_render_result apex_plugin.t_dynamic_action_render_result;  
  
  
  procedure append_to_table(
    p_char_table in out nocopy char_table,
    p_chunk in varchar2)
  as
  begin
    if p_char_table is null then
      p_char_table := char_table();
    end if;
    p_char_table.extend;
    p_char_table(p_char_table.last) := p_chunk;
  end append_to_table;
  

  procedure create_apex_session(
    p_apex_user in apex_workspace_activity_log.apex_user%type,
    p_application_id in apex_applications.application_id%type,
    p_page_id in apex_application_pages.page_id%type default 1)
  as
    $IF UTL_APEX.VER_LE_0500 $THEN
    l_workspace_id apex_applications.workspace_id%type;
    l_param_name owa.vc_arr;
    l_param_val owa.vc_arr;
    $END
  begin
    pit.enter_optional(p_params => msg_params(
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

    wwv_flow_api.set_security_group_id(get_workspace_id(p_application_id));

    apex_application.g_instance := 1;
    apex_application.g_flow_id := p_application_id;
    get_page_id := p_page_id;

    apex_custom_auth.post_login(
      p_uname => p_apex_user,
      p_session_id => apex_custom_auth.get_next_session_id,
      p_app_page => get_application_id || ':' || p_page_id);

    $ELSE
    apex_session.create_session (
      p_app_id => p_application_id,
      p_page_id => p_page_id,
      p_username => p_apex_user);
    $END

    pit.leave_optional;
  end create_apex_session;
  
  
  procedure delete_apex_session(
    p_session_id in number default null)
  as
  begin
    pit.enter_optional(p_params => msg_params(
      msg_param('p_session_id', to_char(p_session_id))));
      
  $IF UTL_APEX.VER_LE_0500 $THEN
    apex_custom_auth.logout;
  $ELSE
    apex_session.delete_session(p_session_id);
  $END
    
    pit.leave_optional;
  end delete_apex_session;
  
  
  procedure init_owa
  as
    l_init integer; 
    l_num_params pls_integer := 0;
    l_param_names owa.vc_arr; 
    l_param_values owa.vc_arr; 
  begin
    l_init := owa.initialize;
    owa.init_cgi_env (
      num_params => l_num_params,
      param_name => l_param_names,
      param_val => l_param_values);
  end init_owa;
  
  
  procedure print_owa_output
  as
    l_owa_output char_table;
  begin
    l_owa_output := get_owa_output;
    
    for i in 1 .. l_owa_output.count loop
      dbms_output.put_line(l_owa_output(i));
    end loop;
  end print_owa_output;
  
  
  function get_owa_output
    return char_table
  as
    l_chunk sys.htp.htbuf_arr;
    l_row_count integer := 99999999999;
    l_rows char_table;
    l_last_row varchar2(1000);
    l_owa_output char_table;
  begin
    -- Method return OWA output as an array of chunks of various length (around 290 Bytes)
    owa.get_page(
      thepage => l_chunk, 
      irows => l_row_count);
    
    -- Iterate over the returned chunk array to extract text lines
    for i in 1 .. l_row_count loop
      if l_chunk (i) is not null then
        -- split text lines within chunk into an array of lines
        utl_text.string_to_table(l_chunk(i), l_rows, chr(10));
        
        for k in 1 .. l_rows.count loop
          case when k = 1 then
            -- first line if the actual chunk. If last iteration contained a text chunk wihtout a CR, this is prepended to the
            -- actual line to get back the original lines
            append_to_table(l_owa_output, l_last_row || l_rows(k));
          when k = l_rows.count then
            -- Last row. Don't append now as the next chunk may contain the rest of this line
            l_last_row := l_rows(k);
          else
            -- Complete line, append to list
            append_to_table(l_owa_output, l_rows(k));
          end case;
        end loop;
      end if;
    end loop;
    -- flush buffer
    append_to_table(l_owa_output, l_last_row
    );
    
    return l_owa_output;
  end get_owa_output;
  
  
end utl_test_apex;
/
