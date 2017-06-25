begin
  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_ITEM_MISSING',
    p_pms_text => 'Das Element #1# existiert auf Seite #2# nicht',
    p_pms_pse_id => 20);
    
  
  pit_admin.create_message_package;

end;
/
