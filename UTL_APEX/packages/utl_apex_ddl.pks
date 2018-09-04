create or replace package utl_apex_ddl
  authid definer
as
  /**
    APEX-bezogene Utility Sammlung, DDL-Anweisung und CodeGeneratoren
  */
  
  
  /** Helper to create a basic table api
   * @param  p_owner            Owner of the table or view the API aims at
   * @param  p_table_name       Name of the table or view the API aims at
   * @param  p_short_name       Abbreviated table name. Is used for method names
   * @param  p_pk_insert        Flag to indicate whether PK columns are part of the insert 1 or not 0
   *                            Useful if the PK is created using a trigger (e.g. SYS_GUID())
   *                            Default 1: PK columns are part of insert.
   * @param  p_pk_columns       Optional list of pk column names if P_TABLE_NAME is a view
   * @param  p_exclude_columns  Optional list of column names the API shall ignore
   *                            Useful to suppress housekeeping columns like VALID_FROM/TO etc.
   * @return CLOB containing code snippets to be included into a package
   * @usage  This method assumes that the objects (table and or view) ar accessible by
   *         the actual schema.
   *         Three methods are provided:
   *         - DELETE method, expecting a record of table/view%rowtype
   *         - MERGE  method, expecting a record of table/view%rowtype
   *         - MERGE  method, overloaded version with parameter list
   */
  function get_table_api(
    p_table_name in utl_apex.ora_name_type,
    p_short_name in utl_apex.ora_name_type,
    p_owner in utl_apex.ora_name_type default user,
    p_pk_insert in utl_apex.flag_type default utl_apex.C_TRUE,
    p_pk_columns in char_table default null,
    p_exclude_columns in char_table default null)
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
    p_insert_method in varchar2,
    p_update_method in varchar2,
    p_delete_method in varchar2)
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
    p_page_id in binary_integer)
    return clob;
end utl_apex_ddl;
/