begin
  param_admin.edit_parameter_group(
    p_pgr_id => 'UTL_APEX',
    p_pgr_description => 'Parameters for UTL_APEX'
    );
    
  param_admin.edit_parameter(
    p_par_id => 'ITEM_PREFIX_CONVENTION',
    p_par_pgr_id => 'UTL_APEX',
	  p_par_description => 'Sets the convention used to prefix page items.',
    p_par_integer_value => utl_apex.CONVENTION_PAGE_PREFIX,
    p_par_validation_string => '#NUMBER_VAL# in (1, 2, 3)',
    p_par_validation_message => 'Only one of the utl_apex.CONVENTION_... values are allowed.');
    
  param_admin.edit_parameter(
    p_par_id => 'ITEM_VALUE_CONVENTION',
    p_par_pgr_id => 'UTL_APEX',
	  p_par_description => 'Sets the convention on whether reading a session value from a non existing item throws an error or not.',
    p_par_boolean_value => true);
end;
/