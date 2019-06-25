create or replace package utl_apex
   authid definer
as
  /**
    Oracle APEX related utilites
  */

  /* Types */
  subtype ora_name_type is &ORA_NAME_TYPE.;
  subtype max_char is varchar2(32767);
  subtype max_sql_char is varchar2(4000 byte);
  subtype flag_type is char(1 byte);
  
  /* Package constants */
  /* APEX Version constants according to DBMS_DB_VERSION */
  VER_LE_05 constant boolean := &VER_LE_05.;
  VER_LE_0500 constant boolean := &VER_LE_0500.;
  VER_LE_0501 constant boolean := &VER_LE_0501.;
  VER_LE_18 constant boolean := &VER_LE_18.;
  VER_LE_1801 constant boolean := &VER_LE_1801.;
  VER_LE_1802 constant boolean := &VER_LE_1802.;
  VER_LE_19 constant boolean := &VER_LE_19.;
  VER_LE_1901 constant boolean := &VER_LE_1901.;

  FORMAT_JSON constant char(4 byte) := 'JSON';
  FORMAT_HTML constant char(4 byte) := 'HTML';

  C_TRUE constant flag_type := 'Y';
  C_FALSE constant flag_type := 'N';

  /* Public constant declarations */

  /* Public type declarations  */
  subtype page_value_t is utl_text.clob_tab;

  /* Public variable declarations */

  /* Public function and procedure declarations */
  function get_true
    return flag_type;
    
  function get_false
    return flag_type;
    
  function get_bool(
    p_bool in boolean)
    return flag_type;
  
  /** Method to check whether actual user has got an authorization
   * %param  p_authorization_scheme  Name of the authorization scheme that is requested for a given ressource.
   *                                 This name may be taken from the APEX data dictionary
   * %return C_TRUE if user is authorized, C_FALSE otherwise
   * %usage  Is called to check whether the actual user has got an authorization
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


  /** Method to read all page item values from the session state and store them in an instance of PAGE_VALUE_T.
   * %param [p_format] Optional formatting. Allowed values are all FORMAT_... constants of this package.
   *                   If set, all session state values are escaped using the respective method from APEX_ESCAPE
   * @return Instance of PAGE_VALUE_T.<br>Key of that type is the page item name WITHOUT the page prefix (Pn_), or, if present,
   *         the name of the column the item gets its value from. This is especially true for FORM regions (Apex 19 and later).
   *         The value is always given as a string, no conversion takes place.
   */
  function get_page_values(
    p_format in varchar2 default null)
    return page_value_t;


  /** Method to read the values of an interactive Grid. Returns a PL/SQL block that reads and converts the data into a 
   * typesave record instance that can be directly used in packages.
   * %param  p_target_table    Name of the table the data is written to, not the table or view name of the interactive grid.
   * %param [p_record_name]    Name of the resulting record.
   * %param [p_application_id] APEX application id. IF NULL, apex_application.g_flow_id is used.
   * %param [p_page_id]        APEX page id. If NULL, apex_application.g_flow_step_id is used.
   * %return Anonymous PL/SQL block to copy and convert the page values into a record. The record structure is taken from P_TARGET_TABLE
   * %usage  Generic utility to create code that reads the actual session state of an interactive grid row. <br>
   *         This method can be used in two variations: static or dynamic. If called statically, you provide an application and
   *         page id, if used dynamically, you run the query without those parameters. The difference is that when called 
   *         dynamically, the method will create a PL/SQL block that can be executed directly using dynamic SQL:
   *         <code> execute immediate utl_apex.get_ig_values('FOO') using out l_row;</code>
   *         Here, <code>l_row</code> must be of <code>P_TARGET_TABLE%ROWTYPE</code>.
   *         If used statically, the method creates PL/SQL code that can be directly copied into a package:
   *         <code>select utl_apex.get_ig_values('MY_TABLE_NAME', 'abc', 123, 1) from dual </code>
   *         This call will generate a global record of <code>P_TARGET_TABLE%ROWTYPE</code>, named <code>P_RECORD_NAME</code>
   */
  function get_ig_values(
    p_target_table in ora_name_type,
    p_record_name in ora_name_type default 'row',
    p_application_id in binary_integer default null,
    p_page_id in binary_integer default null)
    return varchar2;


  /** Method to read a session state value from PAGE_VALUE_T.
   * @usage  Wrapper around the collection to catch exceptions if a key is requested that does not exist.
   * @param  p_page_values   Instance of the page values read by GET_PAGE_VALUES
   * @param  p_element_name  Name of the page item for which the value is requested
   * @return Session state value as string
   */
  function get(
    p_page_values in page_value_t,
    p_element_name in ora_name_type)
    return varchar2;


  /** Method checks and converts a name to adhere to simple SQL naming conventions
   * @param  p_name  Name to check
   * @return Error message if the name does not conform to the naming conventions, NULL otherwise
   * @usage  Wrapper around DBMS_ASSERT with an additional test to prevent umlauts to be part of the name
   */
  function validate_simple_sql_name(
    p_name in varchar2)
    return varchar2;


  /** Method to register validation error messages.
   * @param  p_page_item  Seitenelement, das durch die Validierung betroffen ist
   * @param  p_message    Meldungstext bzw. Referenz auf eine MSG_LOG-Meldung
   * @param [p_msg_args]  Optionale Meldungsparameter
   * @usage  This method is called during validation checks to pass an error message to the UI. It will pass the message if
   *         it is not null and do nothing otherwise. This way, it can be called anyway without prior check whether an error
   *         has occurred. This is useful when <code>P_MESSAGE</code> is provided via a method that throws an error message 
   *         if the validation fails and NULL if everything is OK.
   */
  procedure set_error(
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null);


  /** Method to register validation error messages.
   * @param  p_page_item  Seitenelement, das durch die Validierung betroffen ist
   * @param  p_message    Meldungstext bzw. Referenz auf eine MSG_LOG-Meldung
   * @param [p_msg_args]  Optionale Meldungsparameter
   * @usage  This method is called during validation checks to pass an error message to the UI. It will pass the message if
   *         <code>P_TEST</code> evaluates to <code>FALSE</code> and do nothing otherwise.<br>The message has to be a PIT 
   *         message name with an optional attribute set.
   */
  procedure set_error(
    p_test in boolean,
    p_page_item in ora_name_type,
    p_message in ora_name_type,
    p_msg_args in msg_args default null);


  /** Methods to analyse the requested operation during a page submit
   * @return TRUE, if the respective operation was requested
   * @usage  This method is used within a method to process user entries for a given page. By calling these methods, the package
   *         can decide on the respective action to take, analogous to the trigger constants.
   */
  function inserting
    return boolean;

  function updating
    return boolean;

  function deleting
    return boolean;

  /** Method to check whether the request is equal to P_REQUEST.
   * @param  p_request  Request value to check against the actual request value
   * @return Outcome of the comparison
   * @usage  This method is used to check for arbitrary request values outside the scope of CRUD. Wrapper around
   *         <code>v('REQUEST') (apex_application.g_request)</code>.
   */
  function request_is(
    p_request in varchar2)
    return boolean;


  /** Method to raise an exception to the APEX UI if an unhandled request was provided
   * @usage  Is used in <code>CASE</code> operations to handle unexpected request values.
   */
  procedure unhandled_request;


  /** Method to dynamically create an URL for an APEX application
   * @param  p_url_template        Base part of the URL, consisting of APP_ALIAS:PAGE_ALIAS: Reference to the page to open.
   * @param  p_hidden_item         Name of the hidden element the URL is stored at. Only applicable for the procedure overload
   * @param [p_param_items]        colon separated list of parameter items to set
   * @param [p_value_items]        colon separated list of page items on the source page that will be passed to the target page
   * @param [p_triggering_element] Page item on which the event <code>apexafterclosedialog</code> is raised.
   * @param [p_clear_cache]        Page id for which the session state is cleared.
   * @return URL of the requested page
   * @usage  Is called to create an URL for an APEX page. Wrapper around the respective APEX methods (different, based on APEX version).
   */
  function get_page_url(
    p_url_template in varchar2,
    p_param_items in varchar2 default null,
    p_value_items in varchar2 default null,
    p_triggering_element in varchar2 default null,
    p_clear_cache in binary_integer default null)
    return varchar2;
    
  /** Overload as procedure to store the calculated URL in a page item identified by P_HIDDEN_ITEM */
  procedure set_page_url(
    p_url_template in varchar2,
    p_hidden_item in varchar2,
    p_param_items in varchar2 default null,
    p_value_items in varchar2 default null);


  /** Methods to download a LOB over the browser
   * @param  p_blob       BLOB instance to download
   * @param  p_file_name  Name of the file to download.
   * @usage  Is called to offer a file as a download over APEX
   */
  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2);


  /** Overload for CLOB instances */
  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2);


  /* ASSERTIONS-Wrapper */
  /** Methods call <code>PIT.ASSERT...</code> catch them and pass them to the APEX UI by adding them to the APEX error stack
   * @param  p_condition     Test to execute
   * @param  p_message_name  PIT message name to throw if <code>P_CONDITION</code> evaluates to <code>FLASE</code>
   * @param [p_affected_id]  Page item to bind the error message to. If NULL, the error message is shown without page item relation
   * @param [p_arg_list]     Optional message arguments
   * @usage  These methods are used as a convenience wrapper around <code>PIT.ASSERT...</code> by eliminating repetitive code
   *         to encorporate the error message into the APEX error stack and assign it to a page item.
   *         Further documentation @see PIT
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