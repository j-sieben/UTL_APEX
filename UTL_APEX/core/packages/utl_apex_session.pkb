create or replace package body utl_apex_session
as
  /**
    Package: UTL_APEX_SESSION Body
      Implementation of methods to retrieve the actual session state.

    Author::
      Juergen Sieben, ConDeS GmbH
   */


  /**
    Group: Interface
   */
  /**
    Function: describe
      see <UTL_APEX_SESSION.describe>
   */  
  function describe (tab in out nocopy dbms_tf.table_t)
    return dbms_tf.describe_t
  as
    methods dbms_tf.methods_t;
  begin
    -- Override fetch_rows method name
    methods := dbms_tf.methods_t(
                 dbms_tf.fetch_rows => 'fetch_session_state');
                 
    for i in 1 .. tab.column.count() loop
      tab.column(i).for_read := true;
    end loop;
    return dbms_tf.describe_t(method_names => methods);
  end describe;
  
  
  /**
    Procedure: fetch_session_state
      see <UTL_APEX_SESSION.fetch_session_state>
   */  
  procedure fetch_session_state
  as
    l_row_set dbms_tf.row_set_t;
    l_row_count binary_integer;
    l_column_count binary_integer;
  begin
    dbms_tf.get_row_set(l_row_set, l_row_count, l_column_count);
    return;
  end fetch_session_state;
  
  
end utl_apex_session;
/