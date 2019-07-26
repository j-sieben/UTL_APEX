create or replace package utl_test_apex
  authid definer
as

  /** Method to create an APEX session outside a browser. Used for test purposes
   * @param  p_apex_user       APEX session user
   * @param  p_application_id  ID of the application
   * @param [p_page_id]        ID of the application page
   * @usage  Generates an APEX session for testing purposes. After calling this method,
   *         item values may be set by calling APEX_UTIL.SET_SESSION_STATE.
   *         Output is visible via OWA output window in SQL Developer
   */
  procedure create_apex_session(
    p_apex_user in apex_workspace_activity_log.apex_user%type,
    p_application_id in apex_applications.application_id%type,
    p_page_id in apex_application_pages.page_id%type default 1);


  /** Method to create an APEX session outside a browser. Used for test purposes
   * @param [p_session_id] Optional session id. Defaults to the active session id
   * @usage  Tears down an APEX session after testing.
   */
  procedure delete_apex_session(
    p_session_id in number default null);
    
  
  /** Methodto to initialize a local OWA service to prepare capturing OWA output
   * @usage  Is used to prepare to catch the outcome of APEX method that write their output to the http stream only.
   */
  procedure init_owa;
  
  
  /** Method to capture OWA output and redirect it to DBMS_OUTPUT
   * @usage  Is used to show the outcome of APEX method that write their output to the http stream only.
   */
  procedure print_owa_output;
  
  
  /** Method to capture OWA output and return it as an instance of CHAR_TABLE (split by row)
   * @usage  Is used to examine OWA output
   */
  function get_owa_output
    return char_table;
    
end utl_test_apex;
/
