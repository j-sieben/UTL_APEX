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
            from user_objects
           where object_name in (
                 'UTL_DEV_APEX_COL_T', 'UTL_DEV_APEX_COL_TAB', -- Types
                 'UTL_DEV_APEX',  -- Packages
                 'UTL_DEV_APEX_COLLECTION', 'UTL_DEV_APEX_FORM_COLLECTION', -- Views
                 '',  -- Tabellen
                 '',  -- Synonyme
                 '' -- Sequenzen
                 )
             and object_type not like '%BODY'
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
    dbms_output.put_line('&s1.Removing Template APEX_COLLECTION');
    utl_text_admin.delete_template(p_uttm_type => 'APEX_COLLECTION');
    dbms_output.put_line('&s1.Removing Template APEX_FORM');
    utl_text_admin.delete_template(p_uttm_type => 'APEX_FORM');
    dbms_output.put_line('&s1.Removing Template APEX_IG');
    utl_text_admin.delete_template(p_uttm_type => 'APEX_IG');
  exception
    when others then
      dbms_output.put_line(substr(sqlerrm, 12));
  end;
   
  commit;
end;
/