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
  subtype flag_type is &FLAG_TYPE.;
  
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

  C_TRUE constant flag_type := &C_TRUE.;
  C_FALSE constant flag_type := &C_FALSE.;
  C_YES constant ora_name_type := 'YES';
  C_NO constant ora_name_type := 'NO';
  
  /** Constants to adjust the default item prefixes
   * @usage  CONVENTION_PAGE_PREFIX means that each item is prefixed according to the APEX standards with <code>Pnn</code>
   *         CONVENTION_PAGE_ALIAS means that each item is prefixed with the page alias you chose
   *         CONVENTION_APP_ALIAS means that each item is prefixed with the application alias you chose
   *         It is assumed that each prefix is followed by an underscore
   */
  CONVENTION_PAGE_PREFIX constant binary_integer := 1;
  CONVENTION_PAGE_ALIAS constant binary_integer := 2;
  CONVENTION_APP_ALIAS constant binary_integer := 3;

  /* Public constant declarations */

  /* Public type declarations  */
  subtype page_value_t is utl_text.clob_tab;
  subtype string_table is wwv_flow_global.vc_arr2;

  /* Public variable declarations */

  /* Public function and procedure declarations */
  /** Getter methods as wrapper around APEY provided functionality
   *  Allows for better testing and refactoring when new APEX versions occur
   */  
  function get_user
    return varchar2;
  
  function get_workspace_id(
    p_application_id in number)
    return number;

  function get_application_id
    return number;

  function get_application_alias
    return varchar2;
    
  function get_page_id
    return number;
    
  function get_page_alias
    return varchar2;
    
  /** Method to create the page prefix for the actual page
   * @return Actual page number in the form <code>Pnn_</code>, usable as a page prefix.
   */
  function get_page_prefix
   return varchar2;
    
  function get_session_id
    return number;
    
  function get_request
    return varchar2;
    
  function get_debug
    return boolean;
    
  function get_default_date_format(
    p_application_id in number default null)
    return varchar2;
    
  /** Getter for boolean values
   * @usage  As it is possible to install UTL_APEX with different settings for the FLAG_TYPE, it is required to access the
   *         boolean values using either the defined constants <code>C_TRUE</code> or <code>C_FALSE</code> or these getter
   *         when used in SQL to make the code independent from your flag type
   */
  function get_true
    return flag_type;
    
  function get_false
    return flag_type;
    
  function get_yes
    return ora_name_type;
    
  function get_no
    return ora_name_type;
    
    
  /** Method to case a boolean value to a flag type representation
   * @param  p_bool  The boolean value to convert
   * @usage  Is used to cast a boolean value to the flag type you defined when installing UTL_APEX.
   */
  function get_bool(
    p_bool in boolean)
    return flag_type;
  
  
  /** Method to define a flag that indiciates whether reading values of non existing items throws an error or not
   * @param  p_convention  Convention in use.
   * @usage  Is used to set/get the convention and to override the default. If NULL, it falls back to the parameter value.
   *         Defaults to parameter ITEM_VALUE_CONVENTION.
   */
  procedure set_item_value_convention(
    p_convention in boolean);
    
  function get_item_value_convention
    return boolean;
  
  
  /** Method to define an application wide convention for the item prefixes in use
   * @param  p_convention  Convention in use. Can be one of the CONVENTION_... constants defined in this package
   * @usage  Is used to set/get the convention and to override the default. If NULL, it falls back to the parameter value.
   *         Defaults to parameter ITEM_PREFIX_CONVENTION.
   */
  procedure set_item_prefix_convention(
    p_convention in binary_integer);
    
  function get_item_prefix_convention
    return binary_integer;
    
    
  /* Method to get/set a sessoion state value
   * @param  p_item  Name of the page item
   * @param  p_value Value of the page item
   * @usage  Is used as a wrapper around apex_util.set/get_session_state or v()
   */
  function get_value(
    p_item in varchar2)
    return varchar2;
  
  procedure set_value(
    p_item in varchar2,
    p_value in varchar2);
    
  
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


  /** Method to read all page item values from the session state and store them in an instance of PAGE_VALUE_T.
   * @param [p_static_id]  Required, if an interactive grid or a form region has to be processed.
   *                       As there are potentially more than one IG or form region per page, it is required to distinguish them 
   *                       using the static id property of the regions. Normal form pages may have set this attribute or not.
   * %param [p_format]     Optional formatting. Allowed values are all FORMAT_... constants of this package.
   *                       If set, all session state values are escaped using the respective method from APEX_ESCAPE
   * @return Instance of PAGE_VALUE_T.<br>Key of that type is the page item name WITHOUT the page prefix (Pn_), or, if present,
   *         the name of the column the item gets its value from. This is especially true for FORM regions (Apex 19 and later).
   *         The value is always given as a string, no conversion takes place.
   *         LIMITATIONS: As of now, this method only works with:
   *         - normal form pages if they contain a fetch row process
   *         - form regions
   *         - interactive grids
   */
  function get_page_values(
    p_static_id in varchar2 default null,
    p_format in varchar2 default null)
    return page_value_t;
    
    
  /** Method to grant access to page items based on different views
   * @param  p_view_name       Name of the view that implements the interface given for page item views @see RETURN documentation
   * @param  p_static_id       Optional static id used to identify interactive grids or form regions
   * @param  p_application_id  ID of the application. Used if in a static execution scenario a script for a different app/page is to be created
   * @param  p_page_id         ID of the page. Used if in a static execution scenario a script for a different app/page is to be created
   * @param [p_only_columns]   Optional flag that indicates whether only page items based on database tables should be read.
   *                           This is required if a record is to be created, as the record is of TABLE%rowtype and won't include
   *                           a rowid column for instance.
   * @return The view must return the following columns:
   *         - STATIC_ID (NULL if not present),
   *         - APPLCIATION_ID / PAGE_ID
   *         - IS_COLUMN_BASED (flag_type): Flag that indicates whether the page item value is taken from a database column
   *         - PAGE_ITEMS (utl_apex_page_item): Instance of the user defined type. @see UTL_APEX_PAGE_ITEM
   * @usage  Is used to read the page items along with meta data for these items from various APEX data dictionary views.
   *         The implementation must follow the guidelines outlined above, for examples see UTL_APEX_FETCH_ROW_COLUMNS view.
   */
  function get_page_items(
    p_view_name in ora_name_type,
    p_static_id in varchar2,
    p_application_id in number,
    p_page_id in number,
    p_only_columns in flag_type default null)
    return utl_apex_page_item_t
    pipelined;
    
    
  /** Method to create a dynamic SQL to gather all table values of the actual page as a record.
   * @param [p_static_id]  Required, if an interactive grid or a form region has to be processed.
   *                       As there are potentially more than one IG or form region per page, it is required to distinguish them 
   *                       using the static id property of the regions. Normal form pages may have set this attribute or not.
   * %param [p_table_name] Is required if a form region has an inline SQL query or a interactive grid is used, as in these
   *                       cases no information on the table used is available. If set, it is used as a fallback information
   *                       in case no better information is available (such as from a fetch row process or a form region)
   * @return PL/SQL block that can be executed immediate to return a record instance filled with the page values in a type save
   *         manner. Conversion is done based on the page meta data.
   * @usage  Method retrieves all session state values in a type save manner. It works with normal form pages (pre 19.1) as well 
   *         as with form regions (since 19.1) and interactive grid rows (since 5.1).
   *         As form regions and interactive grids can occur more than once on a page, it is required to mark the regions using
   *         a static id property. Without this, the method will not return any values.
   *         If the form region uses an inline SQL query or if an interactive grid, you must pass in the name of the table
   *         the record gets its structure from.
   *         If used with a regular form page, it is required that the page has a fetch row process to get its data, otherwise
   *         this method will not work.
   *         EXAMPLE: To use this method, call it with execute immediate and pass the record to a predefined output record L_ROW:
   *         <code> l_row your_table%rowtype;</code>
   *         <code> execute immediate utl_apex.get_page_record using out l_row;</code>
   */
  function get_page_record(
    p_static_id in varchar2 default null,
    p_table_name in varchar2 default null)
    return varchar2;
  
  
  /** Method to create a script that can be imported into a package to take over all values of a page.
   * @param [p_static_id]      Required, if an interactive grid or a form region has to be processed.
   *                           As there are potentially more than one IG or form region per page, it is required to distinguish them 
   *                           using the static id property of the regions. Normal form pages may have set this attribute or not.
   * %param [p_table_name]     Name of the table the data is written to. Required if the form does not have a fetch row process
   *                           (such as with interactive grid) or the form region is based on a SQL query instead on a table or view
   * %param  p_application_id  APEX application id. IF NULL, apex_application.g_flow_id is used.
   * %param  p_page_id         APEX page id. If NULL, apex_application.g_flow_step_id is used.
   * %param  p_record_name     Name of the resulting record.
   * %return PL/SQL block to copy and convert the page values into a record. The record structure is taken from P_TARGET_TABLE
   * %usage  Generic utility to create code that reads the actual session state. <br>
   *         This method creates PL/SQL code that can be directly copied into a package:
   *         <code>select utl_apex.get_ig_values('MY_TABLE_NAME', 'abc', 123, 1) from dual </code>
   *         This call will generate a global record of <code>P_TABLE_NAME%ROWTYPE</code>, named <code>P_RECORD_NAME</code>
   */
  function get_page_item_script(
    p_static_id in varchar2 default null,
    p_table_name in varchar2 default null,
    p_application_id in number,
    p_page_id in number,
    p_record_name in varchar2)
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
    p_name in ora_name_type)
    return ora_name_type;


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
    p_application in varchar2 default null,
    p_page in varchar2 default null,
    p_param_items in varchar2 default null,
    p_value_items in varchar2 default null,
    p_triggering_element in varchar2 default null,
    p_clear_cache in binary_integer default null)
    return varchar2;
    
  /** Overload as procedure to store the calculated URL in a page item identified by P_HIDDEN_ITEM */
  procedure set_page_url(
    p_hidden_item in varchar2,
    p_application in varchar2 default null,
    p_page in varchar2 default null,
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
    
    
  /** Method to stop the rendering process of APEX.
   * @usage  Is used to prevent further rendering of the APEX machine. Call it if no further rendering is necessary (such as
   *         when downloading files) or when a fatal error has occurred.
   */
  procedure stop_apex;


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