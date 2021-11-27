create or replace package utl_dev_apex
  authid definer
as
  /**
    APEX-bezogene Utility Sammlung, DDL-Anweisung und CodeGeneratoren
  */
  
  
  /** Helper to create an APEX session for testing purposes
   * @param  p_app_id       ID of the application
   * @param  p_app_page_id  ID of the page, required to control automatic session state value takeover
   * @param  p_app_user     ID of the user the session is attached to, controls access rights
   * @usage  Is used to create an APEX session from PL/SQL. Useful for automated testing of UOI packages.
   */
  procedure create_session(
    p_app_id in apex_applications.application_id%type,
    p_app_page_id in apex_application_pages.page_id%type default 1,
    p_app_user in apex_workspace_activity_log.apex_user%type);
    
    
  /** Helper to free an APEX session for testing purposes
   */
  procedure drop_session;
  
  
  /** Helper to allow to capture output of the web toolkit in automated tests
   */
  procedure init_owa;
  
  /** Helper to create a basic table api
   * @param  p_table_name          Name of the table or view the API aims at
   * @param  p_short_name          Abbreviated table name. Is used for method names
   * @param [p_owner]              Owner of the table or view the API aims at
   * @param [p_pk_insert]          Flag to indicate whether PK columns are part of the insert 1 or not 0
   *                               Useful if the PK is created using a trigger (e.g. SYS_GUID())
   *                               Default 1: PK columns are part of insert.
   * @param [p_pk_columns]         Optional list of pk column names if P_TABLE_NAME is a view without constraints
   * @param [p_exclude_columns]    Optional list of column names to be ignored by the API
   *                               Useful to suppress housekeeping columns like VALID_FROM/TO etc.
   * @param [p_include_table_view] Flag to indicate whether a table view has to be generated when creating a
   *                               TAPI on a table. If set to UTL_APEX.C_TRUE (default) the access methods
   *                               reference the view instead of the table.
   * @return CLOB containing code snippets to be included into a package
   * @usage  This method assumes that the objects (table and or view) ar accessible by
   *         the actual schema.
   *         Three methods are provided:
   *         - DELETE method, expecting a record of table/view%rowtype
   *         - MERGE  method, expecting a record of table/view%rowtype
   *         - MERGE  method, overloaded version with parameter list
   *         If the referenced object is a table, an access view is also provided
   */
  function get_table_api(
    p_table_name in utl_apex.ora_name_type,
    p_short_name in utl_apex.ora_name_type,
    p_owner in utl_apex.ora_name_type default user,
    p_pk_insert in utl_apex.flag_type default utl_apex.c_true,
    p_pk_columns in char_table default null,
    p_exclude_columns in char_table default null,
    p_include_table_view in utl_apex.flag_type default utl_apex.c_true)
    return clob;
  
  
  /** Helper to create a PL/SQL stub to implement forms logic
   * @param  p_application_id  APEX application ID
   * @param  p_page_id         APEX page id
   * @param  p_insert_method   name of the insert method of the BL package
   * @param  p_update_method   name of the update method of the BL package
   * @param  p_delete_method   name of the delete method of the BL package
   * @return CLOB containing code snippets to be included into a package
   * @usage  This method assumes that the following conditions are met:
   *         - The application page is based on a UI-View
   *         - A package exists at the business logic layer that provides methods to
   *           insert, update and delete a row. As an input parameter, these methods
   *           expext a record of <UI-View>%ROWTYPE (or compatible, i.e. with the same declaration)
   *         By passing in the application- and page-id, the method creates PL/SQL code to
   *         - copy the session status into a local record
   *         - cast datatypes to the required data types if necessary
   *         - call the methods of the business layer
   */
  function get_form_methods(
    p_application_id in binary_integer,
    p_page_id in binary_integer,
    p_static_id in varchar2 default null,
    p_check_method in varchar2 default null,
    p_insert_method in varchar2 default null,
    p_update_method in varchar2 default null,
    p_delete_method in varchar2 default null)
    return clob;
  
  
  /** Method to create a view that maps C_001-columns to intutitve column names
   *  taken from the base table or view
   * @param  p_source_table  Name of the table the data finally is stored at
   * @param  p_page_view     Name of the UI-View that shows data from the collection
   * @return DDL statement to create a view based on a collection
   * @usage  This method assumes that the following conditions are met:
   *         - it is called on an existing table or view.
   *         - the collection name equals the view name
   *         - the APEX page is built on the view, fetching the values from a 
   *           FETCH ROW process from P_PAGE_VIEW
   *         A limitation exists in that the method is unable to see or react on
   *         format masks added while creating the page. If this is necessary,
   *         adjust P_PAGE_VIEW by hand
   */
  function get_collection_view(
    p_source_table in utl_apex.ora_name_type,
    p_page_view in utl_apex.ora_name_type)
    return clob;
  
  
  /** Method to create a package that works as an API on a form that is built as
   *  an editor for a report based on a collection
   * @param  p_application_id  Anwendungs-ID
   * @param  p_page_id         Anwendungsseiten-ID
   * @param [p_static_id]      Required if a form region is used. If NOT NULL, only form regions work, otherwise legacy 
   *                           forms are perceived.
   * @return Code that creates a package with all necessary methods to maintain
   *         a row of the collection
   * @usage  This method assumes that the following conditions are met:
   *         - An APEX page based on a view created by GET_COLLECTION_VIEW exists
   *         - The values are inserted to the page using a FETCH ROW process
   *         - No changes are made to the item names. They are identical to the
   *           column names of the view
   *         - the page calls this packages VALIDATE_<PAGE_ALIAS> and PROCESS_<PAGE_ALIAS> 
   *           methods to storedata at the collection. PROCESS methods are used 
   *           to insert, update and delete a row of the collection.
   */
  function get_collection_methods(
    p_application_id in binary_integer,
    p_page_id in binary_integer,
    p_static_id in varchar2 default null)
    return clob;
  
  
  /** Method to create a script that can be imported into a package to take over all values of a page.
   * @param [p_static_id]      Required, if an interactive grid or a form region has to be processed.
   *                           As there are potentially more than one IG or form region per page, it is required to distinguish them 
   *                           using the static id property of the regions. Normal form pages may have set this attribute or not.
   * @param [p_table_name]     Name of the table the data is written to. Required if the form does not have a fetch row process
   *                           (such as with interactive grid) or the form region is based on a SQL query instead on a table or view
   * @param  p_application_id  APEX application id. IF NULL, apex_application.g_flow_id is used.
   * @param  p_page_id         APEX page id. If NULL, apex_application.g_flow_step_id is used.
   * @param  p_record_name     Name of the resulting record.
   * @return PL/SQL block to copy and convert the page values into a record. The record structure is taken from P_TARGET_TABLE
   * @usage  Generic utility to create code that reads the actual session state. <br>
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
    
    
  /** Method to create a private package method to copy a view to a table record.
   * @param  p_view_name       Name of the APEX page UI view that serves as a source of the data
   * @param  p_table_name      Name of the target table 
   * @param  p_table_shortcut  Abbreviated name of the table, is used in the name of the resulting method
   * @usage  Is used to create a method that copies all columns of the view to columns of the table it refers to.
   *         This method is required only if a form contains data of more than one table and you want to split the
   *         columns to the respective tables. As a consequence, this method will only copy those columns which have
   *         an identical name.
   */
  function copy_view_to_table_script(
    p_view_name in utl_apex.ora_name_type,
    p_table_name in utl_apex.ora_name_type,
    p_table_shortcut in utl_apex.ora_name_type)
    return varchar2;
    
end utl_dev_apex;
/