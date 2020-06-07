create or replace view utl_dev_apex_form_collection as
with columns as(
        select apl.application_id, app.page_id, lower(app.page_alias) page_alias, lower(apr.table_name) table_name, 
               utc.column_id, lower(utc.column_name) column_name, acm.collection_data_type data_type,
               -- Pivotierte Mappings aus Template-Tabelle
               acm.convert_to_collection,
               acm.convert_from_collection,
               acm.convert_from_item,
               -- Formatmasken aus Anwendungsseite -> Anwendung -> Default ermitteln
               coalesce(upper(case when api.item_source_data_type in ('DATE') then api.format_mask end), apl.date_format, 'dd.mm.yyyy hh24:mi:ss') date_format,
               coalesce(upper(case when api.item_source_data_type in ('TIMESTAMP') then api.format_mask end), apl.timestamp_format, 'dd.mm.yyyy hh24:mi:ss') timestamp_format,
               coalesce(replace(upper(case when api.item_source_data_type in ('NUMBER', 'INTEGER') then api.format_mask end), 'G'), 'fm9999999999990d99999999') number_format,
               rank() over (partition by apr.table_name, acm.collection_data_type order by api.item_source) column_rank
          from apex_applications apl
          join apex_application_pages app
            on apl.application_id = app.application_id
          join apex_application_page_regions apr
            on app.application_id = apr.application_id
           and app.page_id = apr.page_id
          join apex_application_page_items api
            on apr.application_id = api.application_id
           and apr.page_id = api.page_id
          join user_tab_columns utc
            on apr.table_name = utc.table_name
           and api.item_source = utc.column_name
          join (select uttm_name data_type, convert_to_collection, convert_from_collection, convert_from_item, collection_data_type
                  from (select uttm_name, uttm_mode, uttm_text
                          from utl_text_templates
                         where uttm_type = 'APEX_COLLECTION'
                           and uttm_mode in ('CONVERT_TO_COLLECTION', 'CONVERT_FROM_COLLECTION', 'CONVERT_FROM_ITEM', 'COLLECTION_DATA_TYPE'))
                 pivot (max(uttm_text) for uttm_mode in ('CONVERT_TO_COLLECTION' as convert_to_collection,
                                                         'CONVERT_FROM_COLLECTION' as convert_from_collection,
                                                         'CONVERT_FROM_ITEM' as convert_from_item,
                                                         'COLLECTION_DATA_TYPE' as collection_data_type)))
                acm
             on case api.item_source_data_type when 'CLOB' then 'VARCHAR2' else api.item_source_data_type end = acm.data_type
         where apr.source_type_code in ('NATIVE_FORM')),
     weighted_colums as(
       select application_id, page_id, page_alias, table_name, column_id, column_name, number_format, date_format, timestamp_format,
              -- Limit von 5 NUMBER und DATE-Spalten beachten, anschließend auf CHAR casten
              case when data_type in ('N', 'C') and column_rank > 5 then 'C' else data_type end  ||
              to_char(rank() over (partition by table_name,
                                                case
                                                  when data_type in ('N', 'C') and column_rank > 5 then 'C'
                                                  else data_type end
                                    order by column_id), 'fm000') collection_name,
              convert_to_collection, convert_from_collection, convert_from_item
         from columns
              -- Limit auf LOB und XMLTYPE beachten
        where not(data_type in ('CLOB', 'BLOB', 'XMLTYPE') 
          and column_rank > 1))
select application_id, page_id, page_alias, table_name, column_id, collection_name, column_name, number_format, date_format, timestamp_format,
       'g_#PAGE_ALIAS#_row.' || case when collection_name like 'C%' then convert_to_collection else column_name end column_to_collection,
       case when collection_name like 'C%' then convert_from_collection else collection_name end column_from_collection,
       convert_to_collection, convert_from_collection, convert_from_item
  from weighted_colums
       -- Limit von 50 CHAR-Spalten beachten
 where to_number(substr(collection_name, -3)) <= 50
 order by column_id;

comment on table utl_dev_apex_form_collection is 'View to generate access methods for APEX collection API based on a form region';
