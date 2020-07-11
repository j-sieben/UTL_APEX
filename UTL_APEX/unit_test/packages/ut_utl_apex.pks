create or replace package ut_utl_apex
  authid definer
as
  c_app_alias constant varchar2(30 byte) := 'UTL_APEX_TEST';
  c_apex_page constant binary_integer := 1;
  c_ig_page constant binary_integer := 2;
  c_form_page constant binary_integer := 3;
  c_apex_user constant varchar2(30 byte) := $$PLSQL_UNIT_OWNER;
  c_default_date_format constant varchar2(30 byte) := 'dd.mm.yyyy';

  -- %suite (UTL_APEX Testsuite)
  --%rollback(manual)
  
  -- %beforeall (Test Suite initialisieren)
  procedure tear_up;
  
  -- %test (APEX-Session beenden)
  procedure delete_apex_session;
  
  -- %test (APEX-Session neu erzeugen)
  procedure create_apex_session;

  -- %test (Boolescher Wert entspricht der Konstanten UTL_APEX.C_TRUE)
  procedure get_true;

  -- %test (Boolescher Wert entspricht der Konstanten UTL_APEX.C_FALSE)
  procedure get_false;

  -- %test (YES/NO-Konstante entspricht der Konstanten UTL_APEX.C_YES)
  procedure get_yes;

  -- %test (YES/NO-Konstante entspricht der Konstanten UTL_APEX.C_NO)
  procedure get_no;

  -- %test (GET_BOOL liefert die Konstante UTL_APEX.C_TRUE)
  procedure get_bool_true;

  -- %test (GET_BOOL liefert die Konstante UTL_APEX.C_FALSE)
  procedure get_bool_false;

  -- %test (GET_ITEM_VALUE_CONVENTION entspricht hinterlegtem Parameter)
  procedure get_item_value_convention;

  -- %test (SET_ITEM_VALUE_CONVENTION entspricht uebergenenem Wert)
  procedure set_item_value_convention;

  -- %test (SET_ITEM_VALUE_CONVENTION setzt auf Standardwert zurueck)
  procedure set_null_item_value_convention;

  -- %test (GET_ITEM_PREFIX_CONVENTION entspricht hinterlegtem Parameter)
  procedure get_item_prefix_convention;

  -- %test (SET_ITEM_PREFIX_CONVENTION entspricht uebergenenem Wert)
  procedure set_item_prefix_convention;

  -- %test (SET_INVALID_ITEM_PREFIX_CONVENTION wirft Fehler)
  -- %throws (msg.INVALID_ITEM_PREFIX_ERR)
  procedure set_invalid_item_prefix_convention;

  -- %test (SET_NULL_ITEM_PREFIX_CONVENTION setzt auf Standardwert zurueck)
  procedure set_null_item_prefix_convention;
  
  -- %test (GET_USER liefert C_APEX_USER)
  procedure get_user;

  -- %test (GET_WORKSPACE_ID liefert aktuelle ID des Workspaces)
  procedure get_workspace_id;

  -- %test (GET_APPLICATION_ID liefert aktuelle APP ID der Anwendung C_APP_ALIAS)
  procedure get_application_id;

  -- %test (GET_APPLICATION_ALIAS liefert C_APP_ALIAS)
  procedure get_application_alias;

  -- %test (GET_PAGE_ID liefert C_APEX_PAGE)
  procedure get_page_id;

  -- %test (GET_PAGE_ALIAS liefert "HOME")
  procedure get_page_alias;
  
  -- %test (GET_PAGE_PREFIX liefert "P1_")
  procedure get_page_prefix;
  
  -- %test (GET_PAGE_PREFIX liefert "<PAGE_ALIAS>_")
  procedure get_page_prefix_page;
  
  -- %test (GET_PAGE_PREFIX liefert "<APP_ALIAS>_")
  procedure get_page_prefix_app;
  
  -- %test (GET_SSSION_ID liefert eine Zahl > 0)
  procedure get_session_id;
  
  -- %test (GET_DEBUG liefert FALSE)
  procedure get_debug;
  
  -- %test (GET_DEBUG liefert TRUE)
  procedure set_debug;
  
  -- %test (GET_REQUEST liefert NULL)
  procedure get_request_null;
  
  -- %test (GET_REQUEST liefert gesetzten Wert)
  procedure get_request;
  
  -- %test (utl_apex.INSERTING ist TRUE)
  procedure get_inserting_true;
  
  -- %test (utl_apex.INSERTING ist FALSE)
  procedure get_inserting_false;
  
  -- %test (utl_apex.UPDATING ist TRUE)
  procedure get_updating_true;
  
  -- %test (utl_apex.UPDATING ist FALSE)
  procedure get_updating_false;
  
  -- %test (utl_apex.DELETING ist TRUE)
  procedure get_deleting_true;
  
  -- %test (utl_apex.DELETING ist FALSE)
  procedure get_deleting_false;
  
  -- %test (reqquest_is ist TRUE)
  procedure request_is_true;
  
  -- %test (request_is ist FALSE)
  procedure request_is_false;
  
  -- %test (Behandle unbekannten Request
  -- %throws (msg.UTL_INVALID_REQUEST_ERR)
  procedure throw_unhandled_request;
  
  -- %test (GET_DEFAULT_DATE_FORMAT liefert C_DEFAULT_DATE_FORMAT)
  procedure get_default_date_format;
  
  -- %test (GET_DEFAULT_DATE_FORMAT liefert C_DEFAULT_DATE_FORMAT fuer eine konkrete Anwendung)
  procedure get_default_date_format_explicit;
  
  -- %test (GET_VALUE liefert NULL)
  procedure get_empty_value;
  
  -- %test (GET_VALUE auf ein nicht vorhandenes Feld wirft Fehler)
  -- %throws (msg.PAGE_ITEM_MISSING_ERR)
  procedure get_invalid_value_with_error;
  
  -- %test (GET_VALUE auf ein nicht vorhandenes Feld liefert NULL)
  procedure get_invalid_value_with_null;
  
  -- %test (SET_VALUE setzt uebergebenen Wert)
  procedure set_value;
  
  -- %test (SET_VALUE wirft bei nicht existierendem Feld Fehler)
  -- %throws (msg.PAGE_ITEM_MISSING_ERR)
  procedure set_invalid_value;
  
  -- %test (USER_IS_AUTHORIZED liefert TRUE)
  procedure user_is_authorized;
  
  -- %test (USER_IS_AUTHORIZED liefert FALSE)
  procedure user_is_not_authorized;
  
  -- %test (Nicht vorhandenes Autorisierungsschema liefefrt FALSE)
  procedure invalid_authorization;
  
  -- %test (Benuztereingaben werden als PL/SQL-Tabelle uebergeben)
  procedure get_page_values;
  
  -- %test (Benuztereingaben werden als PL/SQL-Tabelle uebergeben, nicht vorhandenes Element wird abgefragt)
  -- %throws (msg.UTL_APEX_MISSING_ITEM_ERR)
  procedure get_unknown_item_from_page_values;
  
  -- %test (Benuztereingaben in interaktives Grid werden als PL/SQL-Tabelle uebergeben)
  procedure get_page_values_from_ig;
  
  -- %test (GET_VALUE im Format JSON)
  procedure get_value_as_json;
  
  -- %test (GET_VALUE im Format HTML)
  procedure get_value_as_html;
  
  -- %test (Benuztereingaben werden als Record uebergeben)
  procedure get_page_record;
  
  -- %test (Benuztereingaben in interaktives Grid werden als Record uebergeben)
  procedure get_page_record_from_ig;
  /*
  -- %test (Benuztereingaben werden als Script uebergeben)
  procedure get_page_script;
  */
  -- %test (Simple SQL Name ist gueltig)
  procedure validate_simple_sql_name;
  
  -- %test (Simple SQL Name ist ungueltig: Name zu lang)
  procedure validate_long_sql_name;
  
  -- %test (Simple SQL Name ist ungueltig: Name enthaelt Umlaute)
  procedure validate_umlaut_sql_name;
  
  -- %test (Simple SQL Name ist ungueltig: Name verstoesst gegen Oracle-Konvention)
  procedure validate_invalid_sql_name;
  
  -- %afterall (Test Suite herunterfahren)
  procedure tear_down;

end ut_utl_apex;
/
