create or replace package body utl_apex
as

  -- Private type declarations
  -- Private constant declarations
  C_PIT_APEX_MODULE constant ora_name_type := 'PIT_APEX:PIT_CONSOLE';
  C_ROW_STATUS constant ora_name_type := 'APEX$ROW_STATUS';
  
  -- Constants for supported APEX form types
  C_PAGE_FORM constant ora_name_type := 'FORM';
  C_FORM_REGION constant ora_name_type := 'NATIVE_FORM';
  C_IG_REGION constant ora_name_type := 'NATIVE_IG';
  
  -- Templates used for GET_PAGES etc.
  C_TEMPLATE_TYPE constant ora_name_type := 'APEX_FORM';
  C_TEMPLATE_NAME_FRAME constant ora_name_type := 'FORM_FRAME';
  C_TEMPLATE_NAME_COLUMNS constant ora_name_type := 'FORM_COLUMN';
  
  C_TEMPLATE_MODE_DYNAMIC constant ora_name_type := 'DYNAMIC';
  C_TEMPLATE_MODE_STATIC constant ora_name_type := 'STATIC';
  
  C_PARAM_GROUP constant ora_name_type := 'UTL_APEX';
  C_ITEM_PREFIX_CONVENTION constant ora_name_type := 'ITEM_PREFIX_CONVENTION';
  C_ITEM_VALUE_CONVENTION constant ora_name_type := 'ITEM_VALUE_CONVENTION';
  
  C_DATE constant ora_name_type := 'DATE';
  C_NUMBER constant ora_name_type := 'NUMBER';
  C_DEFAULT constant ora_name_type := 'DEFAULT';
  
  g_item_value_convention boolean;
  g_item_prefix_convention binary_integer;

  -- HELPER
  /** Method to canonize an element name. 
   * @param  p_affected_id  Name of the page item
   * @usage  Used to make sure that a page item has got it's page prefix. If it is passed in without page prefix, it will be added
   */
  function get_page_element(
    p_affected_id in ora_name_type)
    return varchar2
  as
    l_page_prefix ora_name_type;
  begin
    l_page_prefix := get_page_prefix;
    return l_page_prefix || ltrim(p_affected_id, l_page_prefix);
  end get_page_element;
  
  
  function get_item_prefix
    return varchar2
  as
    C_DELIMITER constant char(1 byte) := '_';
    l_prefix ora_name_type;
  begin
    case g_item_prefix_convention
    when CONVENTION_PAGE_PREFIX then l_prefix := get_page_prefix;
    when CONVENTION_PAGE_ALIAS then l_prefix := get_page_alias || C_DELIMITER;
    when CONVENTION_APP_ALIAS then l_prefix := get_application_alias || C_DELIMITER;
    end case;
    
    return l_prefix;
  end get_item_prefix;
  
  
  /** Method tries to read the message text of a PIT message
   * @param  p_message  Name of the PIT message or a message text
   * @param  p_msg_args  Arguments for the PIT message
   * @return Message text
   * @usage  Is used to try to create a text based on a PIT message. If that fails, parameter <code>P_MESSAGE</oode> is returned.
   */
  function get_pit_message(
    p_message in ora_name_type,
    p_msg_args in msg_args)
    return varchar2
  as
  begin
    return pit.get_message_text(p_message, p_msg_args);
  exception
    when others then
       return p_message;
  end get_pit_message;
  
      
  /** Method to download a blob file over the browser
   * @param  p_blob  The instance to download
   * @param  p_file_name  File name of the downloaded blob instance
   * @usage  Is used as the implementation for DOWNLOAD_CLOB/DOWNLOAD_BLOB
   */
  procedure download_file(
   p_blob in blob, 
   p_file_name in varchar2)
  as
    l_blob blob := p_blob;
  begin
    -- Write http header
    htp.init;
    owa_util.mime_header('application/octet-stream', false, 'UTF-8');
    htp.p('Content-length: ' || dbms_lob.getlength(p_blob));
    htp.p('Content-Disposition: inline; filename="' || p_file_name || '"');
    owa_util.http_header_close;
    
    wpg_docload.download_file(l_blob);
    
    stop_apex;
  end download_file;
  
  
  /** Method to generate an URL based on APEX functionality
   * @param [p_application]        ID or alias of an APEX application. Defaults to the actual application alias
   * @param [p_page]               ID or alias of an APEX application page. Defaults to the actual page alias
   * @param [p_clear_cache]        Comma seperated list of page ids for which the session state will be cleared
   * @param [p_param_list]         Comma separated list of target page items for which values will be set
   * @param [p_param_list]         Comma separated list of values that are passed to the target page items
   * @param [p_triggering_element] Element that retrieves the apexafterdialogclose event
   * @return URL for the given page
   * @usage  Is used as an internal helper to mask the different interface implementations
   */
  function get_url(
    p_application in varchar2 default null,
    p_page in varchar2 default null,
    p_clear_cache in varchar2 default null,
    p_param_list in varchar2 default null,
    p_value_list in varchar2 default null,
    p_triggering_element in varchar2 default null)
    return varchar2
  as
    $IF utl_apex.ver_le_05 $THEN
    C_URL constant max_sql_char := q'^'f?p=#APP#:#PAGE#:#SESSION_ID#:#DEBUG#::#CLEAR_CACHE#:#PARAM_LIST#:#VALUE_LIST#'^';
    $END
    l_url utl_apex.max_sql_char;
  begin  
    $IF utl_apex.ver_le_0500 $THEN
    l_url := utl_text.bulk_replace(C_URL, char_table(
               'APP', p_application,
               'PAGE', p_page,
               'SESSION_ID', get_session_id,
               'DEBUG', get_debug,
               'CLEAR_CACHE', p_clear_cache,
               'PARAM_LIST', p_param_list,
               'VALUE_LIST', p_value_list));
    l_url := apex_util.prepare_url(
               p_url => l_url,
               p_triggering_element => p_triggering_element);
    $ELSE
    l_url := apex_page.get_url(
               p_application => p_application,
               p_page => p_page,
               p_clear_cache => p_clear_cache,
               p_items => p_param_list,
               p_values => p_value_list);
    $END    
    return l_url;
  end get_url;
  
  
  /** Default initialization method */
  procedure initialize
  as
  begin
    g_item_prefix_convention := param.get_integer(C_ITEM_PREFIX_CONVENTION, C_PARAM_GROUP);
    g_item_value_convention := param.get_boolean('ITEM_VALUE_CONVENTION', C_PARAM_GROUP);
  end initialize;


  -- INTERFACE
  function get_user
    return varchar2
  as
  begin
    return apex_application.g_user;
  end get_user;
  

  function get_workspace_id(
    p_application_id in number)
    return number
  as
    l_workspace_id apex_applications.workspace_id%type;
  begin
    select workspace_id
      into l_workspace_id
      from apex_applications
     where application_id = p_application_id;
    return l_workspace_id;
  end get_workspace_id;
  
  
  function get_application_id
    return number 
  as
  begin
    return apex_application.g_flow_id;
  end get_application_id;
  
  
  function get_application_alias
    return varchar2 
  as
  begin
    return apex_application.g_flow_alias;
  end get_application_alias;
  

  function get_page_id
    return number 
  as
  begin
    return apex_application.g_flow_step_id;
  end get_page_id;
  

  function get_page_alias
    return varchar2 
  as
  begin
    return apex_application.g_page_alias;
  end get_page_alias;


  function get_page_prefix
   return varchar2
  is
    C_PAGE_TEMPLATE constant ora_name_type := 'P#PAGE#';
    C_DELIMITER char(1 byte) := '_';
    l_prefix ora_name_type;
  begin
    case g_item_prefix_convention
    when CONVENTION_PAGE_PREFIX then
      l_prefix := replace(C_PAGE_TEMPLATE, '#PAGE#', to_char(get_page_id));
    when CONVENTION_PAGE_ALIAS then
      l_prefix := get_page_alias;
    when CONVENTION_APP_ALIAS then
      l_prefix := get_application_alias;
    else
      l_prefix := 'NN';
    end case;
    
    return l_prefix || C_DELIMITER;
  end get_page_prefix;
  

  function get_session_id
    return number 
  as
  begin
    return apex_application.g_instance;
  end get_session_id;
  
    
  function get_request
    return varchar2
  as
  begin
    return apex_application.g_request;
  end get_request;
  
    
  function get_debug
    return boolean
  as
  begin
    return apex_application.g_debug;
  end get_debug;
  
  
  function get_default_date_format(
    p_application_id in number default null)
    return varchar2
  as
    l_date_format apex_applications.date_format%type;
  begin
    if p_application_id is null then
      l_date_format := apex_application.g_date_format;
    else
      select date_format
        into l_date_format
        from apex_applications
       where application_id = p_application_id;
    end if;
    return l_date_format;
  end get_default_date_format;
  
  
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
  
  
  function get_yes
    return ora_name_type
  as
  begin
    return C_YES;
  end get_yes;
  
  
  function get_no
    return ora_name_type
  as
  begin
    return C_NO;
  end get_no;
    
    
  function get_bool(
    p_bool in boolean)
    return flag_type
  as
  begin
    if p_bool then
      return C_TRUE;
    else
      return C_FALSE;
    end if;
  end get_bool;
  
  
  function get_value(
    p_item in varchar2)
    return varchar2
  as
    C_STMT constant max_char := q'^select null from apex_application_page_items where application_id = #APP_ID# and page_id = #PAGE_ID# and item_name = '#ITEM_NAME#'^';
    l_stmt max_char;
    l_value max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_item', p_item)));
                    
    l_value := apex_util.get_session_state(upper(p_item));
    
    if l_value is null and g_item_value_convention then
      l_stmt := utl_text.bulk_replace(C_STMT, char_table(
                  'APP_ID', to_char(get_application_id),
                  'PAGE_ID', to_char(get_page_id),
                  'ITEM_NAME', upper(p_item)));
      pit.assert_exists(l_stmt, msg.PAGE_ITEM_MISSING, msg_args(p_item));
    end if;
    
    pit.leave_optional;
    return l_value;
  exception
    when msg.PAGE_ITEM_MISSING_ERR then
      pit.leave_optional(msg_params(msg_param('Error', substr(sqlerrm, 12))));
      raise;
  end get_value;
  
    
  procedure set_value(
    p_item in varchar2,
    p_value in varchar2)
  as
  begin
    apex_util.set_session_state(p_item, p_value);
  exception
    when others then
      pit.error(msg.PAGE_ITEM_MISSING, msg_args(p_item));
  end set_value;


  procedure set_item_value_convention(
    p_convention in boolean)
  as
  begin
    g_item_value_convention := coalesce(p_convention, param.get_boolean('ITEM_VALUE_CONVENTION', C_PARAM_GROUP));
  end set_item_value_convention;
  
    
  function get_item_value_convention
    return boolean
  as
  begin
    return g_item_value_convention;
  end get_item_value_convention;


  procedure set_item_prefix_convention(
    p_convention in binary_integer)
  as
    l_convention binary_integer;
  begin
    l_convention := coalesce(p_convention, param.get_integer(C_ITEM_PREFIX_CONVENTION, C_PARAM_GROUP));
    pit.assert(l_convention in (CONVENTION_PAGE_PREFIX, CONVENTION_PAGE_ALIAS, CONVENTION_APP_ALIAS), msg.INVALID_ITEM_PREFIX);
      
    g_item_prefix_convention := l_convention;
  end set_item_prefix_convention;
  
    
  function get_item_prefix_convention
    return binary_integer
  as
  begin
    return g_item_prefix_convention;
  end get_item_prefix_convention;
    
    
  function user_is_authorized(
    p_authorization_scheme in varchar2)
    return flag_type
  as
    l_result flag_type;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_authorization_scheme', p_authorization_scheme)));
                    
    l_result := get_bool(apex_authorization.is_authorized(p_authorization_scheme));
    
    pit.leave_optional(msg_params(msg_param('is authorized', l_result)));
    return l_result;
  exception
    when others then
      pit.leave_optional(msg_params(msg_param('Error', substr(sqlerrm, 12))));
      return C_FALSE;
  end user_is_authorized;
  
  
  function get_page_items(
    p_view_name in ora_name_type,
    p_static_id in varchar2,
    p_application_id in number,
    p_page_id in number,
    p_only_columns in flag_type default null)
    return utl_apex_page_item_t
    pipelined
  as
    l_form_type ora_name_type;
    l_view_name ora_name_type;
    C_STMT constant max_sql_char := q'^
select d.page_items 
  from #VIEW_NAME# d
 where application_id = #APP_ID#
   and page_id = #PAGE_ID#
   and decode(static_id, '#STATIC_ID#', 1, 0) = 1
   and (is_column_based = '#ONLY_COLUMNS#' or '#ONLY_COLUMNS#' is null)^';
    l_stmt max_char;
    l_cur sys_refcursor;
    l_row utl_apex_page_item;
  begin
    pit.enter_detailed;
    
    l_stmt := utl_text.bulk_replace(C_STMT, char_table(
                '#VIEW_NAME#', p_view_name,
                '#APP_ID#', p_application_id,
                '#PAGE_ID#', p_page_id,
                '#STATIC_ID#', p_static_id,
                '#ONLY_COLUMNS#', case when p_only_columns is not null then C_TRUE end));
                
    open l_cur for l_stmt;
    fetch l_cur into l_row;
    while l_cur%FOUND loop
      pipe row (l_row);
      fetch l_cur into l_row;
    end loop;
    
    pit.leave_detailed;
    return;
  end get_page_items;
  
  
  /** Method to decide upon the view name based on the form type detected on the page for this combination of parameters
   * @return Name of the view as detected.
   * @usage  Is used to get the correct view name based upon the type of form. Supported form types are:
   *         - NATIVE_IG: Interactive Grid, identified by static id => UTL_APEX_IG_COLUMNS
   *         - NATIVE_FORM: Form region, identified by static id => UTL_APEX_FORM_REGION_COLUMNS
   *         - FORM: classic form, deprecated since 19.1, fallback solution => UTL_APEX_FETCH_ROW_COLUMNS
   */
  function get_view_name(
    p_static_id in varchar2,
    p_application_id in number,
    p_page_id in number)
    return varchar2
  as
    l_form_type ora_name_type;
    l_view_name ora_name_type;
    C_VIEW_FETCH_ROW constant ora_name_type := 'utl_apex_fetch_row_columns';
    C_VIEW_FORM constant ora_name_type := 'utl_apex_form_region_columns';
    C_VIEW_IG constant ora_name_type := 'utl_apex_ig_columns';
  begin
    pit.enter_detailed(
      p_params => msg_params(
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_application_id', to_char(p_application_id)),
                    msg_param('p_page_id', to_char(p_page_id))));
    
    -- Try to find interactive Grid or form region, fallback to C_PAGE_FORM if not successful
    select coalesce(max(source_type_code), C_PAGE_FORM) source_type_code
      into l_form_type
      from apex_application_page_regions
     where application_id = p_application_id
       and page_id  = p_page_id
       and static_id = p_static_id
       and source_type_code in (C_FORM_REGION, C_IG_REGION);
     
    pit.debug(msg.PIT_PASS_MESSAGE, msg_args('FormType: ' || l_form_type));
     
    case l_form_type
    when C_PAGE_FORM then
      l_view_name := C_VIEW_FETCH_ROW;
    when C_FORM_REGION then
      l_view_name := C_VIEW_FORM;
    when C_IG_REGION then
      l_view_name := C_VIEW_IG;
    end case;
     
    pit.leave_optional(msg_params(msg_param('Result', l_view_name)));
    return l_view_name;
  end get_view_name;


  function get_page_values(
    p_static_id in varchar2 default null,
    p_format in varchar2 default null)
    return page_value_t
  as
    cursor page_item_cur(
      p_view_name in ora_name_type,
      p_static_id in ora_name_type,
      p_application_id in number,
      p_page_id in number)
    is
      select /*+ no_merge (p) */ 
             upper(column_name) item_name, 
             source_name page_item_name
        from table(utl_apex.get_page_items(p_view_name, p_static_id, p_application_id, p_page_id));
    
    l_application_id number := get_application_id;
    l_page_id number := get_page_id;
    l_view_name ora_name_type;
    page_values page_value_t;
  begin 
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_format', p_format)));
                    
    l_view_name := get_view_name(
                     p_static_id => p_static_id,
                     p_application_id => l_application_id,
                     p_page_id => l_page_id);
                    
    for itm in page_item_cur(l_view_name, p_static_id, l_application_id, l_page_id) loop
      case p_format
      when FORMAT_JSON then
        page_values(itm.item_name) := apex_escape.json(v(itm.page_item_name));
      when FORMAT_HTML then
        page_values(itm.item_name) := apex_escape.html(v(itm.page_item_name));
      else
        page_values(itm.item_name) := v(itm.page_item_name);
      end case;
    end loop;

    pit.leave_optional(msg_params(msg_param('Result', to_char(page_values.count) || ' Item values')));
    return page_values;
  end get_page_values;
  
  
  /** Method to create a script to get the values of the page items.
   * @return script that contains a PL/SQL block to be either directly executed, returning a record, or a script that may
   *         be inserted into a package as a code generator, based on P_UTTM_MODE
   * @usage  Is used to create a script for all page items based on the type of the input form and the usage.
   *         It is called with different P_UTTM_MODE parameters to cater for copying data to a PL/SQL table or a record
   *         Supported values:
   *         - DYNAMIC: script is execeuted immediately and return a filled record instance of P_TABLE_NAME%ROWTYPE
   *         - STATIC: script is returned as varchar2 to be included in PL/SQL packages
   */
  function get_script_for_page_items(
    p_uttm_mode in utl_text_templates.uttm_mode%type,
    p_static_id in varchar2,
    p_table_name in varchar2,
    p_application_id in number default get_application_id,
    p_page_id in number default get_page_id,
    p_record_name in varchar2 default 'l_row_rec')
    return max_char
  as
    l_script clob;
    l_view_name ora_name_type;
  begin
    pit.enter_detailed(
      p_params => msg_params(
                    msg_param('p_uttm_mode', p_uttm_mode),
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_table_name', p_table_name),
                    msg_param('p_application_id', to_char(p_application_id)),
                    msg_param('p_page_id', to_char(p_page_id)),
                    msg_param('p_record_name', p_record_name)));
                    
    l_view_name := get_view_name(
                     p_static_id => p_static_id,
                     p_application_id => p_application_id,
                     p_page_id => p_page_id);

      with params as(
             select p_uttm_mode uttm_mode, 
                    get_default_date_format(p_application_id) date_format,
                    p_record_name record_name,
                    p_table_name table_name
               from dual
           ),
           templates as (
             select uttm_text template, uttm_mode
               from utl_text_templates
              where uttm_name in (C_TEMPLATE_NAME_COLUMNS, C_TEMPLATE_NAME_FRAME)
                and uttm_type = C_TEMPLATE_TYPE),
           data as (
             select *
               from table(utl_apex.get_page_items(l_view_name, p_static_id, p_application_id, p_page_id, C_TRUE)) c),
           tab_name as (
             select max(table_name) table_name
               from data)
    select /*+ no_merge (p)*/
           utl_text.generate_text(cursor(
             select t.template, coalesce(t.table_name, p.table_name) table_name, p.record_name,
                    utl_text.generate_text(cursor(
                      select t.template, d.column_name, d.source_name, 
                             coalesce(d.format_mask, case d.data_type when C_DATE then p.date_format end)  format_mask
                        from data d
                        join templates t
                          on case when d.data_type in ('NUMBER', C_DATE) then d.data_type else C_DEFAULT end = t.uttm_mode
                    )) column_list
               from tab_name t
              cross join params p))
      into l_script
      from templates t
      join params p
        on p.uttm_mode = t.uttm_mode;
        
    pit.leave_detailed;
    return to_char(l_script);
  end get_script_for_page_items;
  
  
  function get_page_record(
    p_static_id in varchar2 default null,
    p_table_name in varchar2 default null)
    return varchar2
  as
    l_cursor sys_refcursor;
    l_script max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_table_name', p_table_name)));
                    
    l_script := get_script_for_page_items(
                  p_uttm_mode => C_TEMPLATE_MODE_DYNAMIC,
                  p_static_id => p_static_id,
                  p_table_name => p_table_name);
    
    pit.leave_optional(msg_params(msg_param('Result', l_script)));
    return l_script;
  end get_page_record;
  
  
  function get_page_item_script(
    p_static_id in varchar2 default null,
    p_table_name in varchar2 default null,
    p_application_id in number,
    p_page_id in number,
    p_record_name in varchar2)
    return varchar2
  as
    l_cursor sys_refcursor;
    l_script max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_table_name', p_table_name),
                    msg_param('p_application_id', to_char(p_application_id)),
                    msg_param('p_page_id', to_char(p_page_id)),
                    msg_param('p_record_name', p_record_name)));
    
    l_script := get_script_for_page_items(
                  p_uttm_mode => C_TEMPLATE_MODE_STATIC,
                  p_static_id => p_static_id,
                  p_table_name => p_table_name,
                  p_application_id => p_application_id,
                  p_page_id => p_page_id,
                  p_record_name => p_record_name);
    
    pit.leave_optional(msg_params(msg_param('Result', l_script)));
    return l_script;
  end get_page_item_script;


  function get(
    p_page_values in page_value_t,
    p_element_name in ora_name_type)
    return varchar2
  as
    l_value max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_element_name', p_element_name)));
                    
    l_value := p_page_values(upper(ltrim(p_element_name, get_item_prefix)));
    
    pit.leave_optional(msg_params(msg_param('Result', l_value)));
    return l_value;
  exception
    when no_data_found then
      pit.leave_optional(msg_params(msg_param('Error', p_element_name || ' not found')));
      pit.error(msg.UTL_APEX_MISSING_ITEM, msg_args(p_element_name, to_char(get_page_id)));
      -- unreachable code, compiler can't see this and will warn if the next stmt is deleted
      return null;
  end get;


  function validate_simple_sql_name(
    p_name in ora_name_type)
    return ora_name_type
  as
    C_UMLAUT_REGEX constant ora_name_type := '[^QWERTZUIOPASDFGHJKLYXCVBNM1234567890$_]';
    -- TODO: Take this length from PIT
    C_MAX_LENGTH constant number := 26;
    l_name ora_name_type;
    l_error_message max_sql_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_name', p_name)));

    -- exclude names with double quotes
    l_name := upper(replace(p_name, '"'));

    -- exclude names with umlauts
    pit.assert(
       p_condition => regexp_instr(l_name, C_UMLAUT_REGEX) = 0,
       p_message_name => msg.UTL_NAME_CONTAINS_UMLAUT,
       p_arg_list => msg_args(l_name));

    -- limit length according to naming conventions
    pit.assert(
       p_condition => length(l_name) <= C_MAX_LENGTH,
       p_message_name => msg.UTL_NAME_TOO_LONG,
       p_arg_list => msg_args(l_name, to_char(C_MAX_LENGTH)));

    -- check name against Oracle naming conventions. Throws errors, so catch them rather than use ASSERT
    begin
       l_name := dbms_assert.simple_sql_name(l_name);
    exception
       when others then
          pit.error(msg.UTL_NAME_INVALID, msg_args(l_name));
    end;

    pit.leave_optional(msg_params(msg_param('Result', 'OK')));
    return null;
  exception
    when others then
      l_error_message := substr(sqlerrm, 12);
      pit.leave_optional(msg_params(msg_param('Result', l_error_message)));
      return l_error_message;
  end validate_simple_sql_name;


  procedure set_error(
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null)
  as
  begin
    pit.enter_optional(p_params => msg_params(
      msg_param('p_page_item', p_page_item),
      msg_param('p_message', p_message)));
      
    pit.assert_not_null(p_message);
    
    if p_page_item is not null then
      apex_error.add_error(
        p_message => get_pit_message(p_message, p_msg_args),
        p_display_location => apex_error.c_inline_with_field_and_notif,
        p_page_item_name => get_page_element(p_page_item));
    else
      apex_error.add_error(
        p_message => get_pit_message(p_message, p_msg_args),
        p_display_location => apex_error.c_inline_in_notification);
    end if;
    
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      -- Assertion is violated if no error was passed in. Accept this as a sign that no error has occurred
      pit.leave_optional;
  end set_error;


  procedure set_error(
    p_test in boolean,
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null)
  as
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_test', get_bool(p_test)),
                    msg_param('p_page_item', p_page_item),
                    msg_param('p_message', p_message)));
                    
    if not p_test then
      set_error(p_page_item, p_message, p_msg_args);
    end if;
    
    pit.leave_optional;
  end set_error;


  function inserting
   return boolean
  is
    C_INSERT_WHITELIST constant char_table := char_table('CREATE', 'CREATE_AGAIN', 'INSERT', 'CREATEAGAIN');
    C_INSERT_FLAG constant char(1 byte) := 'C';
    l_result boolean := false;
    l_item_value_convention boolean := g_item_value_convention;
  begin
    pit.enter_optional;
    
    -- Switch item_value_convention off to avoid exceptions when checking C_ROW_STATUS and no IG is present
    g_item_value_convention := false;
    
    $IF utl_apex.ver_le_0500 $THEN
    l_result := get_request member of C_INSERT_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_STATUS in interactive Grid or Form regions (>= 19.1)
    if get_request member of C_INSERT_WHITELIST or get_value(C_ROW_STATUS) = C_INSERT_FLAG then
      l_result := true;
    end if;
    $END
    -- reset item value convention
    g_item_value_convention := l_item_value_convention;
    
    pit.leave_optional(msg_params(msg_param('Result', get_bool(l_result))));
    return l_result;
  end inserting;


  function updating
   return boolean
  is
    C_UPDATE_WHITELIST constant char_table := char_table('SAVE', 'APPLY CHANGES', 'UPDATE', 'UPDATE ROW', 'CHANGE', 'APPLY');
    C_UPDATE_FLAG constant char(1 byte) := 'U';
    l_result boolean := false;
    l_item_value_convention boolean := g_item_value_convention;
  begin
    pit.enter_optional;
    
    -- Switch item_value_convention off to avoid exceptions when checking C_ROW_STATUS and no IG is present
    g_item_value_convention := false;
   
    $IF utl_apex.ver_le_0500 $THEN
    l_result := get_request member of C_UPDATE_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_STATUS in interactive Grid or Form regions (>= 19.1)
    if get_request member of C_UPDATE_WHITELIST or get_value(C_ROW_STATUS) = C_UPDATE_FLAG then
      l_result := true;
    end if;
    $END
    -- rest item value convntion
    g_item_value_convention := l_item_value_convention;
    
    pit.leave_optional(msg_params(msg_param('Result', get_bool(l_result))));
    return l_result;
  end updating;


  function deleting
   return boolean
  is
    C_DELETE_WHITELIST constant char_table := char_table('DELETE', 'REMOVE', 'DELETE ROW', 'DROP');
    C_DELETE_FLAG constant char(1 byte) := 'D';
    l_result boolean := false;
    l_item_value_convention boolean := g_item_value_convention;
  begin
    pit.enter_optional;
    
    -- Switch item_value_convention off to avoid exceptions when checking C_ROW_STATUS and no IG is present
    g_item_value_convention := false;
    
    $IF utl_apex.ver_le_0500 $THEN
    l_result := get_request member of C_DELETE_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_STATUS in interactive Grid or Form regions (>= 19.1)
    if get_request member of C_DELETE_WHITELIST or get_value(C_ROW_STATUS) = C_DELETE_FLAG then
      l_result := true;
    end if;
    $END
    -- rest item value convntion
    g_item_value_convention := l_item_value_convention;
    
    pit.leave_optional(msg_params(msg_param('Result', get_bool(l_result))));
    return l_result;
  end deleting;


  function request_is(
    p_request in varchar2)
    return boolean
  as
    l_result boolean;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_request', p_request)));
    
    l_result := upper(get_request) = upper(p_request);
    
    pit.leave_optional(msg_params(msg_param('Result', get_bool(l_result))));
    return l_result;
  end request_is;


  procedure unhandled_request
  as
  begin
    pit.error(msg.UTL_INVALID_REQUEST, msg_args(get_request));
  end unhandled_request;
  
  
  function get_page_url(
    p_application in varchar2 default null,
    p_page in varchar2 default null,
    p_param_items in varchar2 default null,
    p_value_items in varchar2 default null,
    p_triggering_element in varchar2 default null,
    p_clear_cache in binary_integer default null)
    return varchar2
  as    
    l_url max_sql_char;
    l_param_values char_table;
    l_param_list max_sql_char;
    l_value_list max_sql_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_param_items', p_param_items),
                    msg_param('p_value_items', p_value_items),
                    msg_param('p_application', p_application),
                    msg_param('p_page', p_page),
                    msg_param('p_triggering_element', p_triggering_element)));
    
    l_param_list := replace(p_param_items, ':', ',');
    utl_text.string_to_table(p_value_items, l_param_values);
    for i in 1 .. l_param_values.count loop
      l_value_list := l_value_list || case when i > 1 then ',' end || get_value(l_param_values(i));
    end loop;
    
    l_url := get_url(
               p_application => p_application,
               p_page => p_page,
               p_clear_cache => p_clear_cache,
               p_param_list => l_param_list,
               p_value_list => l_value_list);
               
    pit.leave_optional(p_params => msg_params(msg_param('URL', l_url)));
    return l_url;
  end get_page_url;


  procedure set_page_url(
    p_hidden_item in varchar2,
    p_application in varchar2 default null,
    p_page in varchar2 default null,
    p_param_items in varchar2 default null,
    p_value_items in varchar2 default null)
  as
    l_url varchar2 (4000);
    l_triggering_element max_sql_char := 'apex.jQuery("#' || p_hidden_item || '")';
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_hidden_item', p_hidden_item),
                    msg_param('p_application', p_application),
                    msg_param('p_page', p_page),
                    msg_param('p_param_items', p_param_items),
                    msg_param('p_value_items', p_value_items)));

    l_url := get_page_url(
               p_application => p_application,
               p_page => p_page,
               p_param_items => p_param_items,
               p_value_items => p_value_items,
               p_triggering_element => l_triggering_element);
    set_value(p_hidden_item, l_url);

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('l_url', l_url)));
  end set_page_url;


  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_blob.length', to_char(dbms_lob.getlength(p_blob))),
                    msg_param('p_file_name', p_file_name)));
    
    download_file(p_blob, p_file_name);

    pit.leave_mandatory;
  exception when others then
    htp.p('error: ' || sqlerrm);
    pit.leave_optional;
    stop_apex;
  end download_blob;


  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2)
  as
    l_blob blob;
  begin
    pit.enter_optional;
    l_blob := utl_text.clob_to_blob(p_clob);
    download_blob(l_blob, p_file_name);
    pit.leave_optional;
  end download_clob;
  
  
  procedure stop_apex
  as
  begin
    pit.enter_optional;
    apex_application.stop_apex_engine;
    pit.leave_optional;
  end stop_apex;


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
    pit.enter_optional;
    pit.assert_not_null(p_condition);
    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      pit.log(
        p_message_name => p_message_name,
        p_affected_id => get_page_element(p_affected_id),
        p_arg_list => coalesce(p_arg_list, msg_args(p_affected_id)),
        p_log_threshold => pit.level_error,
        p_module_list => C_PIT_APEX_MODULE);
      pit.leave_optional;
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

begin
  initialize;
end utl_apex;
/