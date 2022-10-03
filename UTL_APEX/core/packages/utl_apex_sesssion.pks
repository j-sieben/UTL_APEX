create or replace package utl_apex_session
  authid definer
as
    
  
  /**
    Package: UTL_APEX_SESSION
      Package to implement a PTF to retrieve the actual session state

    Author::
      Juergen Sieben, ConDeS GmbH
   */

  /**
    Constants: Public Constants
  */
  
  /** 
    Function: get_session_state_for
      Polymorphic table function (PTF) to retrieve a type save representation of the
      session state values for a given form
      
    Parameter:
      p_table - Table or viewn that is the basis of the form that contains the data
                It may be the UI-View used for the form or the underlying view or
                table for the UI-View in case all column names match
                
    Returns:
      Record of type <P_TABLE> with all found session state values
   */
  function get_session_state_for(
    p_table in table)
    return table 
      pipelined
      row polymorphic 
      using utl_apex_session;
      
      
  /**
    Function: describe
      DESCRIBE function implementation of the PTF
      
    Returns: Instance of <DBMS_TF.TABLE_T>
   */
  function describe (tab in out nocopy dbms_tf.table_t)
    return dbms_tf.describe_t;
    
  /**
    Procedure: fetch_session_state
      FETCH_ROWS procedure implementation of the PTF
   */
  procedure fetch_session_state;
  
  
end utl_apex_session;
/