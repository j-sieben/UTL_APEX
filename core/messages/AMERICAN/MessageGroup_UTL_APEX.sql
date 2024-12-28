begin

  pit_admin.merge_message_group(
    p_pmg_name => 'UTL_APEX',
    p_pmg_description => q'^Meldungen für UTL_APEX^');

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_INVALID_ITEM_PREFIX',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^Only the constants CONVERT_... are allowed as parameters. are allowed as parameters. NULL resets the parameter to the stored default value.^',
    p_pms_description => q'^Only the allowed values may be used for the parameter.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_MISSING_ITEM',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^Element "#1#" is not included on page #2#.^',
    p_pms_description => q'^The specified page does not contain the element. In particular, check the spelling.^',
    p_pms_pse_id => pit.level_fatal,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_FETCH_ROW_REQUIRED',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^The page needs a FETCH ROW process.^',
    p_pms_description => q'^This utility assumes that a fetch row process exists on the page for which an automated transfer of values is to be created.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_INVALID_REQUEST',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^No handler is stored for the request "#1#".^',
    p_pms_description => q'^In a case expression, no decision tree is stored for the current request value. Therefore, this request is not handled.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_ITEM_VALUE_REQUIRED',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^"#ITEM#" must not be empty.^',
    p_pms_description => q'^Obviously.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_NAME_CONTAINS_UMLAUT',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^The identifier "#1#" must not contain umlauts^',
    p_pms_description => q'^It is not a best practice to use special characters in names of database objects. In this utility these names are forbidden.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_NAME_INVALID',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^The identifier "#1#" is not a valid database identifier.^',
    p_pms_description => q'^Use only valid database object names according to Oracle naming convention. In particular, no proprietary terms are allowed.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_NAME_TOO_LONG',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^The identifier "#1#" is too long, the maximum length is #2# characters.^',
    p_pms_description => q'^A maximum length is specified so that a prefix or postfix can still be appended without exceeding the maximum length of the identifier.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_OBJECT_DOES_NOT_EXIST',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^#1# #2# does not exist.^',
    p_pms_description => q'^Obvious.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_PAGE_ALIAS_REQUIRED',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^Page "#1#" needs a page alias, but does not have one.^',
    p_pms_description => q'^For internal identification the utility uses page aliases, also for keeping a naming convention. That's why each APEX page must be given such an alias.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_PARAMETER_REQUIRED',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^Parameter "#1#" must not be NULL.^',
    p_pms_description => q'^Obvious.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_ITEM_IS_REQUIRED',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^Element "#LABEL#" is a mandatory field.^',
    p_pms_description => q'^Obviously.^',
    p_pms_pse_id => pit.level_error,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_INVALID_MAPPING',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^No mapping found for error code #1#.^',
    p_pms_description => q'^Check whether a mapping to an input element should be carried out for this error.^',
    p_pms_pse_id => pit.level_warn,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null);

  pit_admin.merge_message(
    p_pms_name => 'UTL_APEX_NO_IG_SUPPORT',
    p_pms_pmg_name => 'UTL_APEX',
    p_pms_text => q'^Handling IG errors in UTL_APEX is not yet supported due to a missing API for it.^',
    p_pms_description => q'^^',
    p_pms_pse_id => pit.level_warn,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null);

  commit;
  pit_admin.create_message_package;
end;
/