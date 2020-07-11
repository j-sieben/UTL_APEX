create or replace package body utl_dev_apex
as

  C_APEX_TMPL_TYPE constant utl_apex.ora_name_type := 'APEX_COLLECTION';
  C_DEFAULT constant utl_apex.ora_name_type := 'DEFAULT';
  C_CR constant varchar2(2) := chr(10);
  
  -- Constants for supported APEX form types
  C_PAGE_FORM constant utl_apex.ora_name_type := 'FORM';
  C_FORM_REGION constant utl_apex.ora_name_type := 'NATIVE_FORM';
  C_IG_REGION constant utl_apex.ora_name_type := 'NATIVE_IG';  
  
  /********* HELPER **********/  /** Method to decide upon the view name based on the form type detected on the page for this combination of parameters
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
    l_form_type utl_apex.ora_name_type;
    l_view_name utl_apex.ora_name_type;
    C_VIEW_FETCH_ROW constant utl_apex.ora_name_type := 'utl_apex_fetch_row_columns';
    C_VIEW_FORM constant utl_apex.ora_name_type := 'utl_apex_form_region_columns';
    C_VIEW_IG constant utl_apex.ora_name_type := 'utl_apex_ig_columns';
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
  
  
  /** Method to create a script to get the values of the page items.
   * @param  p_uttm_mode      Template mode. Either DYNAMIC or STATIC
   * @param  p_static_id      Static ID of the form or editable grid
   * @param  p_application_id  ID of the application
   * @param  p_page_id         Numeric ID of the page
   * @param [p_table_name]     Name of the underlying table. Only required if legacy forms are used     
   * @param [p_record_name]    Name of the record to return. Only
   * @return Script that contains a PL/SQL block to be either directly executed, returning a record, or a script that may
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
    p_application_id in number default utl_apex.get_application_id,
    p_page_id in number default utl_apex.get_page_id,
    p_record_name in varchar2 default 'l_row_rec')
    return utl_apex.max_char
  as
    l_script clob;
    l_view_name utl_apex.ora_name_type;
    -- Templates used for GET_PAGES etc.
    C_TEMPLATE_TYPE constant utl_apex.ora_name_type := 'APEX_FORM';
    C_TEMPLATE_NAME_FRAME constant utl_apex.ora_name_type := 'FORM_FRAME';
    C_TEMPLATE_NAME_COLUMNS constant utl_apex.ora_name_type := 'FORM_COLUMN';
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
                    utl_apex.get_default_date_format(p_application_id) date_format,
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
               from table(utl_apex.get_page_items(l_view_name, p_static_id, p_application_id, p_page_id, utl_apex.C_TRUE)) c),
           tab_name as (
             select max(table_name) table_name
               from data)
    select /*+ no_merge (p)*/
           utl_text.generate_text(cursor(
             select t.template, coalesce(t.table_name, p.table_name) table_name, p.record_name,
                    utl_text.generate_text(cursor(
                      select t.template, d.column_name, d.source_name, 
                             coalesce(d.format_mask, case d.data_type when 'DATE' then p.date_format end)  format_mask
                        from data d
                        join templates t
                          on case when d.data_type in ('NUMBER', 'DATE') then d.data_type else C_DEFAULT end = t.uttm_mode
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
  
  
  /************ INTERFACE **********/
  procedure create_session(
    p_app_id in apex_applications.application_id%type,
    p_app_page_id in apex_application_pages.page_id%type default 1,
    p_app_user in apex_workspace_activity_log.apex_user%type)
  as
    $IF utl_apex.ver_le_05 $THEN
    l_workspace_id apex_applications.workspace_id%type;
    l_cgivar_name owa.vc_arr;
    l_cgivar_val owa.vc_arr;
    $END
  begin
    if apex_application.g_instance is null then
      $IF utl_apex.ver_le_05 $THEN
      htp.init;
    
      l_cgivar_name(1) := 'REQUEST_PROTOCOL';
      l_cgivar_val(1) := 'HTTP';
    
      owa.init_cgi_env(
        num_params => 1,
        param_name => l_cgivar_name,
        param_val => l_cgivar_val );
    
      select workspace_id
        into l_workspace_id
        from apex_applications
       where application_id = p_app_id;
    
      wwv_flow_api.set_security_group_id(l_workspace_id);
    
      apex_application.g_instance := 1;
      apex_application.g_flow_id := p_app_id;
      apex_application.g_flow_step_id := p_app_page_id;
    
      apex_custom_auth.post_login(
        p_uname => p_app_user,
        p_session_id => null, -- could use APEX_CUSTOM_AUTH.GET_NEXT_SESSION_ID
        p_app_page => apex_application.g_flow_id||':'||p_app_page_id);
      $ELSE
      apex_session.create_session(p_app_id, p_app_page_id, p_app_user);
      $END
    end if;
  end create_session;
  
  
  procedure drop_session
  as
  begin
    rollback;
    $IF utl_apex.ver_le_05 $THEN
    $ELSE
    if apex_application.g_instance is not null then
      apex_session.delete_session;
    end if;
    commit;
    $END
  end drop_session;
  
  
  procedure init_owa
  as
    l_cgivar_name owa.vc_arr;
    l_cgivar_value owa.vc_arr;
  begin
    htp.init;
    l_cgivar_name(1) := 'REQUEST_PROTOCOL';
    l_cgivar_value(1) := 'HTTP';
    owa.init_cgi_env(
      num_params => 1,
      param_name => l_cgivar_name,
      param_val => l_cgivar_value);
  end init_owa;
  

  function get_table_api(
    p_table_name in utl_apex.ora_name_type,
    p_short_name in utl_apex.ora_name_type,
    p_owner in utl_apex.ora_name_type default user,
    p_pk_insert in utl_apex.flag_type default utl_apex.c_true,
    p_pk_columns in char_table default null,
    p_exclude_columns in char_table default null)
    return clob
  as
    C_UTTM_TYPE constant utl_apex.ora_name_type := 'TABLE_API';
    C_COLUMN constant utl_apex.ora_name_type := 'COLUMN';
    l_clob clob;
    l_column_list utl_dev_apex_col_tab;
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_table_name', p_table_name),
                    msg_param('p_short_name', p_short_name),
                    msg_param('p_owner', p_owner),
                    msg_param('p_pk_insert', p_pk_insert)));
      
    -- check input parameters
    pit.assert_not_null(p_table_name, msg.UTL_PARAMETER_REQUIRED, msg_args('P_TABLE_NAME'));
    pit.assert_not_null(p_short_name, msg.UTL_PARAMETER_REQUIRED, msg_args('P_SHORT_NAME'));
    
    -- buffer column list in local variable for better performance on large data dictionaries
      with params as (
           -- Get input params and templates
           select upper(p_owner) owner,
                  upper(p_table_name) table_name,
                  coalesce(p_exclude_columns, char_table()) exclude_columns,
                  coalesce(p_pk_columns, char_table()) pk_columns
             from dual)
    select cast(multiset(
             select utl_dev_apex_col_t(
                      lower(col.column_name), 
                      max(length(col.column_name)) over (),
                      case when coalesce(con.column_name, pk.col_name) is not null then utl_apex.C_TRUE else utl_apex.C_FALSE end)
               from all_tab_columns col
               join params p
                 on col.owner = p.owner
                and col.table_name = p.table_name
               -- get list of pk columns. In case of a table we can read them from the data dictionary, otherwise from P_PK_COLUMNS
               left join (
                    -- list of pk columns from data dictionary
                    select col.owner, col.table_name, col.column_name
                      from all_cons_columns col 
                      join all_constraints con
                        on col.owner = con.owner
                       and col.table_name = con.table_name
                       and col.constraint_name = con.constraint_name
                     where con.constraint_type = 'P') con
                 on col.owner = con.owner
                and col.table_name = con.table_name
                and col.column_name = con.column_name
               left join (
                    -- list of pk columns from P_PK_COLUMNS
                    -- Don't refactor COL_NAME to COLUMN_NAME, as this leads to a strange Oracle error
                    select upper(column_value) col_name
                      from table(select pk_columns from params)) pk
                 on col.column_name = pk.col_name
               left join (
                    select upper(column_value) column_name
                      from table(select exclude_columns from params)) ec
                 on col.column_name = ec.column_name
              where ec.column_name is null
              order by col.column_id) as utl_dev_apex_col_tab)
         into l_column_list
         from dual;
    
    -- generate method list
      with params as (
           -- Get input params and templates
           select lower(p_table_name) table_name,
                  lower(p_short_name) short_name,
                  p_pk_insert pk_insert,
                  uttm_name, uttm_mode, uttm_text
             from utl_text_templates
            where uttm_type = C_UTTM_TYPE)
    select /*+ no_merge (column_data) */
           utl_text.generate_text(cursor(
             -- generate method specs and implementation
             select uttm_text template, table_name, short_name,
                    utl_text.generate_text(cursor(
                      -- generate explicit param list including PK
                      select uttm_text template,
                             rpad(column_name, max_length, ' ') column_name_rpad,
                             column_name
                        from table(l_column_list)
                       cross join params
                       where uttm_name = C_COLUMN
                         and uttm_mode = 'PARAM_LIST'), ',' || C_CR, 4) param_list,
                    utl_text.generate_text(cursor(
                      -- generate code to copy parameter values to record instance
                      select uttm_text template,
                             column_name
                        from table(l_column_list)
                       cross join params
                       where uttm_name = C_COLUMN
                         and uttm_mode = 'RECORD_LIST'), ';' || C_CR, 4) record_list,
                    utl_text.generate_text(cursor(
                      -- generate list of PK columns for delete
                      select uttm_text template,
                             column_name
                        from table(l_column_list)
                       cross join params
                       where uttm_name = C_COLUMN
                         and uttm_mode = 'PK_LIST'
                         and is_pk = utl_apex.C_TRUE), C_CR || '       and ') pk_list,
                    utl_text.generate_text(cursor(
                      -- generate merge statement
                      select uttm_text template,
                             table_name,
                             short_name,
                             utl_text.generate_text(cursor(
                               -- generate using clause (parameter to columns)
                               select uttm_text template,
                                      column_name
                                 from table(l_column_list)
                                cross join params
                                where uttm_name = C_COLUMN
                                  and uttm_mode = 'USING_LIST'), ',' || C_CR, 18) using_list,
                             utl_text.generate_text(cursor(
                               -- generate list of PK columns for on clause
                               select uttm_text template,
                                      column_name
                                 from table(l_column_list)
                                cross join params
                                where uttm_name = C_COLUMN
                                  and uttm_mode = 'ON_LIST'
                                  and is_pk = utl_apex.C_TRUE), C_CR || '       and ') on_list,
                             utl_text.generate_text(cursor(
                               -- generate list of update columns (w/o PK list)
                               select uttm_text template,
                                      column_name
                                 from table(l_column_list)
                                cross join params
                                where uttm_name = C_COLUMN
                                  and uttm_mode = 'UPDATE_LIST'
                                  and is_pk = utl_apex.C_FALSE), ',' || C_CR, 12) update_list,
                             utl_text.generate_text(cursor(
                               -- generate column list for insert clause
                               select uttm_text template,
                                      column_name
                                 from table(l_column_list)
                                cross join params
                                where uttm_name = C_COLUMN
                                  and uttm_mode = 'COL_LIST'
                                  and is_pk in (utl_apex.C_FALSE, pk_insert)), ',', 1) col_list,
                             utl_text.generate_text(cursor(
                               -- generate list of insert columns
                               select uttm_text template,
                                      column_name
                                 from table(l_column_list)
                                cross join params
                                where uttm_name = C_COLUMN
                                  and uttm_mode = 'INSERT_LIST'
                                  and is_pk in (utl_apex.C_FALSE, pk_insert)), ',', 1) insert_list
                        from params
                       where uttm_name = 'MERGE'
                         and uttm_mode = C_DEFAULT)) merge_stmt
               from params p
              where uttm_name = 'METHODS'
                and uttm_mode = C_DEFAULT)) resultat
      into l_clob
      from dual;
  
    pit.leave_mandatory;
    return l_clob;
  end get_table_api;
  
  
  function get_form_methods(
    p_application_id in binary_integer,
    p_page_id in binary_integer,
    p_insert_method in varchar2,
    p_update_method in varchar2,
    p_delete_method in varchar2,
    p_static_id in varchar2 default null)
    return clob
  as 
    l_view_name utl_apex.ora_name_type;
    l_column_list utl_apex.max_char;
    l_mode utl_text_templates.uttm_mode%type;
    l_code clob;
  begin
    pit.enter_mandatory(
      p_params => msg_params(
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
    
    -- Analyze whether one methode for insert and update are requested
    if p_insert_method = p_update_method then
      l_mode := 'MERGE';
    else
      l_mode := C_DEFAULT;
    end if;
    l_view_name := get_view_name(p_static_id, p_application_id, p_page_id);
    
    -- generate column list
    with params as(
           select p_application_id application_id,
                  p_page_id page_id,
                  p_static_id static_id,
                  l_view_name view_name
             from dual)
    select utl_text.generate_text(cursor(
             with page_elements as(
                  select /*+ no_merge (p) */
                         apl.application_id, app.page_id, app.page_alias,
                         i.table_name view_name, i.source_name item_name, i.column_name column_name,
                         case when i.data_type in ('NUMBER', 'DATE') then i.data_type else 'DEFAULT' end data_type,
                         case 
                         when i.data_type in ('DATE') then
                           coalesce(upper(i.format_mask), apl.date_format, 'dd.mm.yyyy')
                         when i.data_type in ('TIMESTAMP') then
                           coalesce(upper(i.format_mask), apl.timestamp_format, 'dd.mm.yyyy hh24:mi:ss')
                         when i.data_type in ('NUMBER', 'INTEGER') then 
                           coalesce(replace(upper(i.format_mask), 'G'), 'fm9999999999990d99999999') 
                         end format_mask
                    from apex_applications apl
                    join params p
                      on apl.application_id = p.application_id
                    join apex_application_pages app
                      on apl.application_id = app.application_id
                     and app.page_id = p.page_id
                   cross join table(utl_apex.get_page_items(p.view_name, p.static_id, p.application_id, p.page_id)) i
                  ),
                  template_list as(
                    select uttm_text ddl_template, uttm_mode data_type
                      from utl_text_templates
                     where uttm_name = 'COLUMN'
                       and uttm_type = 'APEX_FORM')
          select t.ddl_template template, 
                 p.page_alias page_alias_upper, lower(p.page_alias) page_alias,
                 substr(p.item_name, instr(p.item_name, '_', 1) + 1) item_name,
                 p.column_name column_name_upper, lower(p.column_name) column_name, 
                 p.format_mask
            from page_elements p
            join template_list t
              on p.data_type = t.data_type), chr(10) || '    '
         )
    into l_column_list
    from dual;
        
    -- generate methods
    if p_static_id is not null then
      -- static id means that a form region or interactive grid is referenced
      $IF utl_apex.VER_LE_05 $THEN
      select utl_text.generate_text(cursor(
               select t.uttm_text template, l_column_list column_list,
                      lower(apo.attribute_02) view_name, upper(apo.attribute_02) view_name_upper,
                      lower(app.page_alias) page_alias, upper(app.page_alias) page_alias_upper,
                      lower(p_insert_method) insert_method,
                      lower(p_update_method) update_method,
                      lower(p_delete_method) delete_method,
                      lower(p_static_id) static_id
                 from apex_application_pages app
                 join apex_application_page_proc apo
                   on app.application_id = apo.application_id
                  and app.page_id = apo.page_id
                cross join utl_text_templates t
                where app.application_id = p_application_id
                  and app.page_id = p_page_id
                  and apo.process_type_code = 'DML_FETCH_ROW'
                  and t.uttm_name = 'METHODS'
                  and t.uttm_type = 'APEX_FORM'
                  and t.uttm_mode = l_mode
               )
             )
        into l_code
        from dual;
      $ELSIF utl_apex.VER_LE_18 $THEN
      select utl_text.generate_text(cursor(
             select t.uttm_text template, l_column_list column_list,
                    lower(apo.attribute_02) view_name, upper(apo.attribute_02) view_name_upper,
                    lower(app.page_alias) page_alias, upper(app.page_alias) page_alias_upper,
                    lower(p_insert_method) insert_method,
                    lower(p_update_method) update_method,
                    lower(p_delete_method) delete_method,
                    lower(p_static_id) static_id
               from apex_application_pages app
               join apex_application_page_proc apo
                 on app.application_id = apo.application_id
                and app.page_id = apo.page_id
              cross join utl_text_templates t
              where app.application_id = p_application_id
                and app.page_id = p_page_id
                and apo.process_type_code = 'DML_FETCH_ROW'
                and t.uttm_name = 'METHODS'
                and t.uttm_type = 'APEX_FORM'
                and t.uttm_mode = l_mode))
      into l_code
      from dual;
      $ELSE
      select utl_text.generate_text(cursor(
             select t.uttm_text template, l_column_list column_list,
                    lower(apr.table_name) view_name, upper(apr.table_name) view_name_upper,
                    lower(app.page_alias) page_alias, upper(app.page_alias) page_alias_upper,
                    lower(p_insert_method) insert_method,
                    lower(p_update_method) update_method,
                    lower(p_delete_method) delete_method,
                    p_static_id static_id
               from apex_application_pages app
               join apex_application_page_regions apr
                 on app.application_id = apr.application_id
                and app.page_id = apr.page_id
              cross join utl_text_templates t
              where app.application_id = p_application_id
                and app.page_id = p_page_id
                and apr.static_id = p_static_id
                and t.uttm_name = 'METHODS'
                and t.uttm_type = 'APEX_FORM'
                and t.uttm_mode = l_mode))
      into l_code
      from dual;
      $END
    else
      select utl_text.generate_text(cursor(
               select t.uttm_text template, l_column_list column_list,
                      lower(apo.attribute_02) view_name, upper(apo.attribute_02) view_name_upper,
                      lower(app.page_alias) page_alias, upper(app.page_alias) page_alias_upper,
                      lower(p_insert_method) insert_method,
                      lower(p_update_method) update_method,
                      lower(p_delete_method) delete_method
                 from apex_application_pages app
                 join apex_application_page_proc apo
                   on app.application_id = apo.application_id
                  and app.page_id = apo.page_id
                cross join utl_text_templates t
                where app.application_id = p_application_id
                  and app.page_id = p_page_id
                  and apo.process_type_code = 'DML_FETCH_ROW'
                  and t.uttm_name = 'METHODS'
                  and t.uttm_type = 'APEX_FORM'
                  and t.uttm_mode = l_mode))
        into l_code
        from dual;
      end if;
      
    pit.leave_mandatory;
    return l_code;
  end get_form_methods;
  
  
  function get_collection_view(
    p_source_table in utl_apex.ora_name_type,
    p_page_view in utl_apex.ora_name_type,
    p_static_id in varchar2 default null)
    return clob
  as
    C_OBJECT_EXISTS constant varchar2(1000) := q'^select 1
  from user_objects
 where object_name = upper('#OBJECT_NAME#')
   and object_type in ('VIEW', 'TABLE')^';
    C_VIEW_STMT constant utl_apex.max_char := q'^with tmpl_list as(
       select uttm_name, uttm_text template
         from utl_text_templates
        where uttm_type = '#APEX_TMPL_TYPE#'
          and uttm_mode = '#DEFAULT#')
select utl_text.generate_text(cursor(
         select template, '#VIEW_NAME#' view_name, 
                utl_text.generate_text(cursor(
                  select t.template, collection_name, lower(column_name) column_name, lower(column_from_collection) column_from_collection
                    from #ITEM_VIEW_NAME# c
                   cross join tmpl_list t
                   where t.uttm_name = 'COLUMN_LIST'
                     and c.table_name = '#VIEW_NAME#'), ',' || chr(10) || '       ') column_list
           from tmpl_list
          where uttm_name = 'VIEW'))
  from dual^';
    l_stmt utl_apex.max_char;
    l_code clob;       
    l_cur sys_refcursor;
    l_item_view_name utl_apex.ora_name_type;
    C_LEGACY_FORM_REGION boolean;
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_source_table', p_source_table),
                    msg_param('p_page_view', p_page_view)));
      
    -- check input parameters
    pit.assert_not_null(p_source_table, msg.UTL_PARAMETER_REQUIRED, msg_args('P_SOURCE_TABLE'));
    pit.assert_not_null(p_page_view, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_VIEW'));
    pit.assert_exists(
      p_stmt => replace(C_OBJECT_EXISTS, '#OBJECT_NAME#', p_source_table),
      p_message_name => msg.UTL_OBJECT_DOES_NOT_EXIST,
      p_msg_args => msg_args('View/table', p_source_table));
      
    -- initialize
    C_LEGACY_FORM_REGION := p_static_id is null;
    
    if C_LEGACY_FORM_REGION then
      l_item_view_name := 'UTL_DEV_APEX_COLLECTION';
    else
      l_item_view_name := 'UTL_DEV_APEX_FORM_COLLECTION';
    end if;
    
    -- generate DDL for view
    l_stmt := utl_text.bulk_replace(C_VIEW_STMT, char_table(
                     'ITEM_VIEW_NAME', l_item_view_name,
                     'STATIC_ID', p_static_id,
                     'VIEW_NAME', p_page_view,
                     'DEFAULT', C_DEFAULT,
                     'APEX_TMPL_TYPE', C_APEX_TMPL_TYPE));
    open l_cur for l_stmt;
    
    fetch l_cur into l_code;
    
    close l_cur;
    
    pit.leave_mandatory;
    return l_code;
  end get_collection_view;    
  
  
  function get_collection_methods(
    p_application_id in binary_integer,
    p_page_id in binary_integer,
    p_static_id in varchar2 default null)
    return clob
  as
    C_HAS_ALIAS_STMT constant varchar2(1000) := q'^select null
  from apex_application_pages
 where application_id = #APPLICATION_ID#
   and page_id = #PAGE_ID#
   and page_alias is not null^';
    C_HAS_FETCH_ROW_PROCESS constant varchar2(1000) := q'^select null
  from apex_application_page_proc
 where application_id = #APPLICATION_ID#
   and page_id = #PAGE_ID#
   and process_type_code = 'DML_FETCH_ROW'^';
    l_stmt utl_apex.max_char;
    l_code clob;
    l_view_name utl_apex.ora_name_type;
    l_collection_name utl_apex.ora_name_type;
    
    C_LEGACY_FORM_REGION boolean;
    C_PACKAGE_STMT constant utl_apex.max_char := q'^with tmpl_list as(
       select uttm_name, uttm_text template
         from utl_text_templates
        where uttm_type = '#APEX_TMPL_TYPE#'
          and uttm_mode = '#DEFAULT#'),
       columns as(
         select *
           from #VIEW_NAME#
          where application_id = #APPLICATION_ID#
            and page_id = #PAGE_ID#)
select /*+ no_merg(c) */ utl_text.generate_text(cursor(
         select t.template, '#PAGE_VIEW_NAME#' view_name, '#PAGE_VIEW_NAME#' collection_name, lower(apa.page_alias) page_alias, 
                utl_text.generate_text(cursor(
                  select t.template, lower(c.collection_name) collection_name, c.column_to_collection, c.page_alias, lower(c.column_name) column_name
                    from columns c
                   cross join tmpl_list t
                   where t.uttm_name = 'PARAMETER_LIST'), ',' || chr(10) || '        ') param_list,
                utl_text.generate_text(cursor(
                  select t.template, lower(c.collection_name) collection_name, c.column_to_collection, c.page_alias, 
                         lower(column_name) column_name, convert_from_item, number_format, date_format, timestamp_format
                    from columns c
                   cross join tmpl_list t
                   where t.uttm_name = 'COPY_LIST'), ';' || chr(10) || '    ') copy_list
           from tmpl_list t
          where uttm_name = 'PACKAGE')) trigger_stmt
  from apex_application_pages apa
 where apa.application_id = #APPLICATION_ID#
   and apa.page_id = #PAGE_ID#^';
       
    l_cur sys_refcursor;
    l_item_view_name utl_apex.ora_name_type;
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_application_id', to_char(p_application_id)),
                    msg_param('p_page_id', to_char(p_page_id))));
      
    C_LEGACY_FORM_REGION := p_static_id is null;
    
    -- check input parameters
    -- NOT NULL
    pit.assert_not_null(p_application_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_APPLICATION_ID'));
    pit.assert_not_null(p_page_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_ID'));
    
    -- APEX page has PAGE ALIAS
    l_stmt := utl_text.bulk_replace(C_HAS_ALIAS_STMT, char_table(
                  'APPLICATION_ID', p_application_id,
                  'PAGE_ID', p_page_id));
    pit.assert_exists(
      p_stmt => l_stmt,
      p_message_name => msg.UTL_PAGE_ALIAS_REQUIRED,
      p_msg_args => msg_args(to_char(p_page_id)));
      
    if C_LEGACY_FORM_REGION then
      -- APEX page has FETCH ROW process
      l_stmt := utl_text.bulk_replace(C_HAS_FETCH_ROW_PROCESS, char_table(
                    'APPLICATION_ID', p_application_id,
                    'PAGE_ID', p_page_id));
      pit.assert_exists(
        p_stmt => l_stmt,
        p_message_name => msg.UTL_FETCH_ROW_REQUIRED);
        
      l_item_view_name := 'UTL_DEV_APEX_COLLECTION';
      select attribute_02, attribute_02
        into l_view_name, l_collection_name
        from apex_application_page_proc
       where application_id = p_application_id
         and page_id = p_page_id
         and process_type_code = 'DML_FETCH_ROW';      
    else
      $IF utl_apex.ver_le_05 $THEN
      null;
      $ELSIF utl_apex.ver_le_18 $THEN
      null;
      $ELSE
      l_item_view_name := 'UTL_DEV_APEX_FORM_COLLECTION';
      select table_name, table_name
        into l_view_name, l_collection_name
        from apex_application_page_regions
       where application_id = p_application_id
         and page_id = p_page_id
         and source_type_code in ('NATIVE_FORM');
      $END
    end if;
    
    -- generate package code
    l_stmt := utl_text.bulk_replace(C_PACKAGE_STMT, char_table(
                     'VIEW_NAME', l_item_view_name,
                     'APPLICATION_ID', p_application_id,
                     'PAGE_ID', p_page_id,
                     'STATIC_ID', p_static_id,
                     'DEFAULT', C_DEFAULT,
                     'APEX_TMPL_TYPE', C_APEX_TMPL_TYPE,
                     'PAGE_VIEW_NAME', lower(l_view_name)));
    open l_cur for l_stmt;
    
    fetch l_cur into l_code;
    
    close l_cur;
    pit.leave_mandatory;
    return l_code;
  exception
    when others then
      dbms_output.put_line(l_stmt);
      pit.sql_exception;
      raise;
  end get_collection_methods;
  
  
  function get_page_item_script(
    p_static_id in varchar2 default null,
    p_table_name in varchar2 default null,
    p_application_id in number,
    p_page_id in number,
    p_record_name in varchar2)
    return varchar2
  as
    l_cursor sys_refcursor;
    l_script utl_apex.max_char;
  
    C_TEMPLATE_MODE_DYNAMIC constant utl_apex.ora_name_type := 'DYNAMIC';
    C_TEMPLATE_MODE_STATIC constant utl_apex.ora_name_type := 'STATIC';
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
  
  
  function copy_view_to_table_script(
    p_view_name in utl_apex.ora_name_type,
    p_table_name in utl_apex.ora_name_type,
    p_table_shortcut in utl_apex.ora_name_type)
    return varchar2
  as
    l_code clob;
  begin
    with params as(
           select uttm_text template, uttm_mode,
                  p_view_name view_name,
                  p_table_name table_name,
                  p_table_shortcut table_shortcut
             from utl_text_templates
            where uttm_type = 'APEX_FORM'
              and uttm_name = 'VIEW_TO_TABLE')
    select utl_text.generate_text(cursor(
             select p.*,
                    utl_text.generate_text(cursor(
                      select p.template, lower(vw.column_name) column_name
                        from user_tab_columns vw
                        join user_tab_columns tbl
                          on vw.column_name = tbl.column_name
                        join params p
                          on vw.table_name = upper(p.table_name)
                         and tbl.table_name = upper(p.view_name)
                       where uttm_mode = 'COLUMN'
                       order by vw.column_id)) column_list
               from params p
              where uttm_mode = 'DEFAULT')) resultat
      into l_code
      from dual;
   return l_code;
  end copy_view_to_table_script;
  
end utl_dev_apex;
/
