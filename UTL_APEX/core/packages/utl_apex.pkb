create or replace package body utl_apex
as

  -- Private type declarations
  -- Private constant declarations
  C_ROW_DML_ACTION constant ora_name_type := 'APEX$ROW_STATUS';
  C_INSERT constant char(1 byte) := 'C';
  C_UPDATE constant char(1 byte) := 'U';
  C_DELETE constant char(1 byte) := 'D';

  -- Constants for supported APEX form types
  C_PAGE_FORM constant ora_name_type := 'FORM';
  C_FORM_REGION constant ora_name_type := 'NATIVE_FORM';
  C_IG_REGION constant ora_name_type := 'NATIVE_IG';

  -- Templates used for GET_PAGES etc.
  C_TEMPLATE_TYPE constant ora_name_type := 'APEX_FORM';
  C_TEMPLATE_NAME_FRAME constant ora_name_type := 'FORM_FRAME';
  C_TEMPLATE_NAME_COLUMNS constant ora_name_type := 'FORM_COLUMN';

  C_TEMPLATE_MODE_DYNAMIC constant ora_name_type := 'DYNAMIC';

  C_PARAM_GROUP constant ora_name_type := 'UTL_APEX';
  C_ITEM_PREFIX_CONVENTION constant ora_name_type := 'ITEM_PREFIX_CONVENTION';

  C_DATE constant ora_name_type := 'DATE';
  C_DEFAULT constant ora_name_type := 'DEFAULT';

  g_item_value_convention boolean;
  g_item_prefix_convention binary_integer;

  -- HELPER
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
  function get_apex_version
    return number
  as
  begin
    return APEX_VERSION;
  end get_apex_version;


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


  function get_application_id(
    p_ignore_translation in flag_type default C_TRUE)
    return number
  as
    l_application_id apex_applications.application_id%type;
  begin
    if p_ignore_translation = C_TRUE then
      l_application_id := apex_application.g_flow_id;
    else
      l_application_id := coalesce(apex_application.g_translated_flow_id, apex_application.g_flow_id);
    end if;
    return l_application_id;
  end get_application_id;


  function get_application_alias
    return varchar2
  as
  begin
    return apex_application.g_flow_alias;
  end get_application_alias;


  function get_page_id(
    p_ignore_translation in flag_type default C_TRUE)
    return number
  as
    l_page_id apex_application_pages.page_id%type;
  begin
    if p_ignore_translation = C_TRUE then
      l_page_id := apex_application.g_flow_step_id;
    else
      l_page_id := coalesce(apex_application.g_translated_page_id, apex_application.g_flow_step_id);
    end if;
    return l_page_id;
  end get_page_id;


  function get_page_alias
    return varchar2
  as
  begin
    return apex_application.g_page_alias;
  end get_page_alias;


  procedure get_page_element(
    p_page_item in ora_name_type,
    p_item out nocopy item_rec)
  as
    l_application_id number;
    l_page_id number;
    l_page_item ora_name_type;
    l_default_date_format ora_name_type;
    l_default_timestamp_format ora_name_type;
    C_ITEM_NAME_BLACKLIST constant char_table := char_table('APEX$ROW_STATUS');
  begin
    pit.enter_detailed('get_page_element',
      p_params => msg_params(
                    msg_param('p_page_item', p_page_item)));

    l_page_item := upper(p_page_item);
    if l_page_item not like get_page_prefix || '%' then
      l_page_item := get_page_prefix || l_page_item;
    end if;

    if l_page_item member of C_ITEM_NAME_BLACKLIST then
      -- Blacklist items are items which cannot be seen in the APEX data dictionary
      -- Just pass their name and value back
      p_item.item_name := p_page_item;
      p_item.item_value := apex_util.get_session_state(p_page_item);
    else
      l_application_id := get_application_id;
      l_page_id := get_page_id;
      l_default_date_format := get_default_date_format;
      l_default_timestamp_format := get_default_timestamp_format;
      
      pit.debug(msg.PIT_PASS_MESSAGE, msg_args('App: ' || l_application_id || ', Page: ' || l_page_id || ', Item: ' || p_page_item));

      select item_name, label, format_mask, apex_util.get_session_state(item_name), C_FALSE, region_id, null
        into p_item.item_name, p_item.item_label, p_item.format_mask, p_item.item_value, p_item.is_column, p_item.region_id, p_item.item_alias
        from apex_application_page_items
       where application_id = l_application_id
         and page_id = l_page_id
         and item_name = l_page_item
      union all
      select name, heading,
             coalesce(
              format_mask,
              case
                when instr(data_type, 'DATE') > 0 then l_default_date_format
                when instr(data_type, 'TIMESTAMP') > 0 then l_default_timestamp_format
              end) format_mask,
             apex_util.get_session_state(name), C_TRUE, region_id, column_id
        from apex_appl_page_ig_columns
       where application_id = l_application_id
         and page_id = l_page_id
         and name = upper(p_page_item); -- IG columns without page prefix
    end if;

    pit.leave_detailed(
      p_params => msg_params(
                    msg_param('item_name', p_item.item_name),
                    msg_param('item_label', p_item.item_label),
                    msg_param('format_mask', p_item.format_mask),
                    msg_param('item_value', substr(p_item.item_value, 1, 200))));
  exception
    when NO_DATA_FOUND then
      pit.leave_detailed(
        p_params => msg_params(
                      msg_param('Result', 'No item found')));
  end get_page_element;


  function get_page_element(
    p_page_item in ora_name_type)
    return item_rec
  as
    l_item_rec item_rec;
  begin
    get_page_element(p_page_item, l_item_rec);
    return l_item_rec;
  end get_page_element;


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
    return apex_application.g_date_format;
  end get_default_date_format;


  function get_default_timestamp_format(
    p_application_id in number default null)
    return varchar2
  as
    l_timestamp_format apex_applications.timestamp_format%type;
  begin
    return apex_application.g_timestamp_format;
  end get_default_timestamp_format;


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
    l_result flag_type;
  begin
    if p_bool then
      l_result := C_TRUE;
    else
      l_result := C_FALSE;
    end if;
    return l_result;
  end get_bool;


  function get_bool(
    p_bool in flag_type)
    return boolean
  as
  begin
    return p_bool = C_TRUE;
  end get_bool;


  function to_bool(
    p_value in varchar2)
    return flag_type
  as
    l_value varchar(10);
    l_result flag_type;
  begin
    l_value := upper(p_value);
    if l_value in ('J', 'Y', '1') then
      l_result := C_TRUE;
    else
      l_result := C_FALSE;
    end if;
    return l_result;
  end to_bool;


  function get_number(
      p_page_item in varchar2)
      return number
  is
    l_number number;
    l_item item_rec;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_page_item', p_page_item)));

    -- Initialization
    get_page_element(p_page_item, l_item);

    l_number := to_number(l_item.item_value, replace(coalesce(l_item.format_mask, utl_apex.NUMBER_FORMAT_MASK), apex_application.get_nls_group_separator, null));

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('Value', l_number)));
    return l_number;
  exception
    when others then
      pit.handle_exception(msg.IMPOSSIBLE_CONVERSION, msg_args(l_item.item_value, l_item.format_mask, 'NUMBER'));
      return null;
  end get_number;


  function get_date(
    p_page_item in varchar2)
    return date
  is
    l_date date;
    l_item item_rec;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_page_item', p_page_item)));

    -- Initialization
    get_page_element(p_page_item, l_item);

    -- Conversion
    begin
      l_date := to_date(l_item.item_value, coalesce(l_item.format_mask, utl_apex.get_default_date_format));
    exception when others then
      l_date := to_timestamp_tz(l_item.item_value, apex_application.g_nls_date_format);
    end;

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('Value', to_char(l_date, utl_apex.get_default_date_format))));
    return l_date;
  exception
    when others then
      pit.handle_exception(msg.IMPOSSIBLE_CONVERSION, msg_args(l_item.item_value, l_item.format_mask, 'DATE'));
      return null;
  end get_date;


  function get_timestamp(
    p_page_item in varchar2)
    return timestamp
  as
    l_timestamp timestamp;
    l_timestamp_tz timestamp with time zone;
    l_item item_rec;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_page_item', p_page_item)));

    -- Initialization
    get_page_element(p_page_item, l_item);


    -- CONVERSION
    begin
      l_timestamp := to_timestamp(l_item.item_value, l_item.format_mask);
    exception when others then
      begin
        l_timestamp := to_timestamp_tz(l_item.item_value, l_item.format_mask);
      exception when others then
        l_timestamp_tz := to_timestamp_tz(l_item.item_value, apex_application.g_nls_timestamp_tz_format);
      end;
    end;

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('Value', to_char(coalesce(l_timestamp, l_timestamp_tz), utl_apex.get_default_timestamp_format))));
    return coalesce(l_timestamp, l_timestamp_tz);
  exception
    when others then
      pit.handle_exception(msg.IMPOSSIBLE_CONVERSION, msg_args(l_item.item_value, l_item.format_mask, 'TIMESTAMP'));
      return null;
  end get_timestamp;


  function get_value(
    p_page_item in varchar2)
    return varchar2
  as
    l_item item_rec;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_page_item', p_page_item)));

    get_page_element(p_page_item, l_item);

    if l_item.item_value is null and g_item_value_convention then
      pit.assert_exists(l_item.item_name, msg.PAGE_ITEM_MISSING, msg_args(p_page_item));
    end if;

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('Value', substr(l_item.item_value, 1, 200))));
    return l_item.item_value;
  exception
    when msg.PAGE_ITEM_MISSING_ERR then
      pit.handle_exception(msg.SQL_ERROR);
      raise;
  end get_value;


  procedure set_value(
    p_page_item in varchar2,
    p_value in varchar2)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_page_item', p_page_item),
                    msg_param('p_value', substr(p_value, 1, 200))));

    apex_util.set_session_state(p_page_item, p_value);

    pit.leave_mandatory;
  exception
    when others then
      pit.leave_mandatory;
      pit.error(msg.PAGE_ITEM_MISSING, msg_args(p_page_item));
  end set_value;


  function get_app_value(
    p_app_item in varchar2)
    return varchar2
  as
    l_value max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_app_item', p_app_item)));

    l_value := apex_util.get_session_state(p_app_item);

    pit.leave_mandatory;
    return l_value;
  end get_app_value;

  procedure set_app_value(
    p_app_item in varchar2,
    p_value in varchar2)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_app_item', p_app_item),
                    msg_param('p_value', substr(p_value, 1, 200))));

    apex_util.set_session_state(p_app_item, p_value);

    pit.leave_mandatory;
  end set_app_value;


  procedure set_success_message(
    p_message in ora_name_type,
    p_msg_args in msg_args default null)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_message', p_message)));

    apex_application.g_print_success_message := pit.get_message_text(p_message, p_msg_args);

    pit.leave_mandatory;
  end set_success_message;


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


  function current_user_in_group(
    p_group_name in varchar2)
    return utl_apex.flag_type
  is
  begin
    return get_bool(apex_util.current_user_in_group(p_group_name));
  end current_user_in_group;


  function get_last_login
    return date
  as
    l_last_login_date date;
  begin
    pit.enter_detailed;

    select min(access_date) access_date
      into l_last_login_date
      from (select access_date, rank() over (order by access_date desc) rang
              from wwv_flow_user_access_log
             where authentication_result = 0
               and login_name = (select v('APP_USER') from dual));

     pit.leave_detailed(
        p_params => msg_params(
                      msg_param('LastLogin', to_char(l_last_login_date, 'dd.mm.yyyy hh24:mi:ss'))));
     return l_last_login_date;
  exception
    when no_data_found then
      pit.leave_detailed;
      return null;
  end get_last_login;


  function get_page_items(
    p_view_name in ora_name_type,
    p_static_id in varchar2,
    p_application_id in number,
    p_page_id in number,
    p_only_columns in flag_type default null)
    return utl_apex_page_item_tab
    pipelined
  as
    l_form_type ora_name_type;
    l_view_name ora_name_type;
    C_STMT constant max_sql_char := q'^
select d.page_items
  from #VIEW_NAME# d
 where application_id = #APP_ID#
   and page_id = #PAGE_ID#
   and decode(static_id, '#STATIC_ID#', 1, null, 1, 0) = 1
   and (is_column_based = '#ONLY_COLUMNS#' or '#ONLY_COLUMNS#' is null)^';
    l_stmt max_char;
    l_cur sys_refcursor;
    l_row utl_apex_page_item_t;
    l_row_count number := 0;
  begin
    pit.enter_detailed(
      p_params => msg_params(
                    msg_param('p_view_name', p_view_name),
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_application_id', p_application_id),
                    msg_param('p_page_id', p_page_id),
                    msg_param('p_only_columns', p_only_columns)));

    l_stmt := utl_text.bulk_replace(C_STMT, char_table(
                'VIEW_NAME', p_view_name,
                'APP_ID', p_application_id,
                'PAGE_ID', p_page_id,
                'STATIC_ID', p_static_id,
                'ONLY_COLUMNS', case when p_only_columns is not null then C_TRUE end));

    open l_cur for l_stmt;
    fetch l_cur into l_row;
    while l_cur%FOUND loop
      l_row_count := l_row_count + 1;
      pipe row (l_row);
      fetch l_cur into l_row;
    end loop;

    pit.leave_detailed(
      p_params => msg_params(
                    msg_param('Rows piped', l_row_count)));
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
       and upper(static_id) = upper(p_static_id)
       and source_type_code in (C_FORM_REGION, C_IG_REGION);

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
        from table(get_page_items(p_view_name, p_static_id, p_application_id, p_page_id, C_TRUE));

    l_application_id number := get_application_id;
    l_page_id number := get_page_id;
    l_view_name ora_name_type;
    page_values page_value_t;
    l_key_list max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_format', p_format)));

    l_view_name := get_view_name(
                     p_static_id => p_static_id,
                     p_application_id => l_application_id,
                     p_page_id => l_page_id);

    if l_view_name is not null then
      for itm in page_item_cur(l_view_name, p_static_id, l_application_id, l_page_id) loop
        l_key_list := l_key_list || itm.item_name || ',';
        case p_format
        when FORMAT_JSON then
          page_values(itm.item_name) := apex_escape.json(apex_util.get_session_state(itm.page_item_name));
        when FORMAT_HTML then
          page_values(itm.item_name) := apex_escape.html(apex_util.get_session_state(itm.page_item_name));
        else
          page_values(itm.item_name) := apex_util.get_session_state(itm.page_item_name);
        end case;
      end loop;

      l_key_list := rtrim(l_key_list, ',');
      pit.debug(msg.PIT_PASS_MESSAGE, msg_args('... get_page_values: ' || page_values.COUNT || ' page item values read: ' || l_key_list));
    else
      pit.warn(msg.PIT_PASS_MESSAGE, msg_args('No View name found'));
    end if;

    pit.leave_optional(msg_params(msg_param('Result', to_char(page_values.count) || ' Item values')));
    return page_values;
  end get_page_values;


  function get_page_record(
    p_static_id in varchar2 default null,
    p_table_name in varchar2 default null)
    return varchar2
  as
    l_view_name ora_name_type;
    l_script max_char;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_static_id', p_static_id),
                    msg_param('p_table_name', p_table_name)));

    l_view_name := get_view_name(
                     p_static_id => p_static_id,
                     p_application_id => get_application_id,
                     p_page_id => get_page_id);

    with params as(
             select C_TEMPLATE_MODE_DYNAMIC uttm_mode,
                    get_default_date_format(get_application_id) date_format,
                    'l_row_rec' record_name,
                    p_table_name table_name
               from dual),
           templates as (
             select uttm_text template, uttm_mode
               from utl_text_templates
              where uttm_name in (C_TEMPLATE_NAME_COLUMNS, C_TEMPLATE_NAME_FRAME)
                and uttm_type = C_TEMPLATE_TYPE),
           data as (
             select *
               from table(utl_apex.get_page_items(l_view_name, p_static_id, get_application_id, get_page_id, C_TRUE)) c),
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

    pit.leave_optional(msg_params(msg_param('Result', l_script)));
    return l_script;
  end get_page_record;


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

    l_value := p_page_values(upper(p_element_name));

    pit.leave_optional(msg_params(msg_param('Result', l_value)));
    return l_value;
  exception
    when NO_DATA_FOUND then
      pit.leave_optional(msg_params(msg_param('Error', p_element_name || ' not found')));
      pit.error(msg.UTL_APEX_MISSING_ITEM, msg_args(p_element_name, to_char(get_page_id)));
      -- unreachable code to avoid compiler warning
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
       p_msg_args => msg_args(l_name));

    -- limit length according to naming conventions
    pit.assert(
       p_condition => length(l_name) <= C_MAX_LENGTH,
       p_message_name => msg.UTL_NAME_TOO_LONG,
       p_msg_args => msg_args(l_name, to_char(C_MAX_LENGTH)));

    -- name against Oracle naming conventions. Throws errors, so catch them rather than use ASSERT
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
    p_message in ora_name_type default null,
    p_msg_args in msg_args default null,
    p_region_id in ora_name_type default null)
  as
    l_message message_type;
    l_rownum number;
    l_application_id number;
    l_page_id number;
    l_primary_key max_char;
    l_region_Id number;
    l_source_type ora_name_type;
    l_item item_rec;
  begin
    pit.enter_optional(p_params => msg_params(
      msg_param('p_page_item', p_page_item),
      msg_param('p_message', p_message)));

    if p_page_item is not null then
      get_page_element(p_page_item, l_item);
    end if;
    if p_message is null then
      l_message := pit.get_active_message;
    else
      l_message := pit.get_message(p_message, p_msg_args);
    end if;
    l_message.message_text := replace(l_message.message_text, '#LABEL#', l_item.item_label);

    case
      when p_region_id is not null then
        -- Detect type of region to adjust the error message
        l_application_id := get_application_id;
        l_page_id := get_page_id;

        select r.region_id, r.source_type_code, apex_util.get_session_state(i.primary_key_item)
          into l_region_Id, l_source_type, l_primary_key
          from apex_application_page_regions r
          left join (
               select region_id, source_expression primary_key_item
                 from apex_appl_page_ig_columns
                where application_id = l_application_id
                  and page_id = l_page_id
                  and is_primary_key = 'Yes') i
            on r.region_id = i.region_id
         where application_id = l_application_id
           and page_id = l_page_id
           and static_id = p_region_id;

        case l_source_type
          when C_IG_REGION then
            pit.debug(msg.PIT_PASS_MESSAGE, msg_args('... handling error for Interactive Grid'));
            wwv_flow_error.add_error(
              p_message => l_message.message_text,
              p_additional_info => l_message.message_description,
              p_display_location => apex_error.c_inline_with_field_and_notif,
              p_region_id => l_region_id,
              p_column_name => l_item.item_name,
              p_model_instance_id => null,
              p_model_record_id => l_primary_key);
        else
          -- Fallback, works as if P_REGION_ID is NULL
          if p_page_item is not null then
            apex_error.add_error(
              p_message => replace(l_message.message_text, '#LABEL#', l_item.item_label),
              p_additional_info => l_message.message_description,
              p_display_location => apex_error.c_inline_with_field_and_notif,
              p_page_item_name => l_item.item_name);
          else
            apex_error.add_error(
              p_message => l_message.message_text,
              p_additional_info => l_message.message_description,
              p_display_location => apex_error.c_inline_in_notification);
          end if;
        end case;
      when p_page_item is not null then
        apex_error.add_error(
          p_message => replace(l_message.message_text, '#LABEL#', l_item.item_label),
          p_additional_info => l_message.message_description,
          p_display_location => apex_error.c_inline_with_field_and_notif,
          p_page_item_name => l_item.item_name);
      else
        apex_error.add_error(
          p_message => l_message.message_text,
          p_additional_info => l_message.message_description,
          p_display_location => apex_error.c_inline_in_notification);
    end case;

    pit.leave_optional;
  exception
    when msg.ASSERT_IS_NOT_NULL_ERR then
      -- Assertion is violated if no error was passed in. Accept this as a sign that no error has occurred
      pit.leave_optional;
  end set_error;


  procedure set_error(
    p_test in boolean,
    p_page_item in ora_name_type,
    p_message in ora_name_type default null,
    p_msg_args in msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_test', get_bool(p_test)),
                    msg_param('p_page_item', p_page_item),
                    msg_param('p_message', p_message)));

    if not p_test then
      set_error(p_page_item, p_message, p_msg_args, p_region_id);
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

    -- Switch item_value_convention off to avoid exceptions when checking C_ROW_DML_ACTION and no IG is present
    g_item_value_convention := false;

    $IF utl_apex.ver_le_0500 $THEN
    l_result := get_request member of C_INSERT_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_DML_ACTION in interactive Grid or Form regions (>= 19.1)
    -- CAVE: Don't refactor to GET_VALUE instead of APEX_UTIL.GET_SESSION_STATE as C_ROW_DML_ACTION is no page item
    if get_request member of C_INSERT_WHITELIST or apex_util.get_session_state(C_ROW_DML_ACTION) = C_INSERT_FLAG then
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

    -- Switch item_value_convention off to avoid exceptions when checking C_ROW_DML_ACTION and no IG is present
    g_item_value_convention := false;

    $IF utl_apex.ver_le_0500 $THEN
    l_result := get_request member of C_UPDATE_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_DML_ACTION in interactive Grid or Form regions (>= 19.1)
    -- CAVE: Don't refactor to GET_VALUE instead of APEX_UTIL.GET_SESSION_STATE as C_ROW_DML_ACTION is no page item
    if get_request member of C_UPDATE_WHITELIST or apex_util.get_session_state(C_ROW_DML_ACTION) = C_UPDATE_FLAG then
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

    -- Switch item_value_convention off to avoid exceptions when checking C_ROW_DML_ACTION and no IG is present
    g_item_value_convention := false;

    $IF utl_apex.ver_le_0500 $THEN
    l_result := get_request member of C_DELETE_WHITELIST;
    $ELSE
    -- Starting with version 5.1, insert might be detected by using C_ROW_DML_ACTION in interactive Grid or Form regions (>= 19.1)
    -- CAVE: Don't refactor to GET_VALUE instead of APEX_UTIL.GET_SESSION_STATE as C_ROW_DML_ACTION is no page item
    if get_request member of C_DELETE_WHITELIST or apex_util.get_session_state(C_ROW_DML_ACTION) = C_DELETE_FLAG then
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
    p_value_list in varchar2 default null,
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
    if p_value_items is not null then
      utl_text.string_to_table(p_value_items, l_param_values);
      for i in 1 .. l_param_values.count loop
        l_value_list := l_value_list || case when i > 1 then ',' end || get_value(l_param_values(i));
      end loop;
    else
      l_value_list := p_value_list;
    end if;

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


  procedure set_clob(
    p_value in clob,
    p_collection in varchar2 := 'CLOB_CONTENT')
  as
  begin
    pit.enter_optional(
        p_params => msg_params(
                      msg_param('p_value', dbms_lob.substr(p_value, 200, 1)),
                      msg_param('p_collection', p_collection)));

    if apex_collection.collection_exists(
         p_collection_name => p_collection) then
      apex_collection.delete_collection(
        p_collection_name => p_collection);
    end if;

    if dbms_lob.getlength(p_value) > 0 then
      apex_collection.create_or_truncate_collection(
        p_collection_name => p_collection);
      apex_collection.add_member(
        p_collection_name => p_collection,
        p_clob001 => p_value);
    end if;

    pit.leave_optional;
  end set_clob;


  procedure stop_apex
  as
  begin
    pit.enter_optional;
    apex_application.stop_apex_engine;
    pit.leave_optional;
  end stop_apex;


  procedure assert(
    p_condition in boolean,
    p_message_name in ora_name_type default msg.ASSERT_TRUE,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  is
  begin
    pit.enter_optional;
    pit.assert(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert;


  procedure assert_is_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional;
    pit.assert_is_null(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_is_null;


  procedure assert_is_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional;
    pit.assert_is_null(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_is_null;


  procedure assert_is_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional;
    pit.assert_is_null(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_is_null;


  procedure assert_not_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional;
    pit.assert_not_null(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_not_null;


  procedure assert_not_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional;
    pit.assert_not_null(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_not_null;


  procedure assert_not_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  as
  begin
    pit.enter_optional;
    pit.assert_not_null(
      p_condition => p_condition,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_not_null;


  procedure assert_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_EXISTS,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  is
  begin
    pit.enter_optional;
    pit.assert_exists(
      p_stmt => p_stmt,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_exists;


  procedure assert_not_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_NOT_EXISTS,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null)
  is
  begin
    pit.enter_optional;
    pit.assert_not_exists(
      p_stmt => p_stmt,
      p_message_name => p_message_name,
      p_msg_args => p_msg_args);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_not_exists;


  procedure assert_datatype(
    p_value in varchar2,
    p_type in varchar2,
    p_format_mask in varchar2 default null,
    p_message_name in ora_name_type default msg.ASSERT_DATATYPE,
    p_page_item in ora_name_type default null,
    p_msg_args msg_args default null,
    p_region_id in ora_name_type default null,
    p_accept_null in boolean default true)
  as
  begin
    pit.enter_optional;
    pit.assert_datatype(
      p_value => p_value,
      p_type => p_type,
      p_format_mask => p_format_mask,
      p_message_name => p_message_name,
      p_msg_args => coalesce(p_msg_args, msg_args(p_value, p_type)),
      p_accept_null => p_accept_null);
    pit.leave_optional;
  exception
    when others then
      set_error(
        p_page_item => p_page_item,
        p_message => p_message_name,
        p_region_id => p_region_id);
      pit.leave_optional;
  end assert_datatype;


  procedure handle_bulk_errors(
    p_mapping in char_table default null)
  as
    type error_code_map_t is table of ora_name_type index by ora_name_type;
    l_error_code_map error_code_map_t;
    l_error_code ora_name_type;
    l_message_list pit_message_table;
    l_message message_type;
    l_item item_rec;
  begin
    pit.enter_optional;
    l_message_list := pit.get_message_collection;

    if l_message_list.count > 0 then
      -- copy p_mapping to pl/sql table to allow for easy access using EXISTS method
      if p_mapping is not null then
        for i in 1 .. p_mapping.count loop
          if mod(i, 2) = 1 then
            l_error_code_map(upper(p_mapping(i))) := upper(p_mapping(i+1));
          end if;
        end loop;
      end if;

      for i in 1 .. l_message_list.count loop
        l_message := l_message_list(i);
        if l_message.severity in (pit.level_fatal, pit.level_error) then
          pit.verbose(msg.PIT_PASS_MESSAGE, msg_args('Error occured'));
          l_error_code := upper(l_message.error_code);
          if l_error_code_map.exists(l_error_code) then
            pit.verbose(msg.PIT_PASS_MESSAGE, msg_args('Error code found, retrieve item information'));
            get_page_element(l_error_code_map(l_error_code), l_item);
            if get_bool(l_item.is_column) then
              apex_error.add_error(
                p_message => replace(l_message.message_text, '#LABEL#', l_item.item_label),
                p_additional_info => l_message.message_description,
                p_display_location => apex_error.c_inline_with_field_and_notif,
                p_region_id => l_item.region_id,
                p_column_alias => l_item.item_alias,
                p_row_num => 2);
            else
              apex_error.add_error(
                p_message => replace(l_message.message_text, '#LABEL#', l_item.item_label),
                p_additional_info => l_message.message_description,
                p_display_location => apex_error.c_inline_with_field_and_notif,
                p_page_item_name => 'C' || l_item.item_name);
            end if;
          else
            pit.verbose(msg.PIT_PASS_MESSAGE, msg_args('No mapping found'));
            apex_error.add_error(
              p_message => l_message.message_text,
              p_additional_info => l_message.message_description,
              p_display_location => apex_error.c_inline_in_notification);
          end if;
        end if;
      end loop;
    end if;

    pit.leave_optional;
  end handle_bulk_errors;


  procedure print(
    p_value in clob,
    p_line_feed in boolean default false)
  as
    C_CHUNK_SIZE binary_integer := 8196;
    l_locator binary_integer := 1;
    l_amount_read binary_integer := C_CHUNK_SIZE;
    l_chunk max_char;
  begin
    pit.enter_optional;
    while not l_amount_read < C_CHUNK_SIZE and p_value is not null loop
      dbms_lob.read(
        lob_loc => p_value,
        amount => l_amount_read,
        offset => l_locator,
        buffer => l_chunk);
      if p_line_feed then
        htp.print(l_chunk);
      else
        htp.prn(l_chunk);
      end if;
      l_locator := l_locator + l_amount_read;
    end loop;
    pit.leave_optional;
  end print;


  procedure escape_json(
    p_text in out nocopy clob)
  as
    l_result clob;
    l_chunk max_char;
    -- Chunk size shouldn't exceed a quarter of max size because of UTF-8
    l_chunk_size integer := 8191;
    l_idx number := 1;
    l_length number;
  begin
    l_length := dbms_lob.getlength(p_text);
    dbms_lob.createtemporary(l_result, false, dbms_lob.call);
    while l_idx <= l_length loop
      l_chunk := dbms_lob.substr(p_text, l_chunk_size, l_idx);
      l_chunk := trim('''' from apex_escape.js_literal(l_chunk));
      dbms_lob.append(l_result, l_chunk);
      l_idx := l_idx + l_chunk_size;
    end loop;
    p_text := l_result;
  end escape_json;

  function escape_json(
    p_text in clob)
    return clob
  as
    l_result clob;
  begin
    l_result := p_text;
    escape_json(l_result);
    return l_result;
  end escape_json;

begin
  initialize;
end utl_apex;
/