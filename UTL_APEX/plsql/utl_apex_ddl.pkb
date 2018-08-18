create or replace package body utl_apex_ddl
as

  C_PKG constant utl_apex.ora_name_type := $$PLSQL_UNIT;
  c_apex_tmpl_type constant utl_apex.ora_name_type := 'APEX_COLLECTION';
  c_default constant utl_apex.ora_name_type := 'DEFAULT';

  function get_table_api(
    p_table_name in utl_apex.ora_name_type,
    p_short_name in utl_apex.ora_name_type,
    p_owner in utl_apex.ora_name_type default user,
    p_pk_insert in utl_apex.flag_type default utl_apex.c_true,
    p_pk_columns in char_table default null,
    p_exclude_columns in char_table default null)
    return clob
  as
    l_clob clob;
    c_cgrtm_type constant utl_apex.ora_name_type := 'TABLE_API';
    c_column constant utl_apex.ora_name_type := 'COLUMN';
  begin
      with params as (
           -- Get input params and templates
           select lower(p_owner) owner,
                  lower(p_table_name) table_name,
                  lower(p_short_name) short_name,
                  p_pk_insert pk_insert,
                  cgtm_name, cgtm_mode, cgtm_text
             from code_generator_templates
            where cgtm_type = c_cgrtm_type
         ),
         column_data as(
           -- prepare column list
           select lower(col.table_name) table_name, lower(p.short_name) short_name,
                  lower(col.column_name) column_name, max(length(col.column_name)) over () max_length,
                  case when coalesce(con.column_name, pk.col_name) is not null then 1 else 0 end is_pk,
                  cgtm_name, cgtm_mode, cgtm_text
             from all_tab_columns col
             join params p
               on upper(p.owner) = col.owner
              and upper(p.table_name) = col.table_name
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
                    from table(p_pk_columns)) pk
               on col.column_name = pk.col_name
             left join (
                  select upper(column_value) column_name
                    from table(p_exclude_columns)) ec
               on col.column_name = ec.column_name
            where ec.column_name is null
            order by col.column_id)
  select /*+ no_merge (column_data) */
         code_generator.generate_text(cursor(
           -- generate method specs and implementation
           select cgtm_text template, table_name, short_name,
                  code_generator.generate_text(cursor(
                    -- generate explicit param list including PK
                    select cgtm_text template,
                           rpad(column_name, max_length, ' ') column_name_rpad,
                           column_name
                      from column_data
                     where cgtm_name = c_column
                       and cgtm_mode = 'PARAM_LIST'), ',' || chr(10), 4) param_list,
                  code_generator.generate_text(cursor(
                    -- generate code to copy parameter values to record instance
                    select cgtm_text template,
                           column_name
                      from column_data
                     where cgtm_name = c_column
                       and cgtm_mode = 'RECORD_LIST'), ';' || chr(10), 4) record_list,
                  code_generator.generate_text(cursor(
                    -- generate list of PK columns for delete
                    select cgtm_text template,
                           column_name
                      from column_data
                     where cgtm_name = c_column
                       and cgtm_mode = 'PK_LIST'
                       and is_pk = utl_apex.C_TRUE), chr(10) || '       and ') pk_list,
                  code_generator.generate_text(cursor(
                    -- generate merge statement
                    select cgtm_text template,
                           table_name,
                           short_name,
                           code_generator.generate_text(cursor(
                             -- generate using clause (parameter to columns)
                             select cgtm_text template,
                                    column_name
                               from column_data
                              where cgtm_name = c_column
                                and cgtm_mode = 'USING_LIST'), ',' || chr(10), 18) using_list,
                           code_generator.generate_text(cursor(
                             -- generate list of PK columns for on clause
                             select cgtm_text template,
                                    column_name
                               from column_data
                              where cgtm_name = c_column
                                and cgtm_mode = 'ON_LIST'
                                and is_pk = utl_apex.C_TRUE), chr(10) || '       and ') on_list,
                           code_generator.generate_text(cursor(
                             -- generate list update columns (w/o PK list)
                             select cgtm_text template,
                                    column_name
                               from column_data
                              where cgtm_name = c_column
                                and cgtm_mode = 'UPDATE_LIST'
                                and is_pk = utl_apex.C_FALSE), ',' || chr(10), 12) update_list,
                           code_generator.generate_text(cursor(
                             -- generate column list for insert clause
                             select cgtm_text template,
                                    column_name
                               from column_data
                              where cgtm_name = 'COLUMN'
                                and cgtm_mode = 'COL_LIST'
                                and is_pk in (utl_apex.C_FALSE, pk_insert)), ',', 1) col_list,
                           code_generator.generate_text(cursor(
                             -- generate list of insert columns
                             select cgtm_text template,
                                    column_name
                               from column_data
                              where cgtm_name = c_column
                                and cgtm_mode = 'INSERT_LIST'
                                and is_pk in (utl_apex.C_FALSE, pk_insert)), ',', 1) insert_list
                      from params
                     where cgtm_name = 'MERGE'
                       and cgtm_mode = 'DEFAULT')) merge_stmt
             from params p
            where cgtm_name = 'METHODS'
              and cgtm_mode = 'DEFAULT')) resultat
    into l_clob
    from dual;
  
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
    l_mode code_generator_templates.cgtm_mode%type := c_default;
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
                and t.cgtm_mode = l_mode))
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
    c_object_exists constant varchar2(1000) := q'^select 1
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
    p_application_id in binary_integer,
    p_page_id in binary_integer)
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
    pit.enter_mandatory(C_PKG, 'get_collection_methods', msg_params(
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
  
end utl_apex_ddl;
/
