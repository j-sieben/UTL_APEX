begin
  pit_admin.merge_message_group(
    p_pmg_name => 'UTL',
    p_pmg_description => 'Messages for generic utilities');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_MISSING_ITEM',
    p_pms_text => 'Element »#1#« does not exist on page #2#',
    p_pms_description => q'^A page element was referenced that does not exist on the respective page. Assure that the page element does exist or check the spelling^',
    p_pms_pse_id => 20,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_CONTAINS_UMLAUT',
    p_pms_text => 'Name »#1#« must not contain umlauts',
    p_pms_description => q'^It's a best practice to keep column and table names free of special characters. UTL_APEX does not allow for Umlauts^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_TOO_LONG',
    p_pms_text => 'Name »#1#« is too long. Maximum length is #2# characters.',
    p_pms_description => q'^An upper limit is necessary to be able to add a post- or prefix to the name without exceeding the maximum name length.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_NAME_INVALID',
    p_pms_text => 'Name »#1#« is no valid data object name.',
    p_pms_description => q'^Provide a name that is allowed according to the Oracle naming rules. Espceially, no reserved words are allowed.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_INVALID_REQUEST',
    p_pms_text => 'Request »#1#« ist not captured.',
    p_pms_description => q'^In a CASE-list, make sure that any feasible request value is captured.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_PAGE_ALIAS_REQUIRED',
    p_pms_text => 'Page »#1#« lacks a page alias, which is required.',
    p_pms_description => q'^Page alias are used to reference pages in this utility. Therefore, any page the utility shall work upon is required to have a respective alias.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_PARAMETER_REQUIRED',
    p_pms_text => 'Parameter »#1#« must not be null.',
    p_pms_description => q'^Obvious.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_OBJECT_DOES_NOT_EXIST',
    p_pms_text => '#1# #2# does not exist.',
    p_pms_description => q'^Obvious.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'UTL_FETCH_ROW_REQUIRED',
    p_pms_text => 'Page lacks a FETCH ROW process.',
    p_pms_description => q'^To create an automated utility to grab the session values, this utility requires a fetch row process to populate the input fields on the page to be present.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL',
    p_pms_pml_name => 'AMERICAN');
    
  pit_admin.merge_message(
    p_pms_name => 'INVALID_ITEM_PREFIX',
    p_pms_text => 'Only package constants CONVERT_... are valid. If NULL the parameter is reset to the default value.',
    p_pms_description => q'^Only allowed parameter values are valid.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'PAGE_ITEM_MISSING',
    p_pms_text => 'Page item #1# does not exist.',
    p_pms_description => q'^A page item was referenced which does not exist on the actual APEX page.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.merge_message(
    p_pms_name => 'CASE_NOT_FOUND',
    p_pms_text => '#1# not found while executing CASE statement.',
    p_pms_description => q'^An option was passed into a CASE statement for which no handler exists and no ELSE option is available.^',
    p_pms_pse_id => 30,
    p_pms_pmg_name => 'PIT',
    p_pms_pml_name => 'GERMAN');
    
  pit_admin.create_message_package;
end;
/
