declare
  object_does_not_exist exception;
  pragma exception_init(object_does_not_exist, -4043);
  table_does_not_exist exception;
  pragma exception_init(table_does_not_exist, -942);
  sequence_does_not_exist exception;
  pragma exception_init(sequence_does_not_exist, -2282);
  synonym_does_not_exist exception;
  pragma exception_init(synonym_does_not_exist, -1434);
  cursor delete_object_cur is
          select object_name name, object_type type
            from all_objects
           where object_name in (
                 'UTL_DEV_APEX_COL_T', 'UTL_DEV_APEX_COL_TAB', 'UTL_APEX_PAGE_ITEM_T', 'UTL_APEX_PAGE_ITEM_TAB', -- Types
                 'UTL_APEX', 'UTL_APEX_DDL',  -- Packages
                 'UTL_DEV_APEX_COLLECTION', 'UTL_DEV_APEX_FORM_COLLECTION', 'UTL_APEX_FETCH_ROW_COLUMNS', 'UTL_APEX_FORM_REGION_COLUMNS', 'UTL_APEX_IG_COLUMNS', 'UTL_APEX_PAGE_ITEMS', -- Views
                 '',  -- Tabellen
                 'WWV_FLOW_ERROR',  -- Synonyme
                 '' -- Sequenzen
                 )
             and object_type not like '%BODY'
             and owner = upper('&INSTALL_USER.')
           order by object_type, object_name;
  l_has_objects boolean := false;
begin
  for obj in delete_object_cur loop
    begin
      execute immediate 'drop ' || obj.type || ' ' || obj.name ||
                        case obj.type 
                        when 'TYPE' then ' force' 
                        when 'TABLE' then ' cascade constraints' 
                        end;
     dbms_output.put_line('&s1.' || initcap(obj.type) || ' ' || obj.name || ' deleted.');
    
    exception
      when object_does_not_exist or table_does_not_exist or sequence_does_not_exist or synonym_does_not_exist then
        dbms_output.put_line('&s1.' || obj.type || ' ' || obj.name || ' does not exist.');
      when others then
        raise;
    end;
    l_has_objects := true;
  end loop;
  
  if not l_has_objects then
    dbms_output.put_line('&s1.No installed objects found.');
  end if;
  
  pit_admin.delete_message_group('UTL_APEX', true);
     
  -- Try to delete templates (table may not be present anymore)
  begin
    execute immediate q'^delete from utl_text_templates where uttm_type in ('APEX_COLLECTION', 'APEX_FORM', 'APEX_IG')^';
  exception
    when others then
      null;
  end;
   
  commit;
end;
/