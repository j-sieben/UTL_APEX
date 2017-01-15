create or replace package utl_apex
  authid definer
as
  /** Utility-Methoden zur Verwendung im Umfeld von APEX
   */


  /** PL/SQL-Tabelle zur Uebergabe von Sessionstatus-Werten der aktuellen Anwendungsseite
   */
  type value_table is table of varchar2(32767) index by varchar2(30);

  
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
    return value_table;
    

  /* Methode zur Ermittlung des Authorisierungsstatus fuer eine Autorisierung
   * %param p_authorization_scheme Rolle, deren Zuordnung geprueft werden soll
   * %return Flag, das anzeigt, ob die Rolle erteilt wurde (1) oder nicht (0)
   * %usage Wird verwendet, um als generische Loesung die ACL-Funktionalitaet 
   *        von APEX auszubauen
   */
  function get_authorization_status_for(
    p_authorization_scheme in varchar2)
    return number;
    
    
end;
/