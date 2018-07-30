create or replace view code_gen_apex_collection as
  with columns as(
       select api.application_id, api.page_id, apa.page_alias, table_name, 
              column_id, column_name, acm.collection_data_type data_type,
              -- Pivotierte Mappings aus Template-Tabelle
              acm.convert_to_collection,
              acm.convert_from_collection,
              acm.convert_from_item,
              -- Formatmasken aus Anwendungsseite -> Anwendung -> Default ermitteln
              coalesce(upper(case when utc.data_type in ('DATE') then api.format_mask end), apl.date_format, 'dd.mm.yyyy hh24:mi:ss') date_format,
              coalesce(upper(case when utc.data_type in ('TIMESTAMP') then api.format_mask end), apl.timestamp_format, 'dd.mm.yyyy hh24:mi:ss') timestamp_format,
              coalesce(replace(upper(case when utc.data_type in ('NUMBER', 'INTEGER') then api.format_mask end), 'G'), 'fm9999999999990d99999999') number_format,
              rank() over (partition by table_name, acm.collection_data_type order by column_id) column_rank
         from user_tab_columns utc 
         join (select cgtm_name data_type, convert_to_collection, convert_from_collection, convert_from_item, collection_data_type
                 from (select cgtm_name, cgtm_mode, cgtm_text
                         from code_generator_templates
                        where cgtm_type = 'APEX_COLLECTION'
                          and cgtm_mode in ('CONVERT_TO_COLLECTION', 'CONVERT_FROM_COLLECTION', 'CONVERT_FROM_ITEM', 'COLLECTION_DATA_TYPE'))
                pivot (max(cgtm_text) for cgtm_mode in ('CONVERT_TO_COLLECTION' as convert_to_collection,
                                                        'CONVERT_FROM_COLLECTION' as convert_from_collection,
                                                        'CONVERT_FROM_ITEM' as convert_from_item, 
                                                        'COLLECTION_DATA_TYPE' as collection_data_type)))
                acm
           on case utc.data_type when 'CLOB' then 'VARCHAR2' else utc.data_type end = acm.data_type
         left join 
              (select *
                 from apex_application_page_proc
                where process_type_code = 'DML_FETCH_ROW') app
           on utc.table_name = app.attribute_02
         left join 
              (select *
                 from apex_application_page_items
                where item_source_type = 'Database Column') api
           on utc.column_name = api.item_source
          and app.application_id = api.application_id
          and app.page_id = api.page_id
         left join apex_application_pages apa
           on app.application_id = apa.application_id
          and app.page_id = apa.page_id
         left join apex_applications apl
           on app.application_id = apl.application_id),
       -- Spalten der View nach Verfuegbarkeit auf Collectionspalten mappen
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
        where not(data_type in ('CLOB', 'BLOB', 'XMLTYPE') and column_rank > 1))
select application_id, page_id, page_alias, table_name, column_id, collection_name, column_name, number_format, date_format, timestamp_format,
       'g_#PAGE_ALIAS#_row.' || case when collection_name like 'C%' then convert_to_collection else column_name end column_to_collection,
       case when collection_name like 'C%' then convert_from_collection else collection_name end column_from_collection,
       convert_to_collection, convert_from_collection, convert_from_item
  from weighted_colums
       -- Limit von 50 CHAR-Spalten beachten
 where to_number(substr(collection_name, -3)) <= 50
 order by column_id;

comment on table code_gen_apex_collection is 'View to prepare a list of columns for APEX collection API';
