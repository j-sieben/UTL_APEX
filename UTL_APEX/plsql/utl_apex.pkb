create or replace package body utl_apex
as

  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;
  
  
  function clob_to_blob(
    p_clob in clob)
    return blob
  as
    l_blob blob;
    l_lang_context  integer := dbms_lob.DEFAULT_LANG_CTX;
    l_warning       integer := dbms_lob.WARN_INCONVERTIBLE_CHAR;
    l_dest_offset   integer := 1;
    l_source_offset integer := 1;
  begin
    pit.enter_detailed('clob_to_blob', c_pkg);

    dbms_lob.createtemporary(l_blob, true, dbms_lob.call);
      dbms_lob.converttoblob (
        dest_lob => l_blob,
        src_clob => p_clob,
        amount => dbms_lob.LOBMAXSIZE,
        dest_offset => l_dest_offset,
        src_offset => l_source_offset,
        blob_csid => dbms_lob.DEFAULT_CSID,
        lang_context => l_lang_context,
        warning => l_warning
      );

    pit.leave_detailed;
    return l_blob;
  end clob_to_blob;
  
  
  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_optional(
      p_action => 'download_blob',
      p_module => c_pkg,
      p_params => msg_params(msg_param('p_file_name', p_file_name)));

    htp.init;
    owa_util.mime_header('application/octet-stream', FALSE, 'UTF-8');
    htp.p('Content-length: ' || dbms_lob.getlength(p_blob));
    htp.p('Content-Disposition: inline; filename="' || p_file_name || '"');
    owa_util.http_header_close;
    wpg_docload.download_file(p_blob);
    apex_application.stop_apex_engine;

    pit.leave_optional;
  exception when others then
    htp.p('error: ' || sqlerrm);
    apex_application.stop_apex_engine;
    pit.leave_optional;
  end download_blob;


  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2)
  as
    l_blob blob;
  begin
    pit.enter_optional(
      p_action => 'download_clob',
      p_module => c_pkg,
      p_params => msg_params(msg_param('p_file_name', p_file_name)));

    l_blob := clob_to_blob(p_clob);
    download_blob(l_blob, p_file_name);

    pit.leave_optional;
  end download_clob;
  
  
  function get_page_values
    return page_value_tab
  as
    cursor item_cur(p_application_id in number, p_page_id in number) is
      select item_name,
             -- Entferne Abhaengigkeit von Seitennummer aus Elementnamen
             substr(item_name, instr(item_name, '_') + 1) item_short_name
        from apex_application_page_items
       where application_id = p_application_id
         and page_id = p_page_id;
    l_page_values page_value_tab;
  begin
    for itm in item_cur(v('APP_ID'), v('APP_PAGE_ID')) loop
      l_page_values(itm.item_short_name) := v(itm.item_name);
    end loop;
    return l_page_values;
  end get_page_values;
  
  
  function get_page
    return varchar2
  as
    c_page_template constant varchar2(100) := 'P#PAGE#_';
  begin
    return replace(c_page_template, '#PAGE#', v('APP_ID'));
  end get_page;
  
    
  function get_value(
    p_page_values in page_value_tab,
    p_element_name in varchar2)
    return varchar2
  as
  begin
    return p_page_values(p_element_name);
  exception
    when no_data_found then
      pit.stop(msg.UTL_APEX_ITEM_MISSING, msg_args(p_element_name, v('APP_ID')));
  end get_value;
  
  
  function inserting
    return boolean
  as
  begin
    return v('REQUEST') in ('CREATE');
  end inserting;
  
    
  function updating
    return boolean
  as
  begin
    return v('REQUEST') in ('SAVE');
  end updating;
  
    
  function deleting
    return boolean
  as
  begin
    return v('REQUEST') in ('DELETE');
  end deleting;
  
  
  procedure create_modal_dialog_url(
    p_value_item in varchar2,
    p_hidden_item in varchar2,
    p_url_template in varchar2)
  as
    l_value_item_tab wwv_flow_global.vc_arr2;
    l_param_values varchar2(32767);
    l_url varchar2(32767);
    c_url_template constant varchar2(100) := q'^f?p=#URL_TEMPLATE#::::#PARAMS#:#PARAM_VALUES#^';
  begin
    l_value_item_tab := apex_util.string_to_table (
                          p_string => p_value_item,
                          p_separator => ',');
    for i in l_value_item_tab.first .. l_value_item_tab.last loop
      if i > 1 then 
        l_param_values := l_param_values || ',';
      end if;
      l_param_values := l_param_values || v(l_value_item_tab(i));
    end loop;
    l_url := utl_text.bulk_replace(
               c_url_template, char_table(
                 '#UTL_TEMPLATE#', p_url_template,
                 '#PARAMS#', p_value_item,
                 '#PARAM_VALUES#', l_param_values));
    apex_util.set_session_state(p_hidden_item, apex_util.prepare_url(l_url));
  end create_modal_dialog_url;
  
  
  function get_authorization_status_for(
    p_authorization_scheme in varchar2)
    return number
  as
  begin
    if apex_util.public_check_authorization(p_authorization_scheme) then
      return 1;
    else
      return 0;
    end if;
  end get_authorization_status_for;
  
    
  procedure create_apex_session(
    p_application_id in apex_applications.application_id%type,
    p_apex_user in apex_workspace_activity_log.apex_user%type,
    p_page_id in apex_application_pages.page_id%type default 1)
  as
    l_workspace_id apex_applications.workspace_id%type;
    l_param_name owa.vc_arr;
    l_param_val owa.vc_arr;
  begin
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
      
  end create_apex_session;
  
end;
/