begin
  pit_admin.merge_message_group(
    p_pmg_name => 'UTL',
    p_pmg_description => 'Meldungen für allgemeine Utilitys');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_MISSING_ITEM',
    p_pms_text => 'Element »#1#« ist auf Seite #2# nicht enthalten',
    p_pms_description => q'^Die angegebene Seite enthält das Element niht. Prüfen Sie insbesondere die Schreibweise.^',
    p_pms_pse_id => 20,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_CONTAINS_UMLAUT',
    p_pms_text => 'Der Bezeichner »#1#« darf keine Umlaute enthalten',
    p_pms_description => q'^Es ist keine Best Practice, Sonderzeichen in Namen von Datenbankobjekten zu verwenden. In diesem Utility sind diese Namen verboten.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_TOO_LONG',
    p_pms_text => 'Der Bezeichner »#1#« ist zu lang, die Maximallänge berträgt #2# Zeichen.',
    p_pms_description => q'^Eine Maximallänge wird vorgegeben, damit noch ein Prä- oder Postfix angehängt werden kann, ohne die maximale Länge des Bezeichners zu überschreiten.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_INVALID',
    p_pms_text => 'Der Bezeichner »#1#« ist kein gültiger Datenbankbezeichner.',
    p_pms_description => q'^Verwenden Sie nur gültige Datenbankobjektnamen laut Oracle-Namenskonvention. Insbesondere sind kein geschützten Begriffe erlaubt.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_INVALID_REQUEST',
    p_pms_text => 'Für den Request »#1#« ist kein Handler hinterlegt.',
    p_pms_description => q'^In einer Auswahlliste ist für den aktuellen Requestwert kein Entschiedungsbaum hinterlegt. Daher wird dieser Request nicht behandelt.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_PAGE_ALIAS_REQUIRED',
    p_pms_text => 'Seite »#1#« benötigt ein Seitenalias, hat aber keins.',
    p_pms_description => q'^Zur internen Identifizierung verwendet das Utility Seitenaliase, auch zur Einhaltung einer Namenskonvention. Daher muss jede APEX-Seite in solches Alias erhalten.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_PARAMETER_REQUIRED',
    p_pms_text => 'Parameter »#1#« darf nicht NULL sein.',
    p_pms_description => q'^Offensichtlich.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_OBJECT_DOES_NOT_EXIST',
    p_pms_text => '#1# #2# existiert nicht.',
    p_pms_description => q'^Offensichtlich.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_FETCH_ROW_REQUIRED',
    p_pms_text => 'Die Seite benötigt einen FETCH ROW-Prozess.',
    p_pms_description => q'^Dieses Utility setzt voraus, dass auf der Seite, für die eine automatisierte Übernahme der Werte erstellt werden soll, ein Fetch-Row-Prozess existiert.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.create_message_package;
end;
/
