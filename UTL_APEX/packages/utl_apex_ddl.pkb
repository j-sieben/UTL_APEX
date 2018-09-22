create or replace package body utl_apex_ddl
as

  C_PKG constant utl_apex.ora_name_type := $$PLSQL_UNIT;
  C_APEX_TMPL_TYPE constant utl_apex.ora_name_type := 'APEX_COLLECTION';
  C_DEFAULT constant utl_apex.ora_name_type := 'DEFAULT';
  C_CR constant varchar2(2) := chr(10);

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
    l_column_list utl_apex_ddl_col_tab;
  begin
    pit.enter_mandatory(C_PKG, 'get_table_api', msg_params(
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
             select utl_apex_ddl_col_t(
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
              order by col.column_id) as utl_apex_ddl_col_tab)
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
    p_delete_method in varchar2)
    return clob
  as
    l_column_list utl_apex.max_char;
    l_mode utl_text_templates.uttm_mode%type := C_DEFAULT;
    l_code clob;
  begin
    pit.enter_mandatory(C_PKG, 'get_form_methods', msg_params(
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
    end if;
    
    -- generate column list
    select utl_text.generate_text(cursor(
             with page_elements as(
                  select apl.application_id, app.page_id, apo.attribute_02 view_name, app.page_alias, api.item_name, utc.column_name,
                         case when utc.data_type in ('NUMBER', 'DATE') then utc.data_type else C_DEFAULT end data_type,
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
                    select uttm_text ddl_template, uttm_mode data_type
                      from utl_text_templates
                     where uttm_name = 'COLUMN'
                       and uttm_type = 'APEX_FORM')
          select t.ddl_template, p.page_alias page_alias_upper, lower(p.page_alias) page_aliasl, 
                 substr(p.item_name, instr(p.item_name, '_', 1) + 1) item_name,
                 p.column_name column_name_upper, lower(p.column_name) column_name, p.format_mask
            from page_elements p
            join template_list t
              on p.data_type = t.data_type
           where p.application_id = p_application_id
             and p.page_id = p_page_id), C_CR || '    '
         )
    into l_column_list
    from dual;
    
    -- generate methods
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
      
    pit.leave_mandatory;
    return l_code;
  end get_form_methods;
  
  
  function get_collection_view(
    p_source_table in utl_apex.ora_name_type,
    p_page_view in utl_apex.ora_name_type)
    return clob
  as
    C_OBJECT_EXISTS constant varchar2(1000) := q'^select 1
  from user_objects
 where object_name = upper('#OBJECT_NAME#')
   and object_type in ('VIEW', 'TABLE')^';
    l_code clob;
  begin
    pit.enter_mandatory(C_PKG, 'get_collection_view', msg_params(
      msg_param('p_source_table', p_source_table),
      msg_param('p_page_view', p_page_view)));
      
    -- check input parameters
    pit.assert_not_null(p_source_table, msg.UTL_PARAMETER_REQUIRED, msg_args('P_SOURCE_TABLE'));
    pit.assert_not_null(p_page_view, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_VIEW'));
    pit.assert_exists(
      p_stmt => replace(C_OBJECT_EXISTS, '#OBJECT_NAME#', p_source_table),
      p_message_name => msg.UTL_OBJECT_DOES_NOT_EXIST,
      p_arg_list => msg_args('View/table', p_source_table));
      
    -- generate DDL for view
      with tmpl_list as(
           select uttm_name, uttm_text
             from utl_text_templates
            where uttm_type = C_APEX_TMPL_TYPE
              and uttm_mode = C_DEFAULT)
    select utl_text.generate_text(cursor(
             select uttm_text, p_page_view view_name, 
                    utl_text.generate_text(cursor(
                      select t.uttm_text, collection_name, column_name, column_from_collection
                        from code_gen_apex_collection c
                       cross join tmpl_list t
                       where t.uttm_name = 'COLUMN_LIST'
                         and c.table_name = p_source_table), ',' || C_CR || '       ') column_list
               from tmpl_list
              where uttm_name = 'VIEW'))
      into l_code
      from dual;
    
    pit.leave_mandatory;
    return l_code;
  end get_collection_view;    
  
  
  function get_collection_methods(
    p_application_id in binary_integer,
    p_page_id in binary_integer)
    return clob
  as
    C_HAS_ALIAS_STMT constant varchar2(1000) := q'^select 1
  from apex_application_pages
 where application_id = #APPLICATION_ID#
   and page_id = #PAGE_ID#
   and page_alias is not null^';
    C_HAS_FETCH_ROW_PROCESS constant varchar2(1000) := q'^select 1
  from apex_application_page_proc
 where application_id = #APPLICATION_ID#
   and page_id = #PAGE_ID#
   and process_type_code = 'DML_FETCH_ROW'^';
   
    l_code clob;
  begin
    pit.enter_mandatory(C_PKG, 'get_collection_methods', msg_params(
      msg_param('p_application_id', to_char(p_application_id)),
      msg_param('p_page_id', to_char(p_page_id))));
      
    -- check input parameters
    -- NOT NULL
    pit.assert_not_null(p_application_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_APPLICATION_ID'));
    pit.assert_not_null(p_page_id, msg.UTL_PARAMETER_REQUIRED, msg_args('P_PAGE_ID'));
    -- APEX page has PAGE ALIAS
    pit.assert_exists(
      p_stmt => utl_text.bulk_replace(C_HAS_ALIAS_STMT, char_table(
                  '#APPLICATION_ID#', to_clob(p_application_id),
                  '#PAGE_ID#', to_clob(p_page_id))),
      p_message_name => msg.UTL_PAGE_ALIAS_REQUIRED,
      p_arg_list => msg_args(to_char(p_page_id)));
    -- APEX page has FETCH ROW process
    pit.assert_exists(
      p_stmt => utl_text.bulk_replace(C_HAS_FETCH_ROW_PROCESS, char_table(
                  '#APPLICATION_ID#', to_clob(p_application_id),
                  '#PAGE_ID#', to_clob(p_page_id))),
      p_message_name => msg.UTL_FETCH_ROW_REQUIRED);
    
    -- generate package code
      with tmpl_list as(
           select uttm_name, uttm_text
             from utl_text_templates
            where uttm_type = C_APEX_TMPL_TYPE
              and uttm_mode = C_DEFAULT)
    select utl_text.generate_text(cursor(
             select t.uttm_text, app.attribute_02 view_name, app.attribute_02 collection_name, apa.page_alias, 
                    utl_text.generate_text(cursor(
                      select t.uttm_text, c.collection_name, c.column_to_collection, c.page_alias, c.column_name
                        from code_gen_apex_collection c
                       cross join tmpl_list t
                       where t.uttm_name = 'PARAMETER_LIST'
                         and c.application_id = apa.application_id
                         and c.page_id = apa.page_id), ',' || C_CR || '        ') param_list,
                    utl_text.generate_text(cursor(
                      select t.uttm_text, c.collection_name, c.column_to_collection, c.page_alias, 
                             column_name, convert_from_item, number_format, date_format, timestamp_format
                        from code_gen_apex_collection c
                       cross join tmpl_list t
                       where t.uttm_name = 'COPY_LIST'
                         and c.application_id = apa.application_id
                         and c.page_id = apa.page_id), ';' || C_CR || '    ') copy_list
               from tmpl_list t
              where uttm_name = 'PACKAGE')) trigger_stmt
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
  
end utl_apex_ddl;
/
