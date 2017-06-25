create or replace package utl_apex
  authid definer
as
  /** Utility-Methoden zur Verwendung im Umfeld von APEX
   */


  /** PL/SQL-Tabelle zur Uebergabe von Sessionstatus-Werten der aktuellen Anwendungsseite
   */
  type page_value_tab is table of varchar2(32767) index by varchar2(30);

  
  /** Prozedur zum Herunterladen eines BLOB ueber den Browser
   * %param p_blob BLOB-Instanz, die heruntergeladen werden soll
   * %param p_file_name Dateiname der Datei, die heruntergeladen werden soll
   * %usage Wird verwendet, um eine BLOB-Instanz aus der Datenbank ueber den 
   *        Browser auf einen Client-PC zu laden
   */
  procedure download_blob(
    p_blob in out nocopy blob,
    p_file_name in varchar2);

  
  /** Prozedur zum Herunterladen eines CLOB ueber den Browser
   * %param p_blob CLOB-Instanz, die heruntergeladen werden soll
   * %param p_file_name Dateiname der Datei, die heruntergeladen werden soll
   * %usage Wird verwendet, um eine CLOB-Instanz aus der Datenbank ueber den 
   *        Browser auf einen Client-PC zu laden
   */
  procedure download_clob(
    p_clob in clob,
    p_file_name in varchar2);
    
  
  /* Methode zum Auslesen aller Elementwerte einer APEX-Anwendungsseite
   * %return PL/SQL-Tabelle mit den Elementwerten, Zugriff erfolgt ueber den
   *         Elementnamen
   * %usage Generisches Utility, um alle Werte der aktuellen Anwendungsseite
   *        in eine Datenstruktur zu uebernehmen. Von hier aus koennen die 
   *        Werte entweder direkt verwendet oder typsicher auf einen lokalen
   *        Record verteilt werden.
   */
  function get_page_values
    return page_value_tab;
    
  
  /* Funktion zum Lesen eines Seitenlementwerts aus einer Instang von PAGE_VALUE_TAB
   * %param p_page_values Instanz der Seitenwerte
   * %param p_element_name Name des Seitenelements
   * %return Sessionstatuswert
   * %usage Wrapper, wird verwendet, um sprechende Fehlermeldung bei nicht vorhandenen
   *        Seitenelementen zu generieren.
   */
  function get_value(
    p_page_values in page_value_tab,
    p_element_name in varchar2)
    return varchar2;
    
    
  /* Funktion zur Ermittlung des aktuellen Seitenpraefixes
   * %return Aktuelle Seitennummer der APEX-ANwenudng, als Praefix in der Form
   *         Pnn_
   */
  function get_page
    return varchar2;
    
  /* Funktion zur Analyse des Requests auf Loesch-, Aktualisierungs- oder Einfuegeoperationen
   * %return TRUE, falls die entsprechende Aktion aktuell angefordert wurde
   * %usage Mappt eine interne Liste von Requests auf die entsprechende Aktion.
   *        Kann verwendet werden, um in einer generischen Seitenverarbeitungsoperation
   *        auf eine explizite Pruefung des Requests zu verzichten
   */
  function inserting
    return boolean;
    
  function updating
    return boolean;
    
  function deleting
    return boolean;
    
    
  /* Prozedur erzeugt einen URL auf einen modalen Dialog, basierend auf einem Elementwert und legt
     den erzeugten URL in einem Hidden-Field auf der Seite ab
   * %param p_value_item Element(e), dass einen zu uebergebenden Wert enthaelt.
            Sollen mehrere Elemente uebergeben werden, muessen diese dem APEX-Prozess
            mitgegeben und hier ueber eine Komma-separierte Liste referenziert werden
   * %param p_hidden_item Element, das den generierten URL auf der Seite speichert
   * %param p_url_template Basisteil des URL, im Regelfall in der Form <APP_ALIAS>:<PAGE_ALIAS>
   * %usage Wird verwendet, um dynamisch einen modalen Dialo zu oeffnen. Das Problem ist,
            das Sessionstatuselemente uebergeben werden koennen, die zum Zeitpunkt des
            Renderns der Seite nicht bekannt sind. Daher muss der URL dynamisch
            berechnet und in einem Hidden-Field abgelegt werden.
   */
  procedure create_modal_dialog_url(
    p_value_item in varchar2,
    p_hidden_item in varchar2,
    p_url_template in varchar2);
    

  /* Methode zur Ermittlung des Authorisierungsstatus fuer eine Autorisierung
   * %param p_authorization_scheme Rolle, deren Zuordnung geprueft werden soll
   * %return Flag, das anzeigt, ob die Rolle erteilt wurde (1) oder nicht (0)
   * %usage Wird verwendet, um als generische Loesung die ACL-Funktionalitaet 
   *        von APEX auszubauen
   */
  function get_authorization_status_for(
    p_authorization_scheme in varchar2)
    return number;
    
  
  /* Prozedur erstellt eine APEX-Session ohne Browserbeteiligung
   * %param p_application_id ID der Anwendung, fuer die eine Session erstellt werden soll
   * %param p_apex_user Name des APEX-Benutzers, fuer den eine Session erstellt werden soll
   * %param p_page_id Optionale Angabe einer Seitennummer, auf die sich die folgenden Eingaben
            beziehen sollen
   * %usage Wird verwendet, um bei Tests von APEX-Komponenten keine Weboberflaeche verwenden 
            zu muessen
   */
  procedure create_apex_session(
    p_application_id in apex_applications.application_id%type,
    p_apex_user in apex_workspace_activity_log.apex_user%type,
    p_page_id in apex_application_pages.page_id%type default 1);
    
end;
/