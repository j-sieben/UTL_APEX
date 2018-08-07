create or replace package body utl_apex
as

  -- Private type declarations
  -- Private constant declarations
  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;
  c_true constant integer := 1;
  c_false constant integer := 0;
  c_apex_schema constant varchar2(30 byte) := $$PLSQL_UNIT_OWNER;
  c_apex_tmpl_type constant varchar2(30 byte) := 'APEX_COLLECTION';
  c_default constant varchar2(30 byte) := 'DEFAULT';
  c_pit_apex_module constant varchar2(30 byte) := 'PIT_APEX';

  -- HELPER
  function get_page_element(
    p_affected_id in varchar2)
    return varchar2
  as
    l_element varchar2(100);
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
    l_result pls_integer;
  begin
    if apex_authorization.is_authorized(p_authorization_scheme) then
      l_result := c_true;
    else
      l_result := c_false;
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
    pit.enter_mandatory(c_pkg, 'create_apex_session', msg_params(
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
    pit.enter_optional(c_pkg, 'get_page_values');
    
    for itm in page_item_cur(v('APP_ID'), v('APP_PAGE_ID')) loop
      page_values(itm.item_name) := itm.item_value;
    end loop;
    
    pit.leave_optional;
    return page_values;
  end get_page_values;

  function get_ig_values(
    p_target_table in varchar2,
    p_static_id in varchar2,
    p_application_id in number default null,
    p_page_id in number default null)
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
    p_element_name in varchar2)
    return varchar2
  as
  begin
    return p_page_values(p_element_name);
  exception
    when no_data_found then
      pit.fatal(msg.UTL_APEX_MISSING_ITEM, msg_args(p_element_name, v('APP_PAGE_ID')));
      return null;
  end get;
  
  
  function get_form_methods(
    p_application_id in number,
    p_page_id in number,
    p_insert_method in varchar2,
    p_update_method in varchar2,
    p_delete_method in varchar2)
    return clob
  as
    l_column_list varchar2(32767);
    l_code clob;
  begin
    pit.enter_mandatory(c_pkg, 'get_form_methods', msg_params(
      msg_param('p_application_id', to_char(p_application_id)),
      msg_param('p_page_id', to_char(p_page_id)),
      msg_param('p_insert_method', p_insert_method),
      msg_param('p_update_method', p_update_method),
      msg_param('p_delete_method', p_delete_method)));
      
    -- check input parameters
    pit.assert_not_null(p_application_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_APPLICATION_ID'));
    pit.assert_not_null(p_page_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_ID'));
    pit.assert_not_null(p_insert_method, msg.UTL_PARAMETER_REQUIRED, msg_args('P_INSET_METHOD'));
    pit.assert_not_null(p_update_method, msg.UTL_PARAMETER_REQUIRED, msg_args('P_UPDATE_METHOD'));
    pit.assert_not_null(p_delete_method, msg.UTL_PARAMETER_REQUIRED, msg_args('P_DELETE_METHOD'));
    
    -- generate column list
    select code_generator.generate_text(cursor(
             with page_elements as(
                  select apl.application_id, app.page_id, apo.attribute_02 view_name, app.page_alias, api.item_name, utc.column_name,
                         case when utc.data_type in ('NUMBER', 'DATE') then utc.data_type else 'DEFAULT' end data_type,
                         case 
                         when utc.data_type in ('DATE') then
                           coalesce(upper(api.format_mask), apl.date_format, 'dd.mm.yyyy hh24:mi:ss')
                         when utc.data_type in ('TIMESTAMP') then
                           coalesce(upper(api.format_mask), apl.timestamp_format, 'dd.mm.yyyy hh24:mi:ss')
                         when utc.data_type in ('NUMBER', 'INTEGER') then 
                           coalesce(replace(upper(api.format_mask), 'G'), 'fm9999999999990d99999999') 
                         end format_mask
                    from apex_applications apl
                    join apex_application_pages app
                      on apl.application_id = app.application_id
                    join apex_application_page_items api
                      on app.application_id = api.application_id
                     and app.page_id = api.page_id
                    join apex_application_page_proc apo
                      on app.application_id = apo.application_id
                     and app.page_id = apo.page_id
                    join user_tab_columns utc
                      on apo.attribute_02 = utc.table_name
                     and api.item_source = utc.column_name
                   where apo.process_type_code = 'DML_FETCH_ROW'),
                  template_list as(
                    select cgtm_text ddl_template, cgtm_mode data_type
                      from code_generator_templates
                     where cgtm_name = 'COLUMN'
                       and cgtm_type = 'APEX_FORM')
          select t.ddl_template, p.page_alias page_alias_upper, lower(p.page_alias) page_aliasl, 
                 substr(p.item_name, instr(p.item_name, '_', 1) + 1) item_name,
                 p.column_name column_name_upper, lower(p.column_name) column_name, p.format_mask
            from page_elements p
            join template_list t
              on p.data_type = t.data_type
           where p.application_id = p_application_id
             and p.page_id = p_page_id), chr(10) || '    '
         )
    into l_column_list
    from dual;
    
    -- generate methods
    select code_generator.generate_text(cursor(
             select t.cgtm_text template, l_column_list column_list,
                    lower(apo.attribute_02) view_name, upper(apo.attribute_02) view_name_upper,
                    lower(app.page_alias) page_alias, upper(app.page_alias) page_alias_upper,
                    lower(p_insert_method) insert_method,
                    lower(p_update_method) update_method,
                    lower(p_delete_method) delete_method
               from apex_application_pages app
               join apex_application_page_proc apo
                 on app.application_id = apo.application_id
                and app.page_id = apo.page_id
              cross join code_generator_templates t
              where app.application_id = p_application_id
                and app.page_id = p_page_id
                and apo.process_type_code = 'DML_FETCH_ROW'
                and t.cgtm_name = 'METHODS'
                and t.cgtm_type = 'APEX_FORM'
                and t.cgtm_mode = c_default))
      into l_code
      from dual;
      
    pit.leave_mandatory;
    return l_code;
  end get_form_methods;
  
  
  function get_collection_view(
    p_source_table in varchar2,
    p_page_view in varchar2)
    return clob
  as
    c_object_exists constant varchar2(1000) := q'^select 1
  from user_objects
 where object_name = upper('#OBJECT_NAME#')
   and object_type in ('VIEW', 'TABLE')^';
    l_code clob;
  begin
    pit.enter_mandatory(c_pkg, 'get_collection_view', msg_params(
      msg_param('p_source_table', p_source_table),
      msg_param('p_page_view', p_page_view)));
      
    -- check input parameters
    pit.assert_not_null(p_source_table, msg.UTL_PARAMETER_REQUIRED, msg_args('P_SOURCE_TABLE'));
    pit.assert_not_null(p_page_view, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_VIEW'));
    pit.assert_exists(
      p_stmt => replace(c_object_exists, '#OBJECT_NAME#', p_source_table),
      p_message_name => msg.UTL_OBJECT_DOES_NOT_EXIST,
      p_arg_list => msg_args('View/table', p_source_table));
      
    -- generate DDL for view
      with tmpl_list as(
           select cgtm_name, cgtm_text
             from code_generator_templates
            where cgtm_type = c_apex_tmpl_type
              and cgtm_mode = c_default)
    select code_generator.generate_text(cursor(
             select cgtm_text, p_page_view view_name, 
                    code_generator.generate_text(cursor(
                      select t.cgtm_text, collection_name, column_name, column_from_collection
                        from code_gen_apex_collection c
                       cross join tmpl_list t
                       where t.cgtm_name = 'COLUMN_LIST'
                         and c.table_name = p_source_table), ',' || chr(10) || '       ') column_list
               from tmpl_list
              where cgtm_name = 'VIEW'))
      into l_code
      from dual;
    
    pit.leave_mandatory;
    return l_code;
  end get_collection_view;    
  
  
  function get_collection_methods(
    p_application_id in number,
    p_page_id in number)
    return clob
  as
    c_has_alias_stmt constant varchar2(1000) := q'^select 1
  from apex_application_pages
 where application_id = #APPLICATION_ID#
   and page_id = #PAGE_ID#
   and page_alias is not null^';
    c_view_exists constant varchar2(1000) := q'^select 1
  from user_views
 where view_name = upper('#VIEW_NAME#')^';
    c_has_fetch_row_process constant varchar2(1000) := q'^select 1
  from apex_application_page_proc
 where application_id = #APPLICATION_ID#
   and page_id = #PAGE_ID#
   and process_type_code = 'DML_FETCH_ROW'^';
   
    l_code clob;
  begin
    pit.enter_mandatory(c_pkg, 'get_collection_methods', msg_params(
      msg_param('p_application_id', to_char(p_application_id)),
      msg_param('p_page_id', to_char(p_page_id))));
      
    -- check input parameters
    -- NOT NULL
    pit.assert_not_null(p_application_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_APPLICATION_ID'));
    pit.assert_not_null(p_page_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_ID'));
    -- APEX page has PAGE ALIAS
    pit.assert_exists(
      p_stmt => code_generator.bulk_replace(c_has_alias_stmt, char_table(
                  '#APPLICATION_ID#', to_clob(p_application_id),
                  '#PAGE_ID#', to_clob(p_page_id))),
      p_message_name => msg.UTL_PAGE_ALIAS_REQUIRED,
      p_arg_list => msg_args(to_char(p_page_id)));
    -- APEX page has FETCH ROW process
    pit.assert_exists(
      p_stmt => code_generator.bulk_replace(c_has_fetch_row_process, char_table(
                  '#APPLICATION_ID#', to_clob(p_application_id),
                  '#PAGE_ID#', to_clob(p_page_id))),
      p_message_name => msg.UTL_FETCH_ROW_REQUIRED);
    
    -- generate package code
      with tmpl_list as(
           select cgtm_name, cgtm_text
             from code_generator_templates
            where cgtm_type = c_apex_tmpl_type
              and cgtm_mode = c_default)
    select code_generator.generate_text(cursor(
             select t.cgtm_text, app.attribute_02 view_name, app.attribute_02 collection_name, apa.page_alias, 
                    code_generator.generate_text(cursor(
                      select t.cgtm_text, c.collection_name, c.column_to_collection, c.page_alias, c.column_name
                        from code_gen_apex_collection c
                       cross join tmpl_list t
                       where t.cgtm_name = 'PARAMETER_LIST'
                         and c.application_id = apa.application_id
                         and c.page_id = apa.page_id), ',' || chr(10) || '        ') param_list,
                    code_generator.generate_text(cursor(
                      select t.cgtm_text, c.collection_name, c.column_to_collection, c.page_alias, 
                             column_name, convert_from_item, number_format, date_format, timestamp_format
                        from code_gen_apex_collection c
                       cross join tmpl_list t
                       where t.cgtm_name = 'COPY_LIST'
                         and c.application_id = apa.application_id
                         and c.page_id = apa.page_id), ';' || chr(10) || '    ') copy_list
               from code_generator_templates t
              where cgtm_name = 'PACKAGE'
                and cgtm_type = 'APEX_COLLECTION'
                and cgtm_mode = 'DEFAULT')) trigger_stmt
      into l_code
      from apex_application_pages apa
      join apex_application_page_proc app
        on apa.application_id = app.application_id
       and apa.page_id = app.page_id
     where apa.application_id = p_application_id
       and apa.page_id = p_page_id
       and app.process_type_code = 'DML_FETCH_ROW';
       
    pit.leave_mandatory;
    return l_code;
  end get_collection_methods;
  
  
  function validate_simple_sql_name(
    p_name in varchar2)
    return varchar2
  as
    c_umlaut_regex constant varchar2(25) := '^[A-Z][_A-Z0-9#$]*$';
    l_position pls_integer;
    l_name varchar2(50);
    c_max_length constant number := 26;
  begin
    pit.enter(c_pkg, 'validate_simple_sql_name', msg_params(
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
    p_page_item in varchar2,
    p_message in varchar2,
    p_msg_args in msg_args default null)
  as
    l_message varchar2(32767);
    l_page_item varchar2(50);
  begin
    pit.enter_detailed(c_pkg, 'set_error', msg_params(
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
    p_page_item in varchar2,
    p_message in varchar2,
    p_msg_args in msg_args default null)
  as
    l_page_item varchar2(50);
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
    pit.enter_optional(c_pkg, 'create_modal_dialog_url', msg_params(
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
    c_chunk_size constant integer := 4096;
    l_blob blob;
    l_offset number default 1;
    l_amount number default c_chunk_size;
    l_offsetwrite number default 1;
    l_amountwrite number;
    l_buffer varchar2(c_chunk_size char);
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
        l_amount := c_chunk_size;
      end loop;
    end if;
    return l_blob;
  end clob_to_blob;
  

  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_mandatory(c_pkg, 'download_blob', msg_params(
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
    p_message_name in varchar2,
    p_affected_id in varchar2 default null,
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
        p_log_modules => c_pit_apex_module);
  end assert;
    
    
  procedure assert_is_null(
    p_condition in varchar2,
    p_message_name in varchar2 default msg.ASSERT_IS_NULL,
    p_affected_id in varchar2 default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_is_null(p_condition);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => c_pit_apex_module);
  end assert_is_null;
    
    
  procedure assert_is_null(
    p_condition in number,
    p_message_name in varchar2 default msg.ASSERT_IS_NULL,
    p_affected_id in varchar2 default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_is_null(p_condition);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => c_pit_apex_module);
  end assert_is_null;
    
    
  procedure assert_is_null(
    p_condition in date,
    p_message_name in varchar2 default msg.ASSERT_IS_NULL,
    p_affected_id in varchar2 default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_is_null(p_condition);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => c_pit_apex_module);
  end assert_is_null;
  
  
  procedure assert_not_null(
    p_condition in varchar2,
    p_message_name in varchar2 default msg.ASSERT_IS_NOT_NULL,
    p_affected_id in varchar2 default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_not_null(p_condition);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => c_pit_apex_module);
  end assert_not_null;
    
    
  procedure assert_not_null(
    p_condition in number,
    p_message_name in varchar2 default msg.ASSERT_IS_NOT_NULL,
    p_affected_id in varchar2 default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_not_null(p_condition);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => c_pit_apex_module);
  end assert_not_null;
    
    
  procedure assert_not_null(
    p_condition in date,
    p_message_name in varchar2 default msg.ASSERT_IS_NOT_NULL,
    p_affected_id in varchar2 default null,
    p_arg_list msg_args default null)
  as
  begin
    pit.assert_not_null(p_condition);
  exception
    when msg.ASSERT_EXISTS_ERR then
      pit.log_specific(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => p_arg_list,
        p_log_threshold => pit.level_error,
        p_log_modules => c_pit_apex_module);
  end assert_not_null;
    
    
  procedure assert_exists(
    p_stmt in varchar2,
    p_message_name in varchar2,
    p_affected_id in varchar2 default null,
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
        p_log_modules => c_pit_apex_module);
  end assert_exists;
    
  
  procedure assert_not_exists(
    p_stmt in varchar2,
    p_message_name in varchar2,
    p_affected_id in varchar2 default null,
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
        p_log_modules => c_pit_apex_module);
  end assert_not_exists;

end utl_apex;
/