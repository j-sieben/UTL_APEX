create or replace package utl_apex 
   authid definer
as
  /**
    Oracle APEX related utilites
  */
  
  /* Types */
  subtype ora_name_type is &ORA_NAME_TYPE.;
  subtype max_char is varchar2(32767);
  subtype flag_type is char(1 byte);
  
  /* Package constants */
  /* APEX Version constants according to DBMS_DB_VERSION */
  VER_LE_05 constant boolean := &VER_LE_05.;
  VER_LE_0500 constant boolean := &VER_LE_0500.;
  VER_LE_0501 constant boolean := &VER_LE_0501.;
  VER_LE_18 constant boolean := &VER_LE_18.;
  VER_LE_1801 constant boolean := &VER_LE_1801.;
  
  FORMAT_JSON constant char(4 byte) := 'JSON';
  FORMAT_HTML constant char(4 byte) := 'HTML';
  
  C_TRUE constant flag_type := 'Y';
  C_FALSE constant flag_type := 'N';
  
  function get_true
    return varchar2;
    
  function get_false
    return varchar2;
  
  /* Public constant declarations */
  
  /* Public type declarations  */
  subtype page_value_t is utl_text.clob_tab;
  
  /* Public variable declarations */
  
  /* Public function and procedure declarations */
  /** Method to check whether actual user has got an authorization
   * @param  p_authorization_scheme  Name of the authorization scheme that is requested for a given ressource.
   *                                 This name may be taken from the APEX data dictionary
   * @return 1 if user is authorized, 0 otherwise
   * @usage  Is called to check whether the actual user has got an authorization
   *         for a requested ressource. Wrapper around APEX_AUTHORIZATION
   */
  function user_is_authorized(
    p_authorization_scheme in varchar2)
    return flag_type;
    
    
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
    
    
  /** Method to read all active session values on the active page
   * @param [p_format] Optional format constant. Allowed values are package constants FORMAT_...
   *                   If set, all values taken from the session state will be escaped by APEX_ESCAPE.
   *                   Useful if values are to be copied to a JSON- or XML instance.
   * @return Instance of PAGE_VALUE_T, 
   *         - Key is the name of the page element <em>without</em> page prefix Pnn_<br/>
   *         - Value is the actual value of the page element as varchar2
   */
  function get_page_values(
    p_format in varchar2 default null)
    return page_value_t;
  
  
  /* Methode ro read all values of the actually selected interactive grid row
   * @param  p_target_table    Name of the target table
   * @param  p_static_id       Static ID of the interactive grid. Is used to name the record returned
   * @param [p_application_id] Optional applcation id. Defaults to v('APP_ID').
   * @param [p_page_id]        Optional page id. Defaults to v('APP_PAGE_ID').
   * @return Anonymous block that fills a pl/sql table
   * @usage  Generic utility to read all columns of an interactive grid into a generic pl/sql table
   *         Is either called dynamically on the page or statically upon development time to include the resulting code
   *         into a package.
   *         Example dynamic usage:
   *         <code> execute immedite utl_apex.get_ig_values('FOO', 'FOO_EDIT') using out l_row;</code>
   *         Example static usage:
   *         <code>select utl_apex.get_ig_values('FOO', 'FOO_EDIT', 123, 1) from dual </code>
   */
  function get_ig_values(
    p_target_table in ora_name_type,
    p_static_id in ora_name_type,
    p_application_id in binary_integer default null,
    p_page_id in binary_integer default null)
    return varchar2;
  
  
  /** Method to get the value of a page item stored in P_PAGE_VALUES
   * @usage  Wrapper to provide a meaningful error message if the requested item is not in the list of page items
   * @param  p_page_values   PL/SQL table with all page items as key and page item values as payload
   * @param  p_element_name  Name of the page item
   * @return Value of the page item
   * @throws msg.UTL_APEX_MISSING_ITEM
   */
  function get(
    p_page_values in page_value_t,
    p_element_name in ora_name_type)
    return varchar2;
  
  
  /** Method to check that P_NAME is a simple sql name
   * @param  p_name  Name, der geprueft werden soll
   * @return Fehlermeldung, falls Pruefung nicht erfolgreich war, NULL ansonsten
   * @usage  Wrapper around DBMS_ASSERT.SIMPLE_SQL_NAME with the extension that umlauts are not allowed.
   *         Length limited to PIT_UTIL.C_MAX_LENGTH - 4
   */
  function validate_simple_sql_name(
    p_name in varchar2)
    return varchar2;
  
  
  /** Method to emit validation error messages.<br/>
   * This method includes an error message into the apex error stack if a validation returns a non null error message
   * @param  p_page_item  Page item to validate
   * @param  p_message    Name of a PIT message or plain message text to raise
   * @param [p_msg_args]  optional message parameters
   */
  procedure set_error(
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null);
  
  
  /** Method to get a page prefix for the actual apex page
   * @return String containing a prefix for the actual page: On page 10 it returns <code>P10_<code>
   */
  function get_page
    return varchar2;
  
  
  /** Methods to check what action is requested
   * @usage  All methods anlayze two different sources: REQUEST and APEX$ROW_STATUS.
   *         Either of both values are checked against a white list of values. If they match, the method returns TRUE
   * @return TRUE, if REQUEST or APEX$ROW_STATUS is in the white list, FALSE otherwise
   */
  function inserting
    return boolean;
    
  function updating
    return boolean;
    
  function deleting
    return boolean;
  
  /** Method to check whether Request equals P_REQUEST.<br/>
   * Wrapper to avoid having to deal with Apex V methods in the code
   * @param  p_request  Value to compare against Request
   * @return TRUE if P_REQUEST equals Request, FALSE otherwise
   */
  function request_is(
    p_request in varchar2)
    return boolean;
  
  
  /** Method to raise an exception if a Request can not be handled
   */
  procedure unhandled_request;
  
  
  /** Method to load a BLOB instance as a file download
   * @param  p_blob       Instance to download
   * @param  p_file_name  Name of the file to download.
   */
  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2);
    
  
  /** Ovewrlaod for CLOB instances */
  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2);
  
  
  /* ASSERTION wrappers */
  /* Methods call PIT.ASSERT... but incorporate any exception raised into the APEX error stack using PIT.LOG_SPECIFIC. 
   * This way, only APEX will get any exception messages. 
   * P_AFFECTED_ID references the page item the error message is linked to.
   * Further documentation see PIT
   */
  procedure assert(
    p_condition in boolean,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
    
  procedure assert_is_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
    
  procedure assert_is_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
    
  procedure assert_is_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.ASSERT_IS_NULL,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
  
  
  procedure assert_not_null(
    p_condition in varchar2,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
    
  procedure assert_not_null(
    p_condition in number,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
    
  procedure assert_not_null(
    p_condition in date,
    p_message_name in ora_name_type default msg.UTL_PARAMETER_REQUIRED,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
    
  procedure assert_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
    
  
  procedure assert_not_exists(
    p_stmt in varchar2,
    p_message_name in ora_name_type,
    p_affected_id in ora_name_type default null,
    p_arg_list msg_args default null);
  
end utl_apex;
/