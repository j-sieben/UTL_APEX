create or replace package utl_apex 
   authid definer
as
  /**
    APEX-bezogene Utility Sammlung
  */
  
  /* Public constant declarations */
  
  /* Public type declarations  */
  type page_value_t is table of varchar2(32767) index by varchar2(30);
  
  /* Public variable declarations */
  
  /* Public function and procedure declarations */
  /** Method to create an APEX session outside a browser. Used for test purposes
   * @param  p_apex_user       APEX session user
   * @param  p_application_id  ID of the application
   * @param  p_page_id         ID of the application page
   * @usage  Generates an APEX session for testing purposes. After calling this method,
   *         item values may be set by calling APEX_UTIL.SET_SESSION_STATE.
   *         Output is visible via OWA output window in SQL Developer
   */
  procedure create_apex_session(
    p_apex_user in apex_workspace_activity_log.apex_user%type,
    p_application_id in apex_applications.application_id%type,
    p_page_id in apex_application_pages.page_id%type default 1);
    
    
  /** Funktion liest alle Elementwerte der aktuellen Seite und packt sie in eine Instanz des Typs PAGE_VALUE_T.
   * @return Instanz von PAGE_VALUE_T, Schluessel ist der Name des Seitenelements OHNE Seitennummer,
   *         also anstatt P14_ENAME lediglich ENAME, um unabhängig von der Seitennummer zu sein.<br/>
   *         Als Wert enthält der Datensatz den aktuellen Elementwert des Sessionstatus
   */
  function get_page_values
    return page_value_t;
  
  
  /** Funktion zum Lesen eines Seitenelementwerts aus einer Instanz von PAGE_VALUE_T.
   * @usage  Wrapper, wird verwendet, um sprechende Fehlermeldung bei nicht vorhandenen Seitenelementen
   *         zu generieren.
   * @param  p_page_values  Instanz der Seitenwerte
   * @param  p_element_name  Name des Seitenelements
   * @return Sessionstatuswert
   */
  function get(
    p_page_values in page_value_t,
    p_element_name in varchar2)
    return varchar2;
  
  
  /** Funktion zur Erzeugung eines CLOB, das fuer eine View eine Zugriffsmethode aus APEX erstellt.
   * @param  p_application_id  Technische ID der APEX-Anwendung
   * @param  p_page_id         Technische ID der APEX-Anwendungsseite
   * @param  p_insert_method   Name der Methode, die fuer Einfuegeoperationen verwendet werden soll
   * @param  p_update_method   Name der Methode, die fuer Aktualisierungsoperationen verwendet werden soll
   * @param  p_delete_method   Name der Methode, die fuer Loeschoperationen verwendet werden soll
   * @return CLOB mit Code-Schnippseln zur Integration in Packages
   */
  function get_form_methods(
    p_application_id in number,
    p_page_id in number,
    p_insert_method in varchar2,
    p_update_method in varchar2,
    p_delete_method in varchar2)
    return clob;
  
  
  /** Methode erstellt UI-View fuer eine eine Anwendungsseite mit Collection-API 
   * @param  p_source_table  Name der Zieltabelle
   * @param  p_page_view     Name der UI-View
   * @return DDL-ANweisung, um die UI-View dieser Anwendungsseite zu erstellen.
   */
  function get_collection_view(
    p_source_table in varchar2,
    p_page_view in varchar2)
    return clob;
  
  
  /** Methode erstellt Package-Code fuer eine Collection-API einer Anwendungsseite
   * @param  p_application_id  Anwendungs-ID
   * @param  p_page_id         Anwendungsseiten-ID
   * @return Code, der als Tabellen-API dieser Seite verwendet werden kann.
   */
  function get_collection_methods(
    p_application_id in number,
    p_page_id in number)
    return clob;
  
  
  /** Funktion prueft, ob der uebergebene Name ein einfache SQL-Bezeichner ist.
   * Zusaetzlich zu DBMS_ASSERT wird geprueft, dass keine Umlaute enthalten sind.
   * @param  p_name  Name, der geprueft werden soll
   * @return Fehlermeldung, falls Pruefung nicht erfolgreich war, NULL ansonsten
   */
  function validate_simple_sql_name(
    p_name in varchar2)
    return varchar2;
  
  
  /** Prozedur zum Setzen von Validierungsfehlermeldungen.<br/>
   * Die Prozedur wird aufgerufen, um bei einer nicht erfolgreichen Validierungspruefung
   * eine Fehlermeldung an die Oberflaeche auszugeben. Die Meldung wird ausgegeben, wenn p_message NOT NULL ist.
   * @param  p_page_item  Seitenelement, das durch die Validierung betroffen ist
   * @param  p_message    Meldungstext bzw. Referenz auf eine MSG_LOG-Meldung
   * @param [p_msg_args]  Optionale Meldungsparameter
   */
  procedure set_error(
    p_page_item in varchar2,
    p_message in varchar2,
    p_msg_args in msg_args default null);
  
  
  /** Prozedur zum Setzen von Validierungsfehlermeldungen.<br/>
   * Die Prozedur wird aufgerufen, um eine Validierung durchzufuehren und, falls die Pruefung nicht TRUE war, 
   * direkt eine Fehlermeldung auszugeben.
   * Entspricht inhaltlich msg_log.assert, erlaubt aber die Zuordnung der Meldung zu einem Seitenelement.
   * @param p_test Validierung, die zu TRUE, FALSE oder NULL evaluiert
   * @param p_page_item Seitenelement, das durch die Validierung betroffen ist
   * @param p_message Meldungstext bzw. Referenz auf eine MSG_LOG-Meldung
   * @param p_msg_args Optionale Meldungsparameter
   /
  procedure set_error(
    p_test in boolean,
    p_page_item in varchar2,
    p_message in varchar2,
    p_msg_args in msg_args default null);
  
  
  /** Funktion zur Ermittlung eines Seitenpraefixes zur aktuellen Seite.
   * @return Aktuelle Seitennummer der APEX-Anwendung als Praefix der Form Pnn_
   */
  function get_page
    return varchar2;
  
  
  /** Funktion zur Analyse des Requests auf Einfuegeoperation.
   * @return TRUE, falls die entsprechende Aktion aktuell angefordert wurde
   */
  function inserting
    return boolean;
  
  /** Funktion zur Analyse des Requests auf Aktualisierungsoperation.
   * @return TRUE, falls die entsprechende Aktion aktuell angefordert wurde
   */
  function updating
    return boolean;
  
  /** Funktion zur Analyse des Requests auf Loeschoperation
   * @return TRUE, falls die entsprechende Aktion aktuell angefordert wurde
   */
  function deleting
    return boolean;
  
  /** Funktion zur Analyse, ob der aktuelle Request dem uebergebenen Request entspricht.<br/>
   * Wird verwendet, um neben den <i>normalen</i> Request auch spezielle Requestwerte pruefen zu koennen.
   * @param  p_request  Requestwert, dem der aktuell durch die Seite ausgeloeste Request entsprechen soll.
   * @return TRUE, falls die entsprechende Aktion aktuell angefordert wurde
   */
  function request_is(
    p_request in varchar2)
    return boolean;
  
  
  /** Methode zur Ausgabe einer Fehlermeldung, falls REQUEST durch aufrufenden Code nicht verabeitet werden kann.
   */
  procedure unhandled_request;
  
  
  /** Methode zur dynamischen Berechnung eines URL fuer eine modale Seite.<br/>
   * Wird verwendet, um zu ermoeglichen, dass eine modale Seite ueber dynamisch ermittelte Parameter aufgerufen wird, 
   * zum Beispiel in einem Bericht.
   * @param  p_param_items   Elementname, dem der uebergebene Parameterwert uebergeben werden soll, kann auch eine :-separierte Liste von Elementnamen sein
   * @param  p_value_items   Seitenelement, deren Wert als Parameter an die modale Seite uebergeben werden soll, kann auch eine :-separierte Liste von Elementnamen sein
   * @param  p_hidden_item   Elementname, in das der URL geschrieben werden soll. Erforderlich, weil dieser URL durch eval() ausgefuehrt wird
   * @param  p_url_template  Stammanteil des URL, bestehend aus APP_ALIAS:PAGE_ALIAS: Seite, die modal geöffnet werden soll
   */
  procedure create_modal_dialog_url(
    p_param_items in varchar2,
    p_value_items in varchar2,
    p_hidden_item in varchar2,
    p_url_template in varchar2);
  
  
  /** Methode zum Laden einer BLOB-Instanz ueber die Download-Funktion des Browsers.
   * @param  p_blob       Instanz, die als Datei ueber den Browser heruntergeladen werden soll.
   * @param  p_file_name  Name der Datei, die heruntergeladen werden soll.
   */
  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2);
    
  
  /** Methode zum Laden einer CLOB-Instanz ueber die Download-Funktion des Browsers.
   * @param  p_clob       Instanz, die als Datei ueber den Browser heruntergeladen werden soll.
   * @param  p_file_name  Name der Datei, die heruntergeladen werden soll.
   */
  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2);
  
  end utl_apex;
  /