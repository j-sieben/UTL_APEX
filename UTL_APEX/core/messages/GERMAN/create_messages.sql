begin
  pit_admin.merge_message_group(
    p_pmg_name => 'UTL_APEX',
    p_pmg_description => 'Meldungen für allgemeine Utilitys');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_MISSING_ITEM',
    p_pms_text => 'Element »#1#« ist auf Seite #2# nicht enthalten',
    p_pms_description => q'^Die angegebene Seite enthält das Element niht. Prüfen Sie insbesondere die Schreibweise.^',
    p_pms_pse_id => 20,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_CONTAINS_UMLAUT',
    p_pms_text => 'Der Bezeichner »#1#« darf keine Umlaute enthalten',
    p_pms_description => q'^Es ist keine Best Practice, Sonderzeichen in Namen von Datenbankobjekten zu verwenden. In diesem Utility sind diese Namen verboten.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_TOO_LONG',
    p_pms_text => 'Der Bezeichner »#1#« ist zu lang, die Maximallänge berträgt #2# Zeichen.',
    p_pms_description => q'^Eine Maximallänge wird vorgegeben, damit noch ein Prä- oder Postfix angehängt werden kann, ohne die maximale Länge des Bezeichners zu überschreiten.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_INVALID',
    p_pms_text => 'Der Bezeichner »#1#« ist kein gültiger Datenbankbezeichner.',
    p_pms_description => q'^Verwenden Sie nur gültige Datenbankobjektnamen laut Oracle-Namenskonvention. Insbesondere sind kein geschützten Begriffe erlaubt.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_INVALID_REQUEST',
    p_pms_text => 'Für den Request »#1#« ist kein Handler hinterlegt.',
    p_pms_description => q'^In einer Auswahlliste ist für den aktuellen Requestwert kein Entschiedungsbaum hinterlegt. Daher wird dieser Request nicht behandelt.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_PAGE_ALIAS_REQUIRED',
    p_pms_text => 'Seite »#1#« benötigt ein Seitenalias, hat aber keins.',
    p_pms_description => q'^Zur internen Identifizierung verwendet das Utility Seitenaliase, auch zur Einhaltung einer Namenskonvention. Daher muss jede APEX-Seite in solches Alias erhalten.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_PARAMETER_REQUIRED',
    p_pms_text => 'Parameter »#1#« darf nicht NULL sein.',
    p_pms_description => q'^Offensichtlich.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_ITEM_VALUE_REQUIRED',
    p_pms_text => '»#ITEM#« darf nicht leer sein.',
    p_pms_description => q'^Offensichtlich.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_OBJECT_DOES_NOT_EXIST',
    p_pms_text => '#1# #2# existiert nicht.',
    p_pms_description => q'^Offensichtlich.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_FETCH_ROW_REQUIRED',
    p_pms_text => 'Die Seite benötigt einen FETCH ROW-Prozess.',
    p_pms_description => q'^Dieses Utility setzt voraus, dass auf der Seite, für die eine automatisierte Übernahme der Werte erstellt werden soll, ein Fetch-Row-Prozess existiert.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'INVALID_ITEM_PREFIX',
    p_pms_text => 'Als Parameter sind nur die Konstanten CONVERT_... erlaubt. NULL setzt den Parameter auf den hinterlegten Standardwert zurück.',
    p_pms_description => q'^Nur die erlaubten Werte dürfen für den Parameter verwendet werden.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'PAGE_ITEM_MISSING',
    p_pms_text => 'Element #1# existiert nicht auf der Anwendungsseite.',
    p_pms_description => q'^Es wurde ein Seitenelement referenziert, das nicht existiert.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'CASE_NOT_FOUND',
    p_pms_text => '#1# bei Ausführung von CASE-Anweisung nicht gefunden.',
    p_pms_description => q'^Eine Option wurde übergeben, für die kein Handler in einer CASE-Anweisung vorlag und die keinen ELSE-Zweig enthält.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'PIT',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'IMPOSSIBLE_CONVERSION',
    p_pms_text => 'Ungültige Konvertierung von Elementwert "#1#" und Formatmaske "#2#2" zum Typ #3#.',
    p_pms_description => q'^Bei der automatisierten Ermittlung eines Datums- oder Zahlenwertes konnte der Elementwert nicht korrekt konvertiert werden.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'PIT',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.create_message_package;
end;
/
