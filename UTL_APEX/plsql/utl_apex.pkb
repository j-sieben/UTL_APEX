create or replace package body utl_apex
as

  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;
  
  
  function clob_to_blob(
    p_clob in clob)
    return blob
  as
    l_blob blob;
    l_lang_context  integer := dbms_lob.DEFAULT_LANG_CTX;
    l_warning       integer := dbms_lob.WARN_INCONVERTIBLE_CHAR;
    l_dest_offset   integer := 1;
    l_source_offset integer := 1;
  begin
    pit.enter_detailed('clob_to_blob', c_pkg);

    dbms_lob.createtemporary(l_blob, true, dbms_lob.call);
      dbms_lob.converttoblob (
        dest_lob => l_blob,
        src_clob => p_clob,
        amount => dbms_lob.LOBMAXSIZE,
        dest_offset => l_dest_offset,
        src_offset => l_source_offset,
        blob_csid => dbms_lob.DEFAULT_CSID,
        lang_context => l_lang_context,
        warning => l_warning
      );

    pit.leave_detailed;
    return l_blob;
  end clob_to_blob;
  
  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2)
  as
  begin
    pit.enter_optional(
      p_action => 'download_blob',
      p_module => c_pkg,
      p_params => msg_params(msg_param('p_file_name', p_file_name)));

    htp.init;
    owa_util.mime_header('application/octet-stream', FALSE, 'UTF-8');
    htp.p('Content-length: ' || dbms_lob.getlength(p_blob));
    htp.p('Content-Disposition: inline; filename="' || p_file_name || '"');
    owa_util.http_header_close;
    wpg_docload.download_file(p_blob);
    apex_application.stop_apex_engine;

    pit.leave_optional;
  exception when others then
    htp.p('error: ' || sqlerrm);
    apex_application.stop_apex_engine;
    pit.leave_optional;
  end download_blob;


  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2)
  as
    l_blob blob;
  begin
    pit.enter_optional(
      p_action => 'download_clob',
      p_module => c_pkg,
      p_params => msg_params(msg_param('p_file_name', p_file_name)));

    l_blob := clob_to_blob(p_clob);
    download_blob(l_blob, p_file_name);

    pit.leave_optional;
  end download_clob;
  
  
  function get_page_values
    return value_table
  as
    cursor item_cur(p_application_id in number, p_page_id in number) is
      select item_name,
             -- Entferne Abhaengigkeit von Seitennummer aus Elementnamen
             substr(item_name, instr(item_name, '_') + 1) item_short_name
        from apex_application_page_items
       where application_id = p_application_id
         and page_id = p_page_id;
    l_page_values value_table;
  begin
    for itm in item_cur(v('APP_ID'), v('APP_PAGE_ID')) loop
      l_page_values(itm.item_short_name) := v(itm.item_name);
    end loop;
    return l_page_values;
  end get_page_values;
  
  
  function get_authorization_status_for(
    p_authorization_scheme in varchar2)
    return number
  as
  begin
    if apex_util.public_check_authorization(p_authorization_scheme) then
      return 1;
    else
      return 0;
    end if;
  end get_authorization_status_for;
  
end;
/