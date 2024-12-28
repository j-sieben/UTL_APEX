begin

  param_admin.edit_parameter_group(
    p_pgr_id => 'UTL_APEX',
    p_pgr_description => 'Parameters for UTL_APEX',
    p_pgr_is_modifiable => true
  );

  param_admin.edit_parameter(
    p_par_id => 'ITEM_PREFIX_CONVENTION'
   ,p_par_pgr_id => 'UTL_APEX'
   ,p_par_description => 'Sets the convention used to prefix page items.'
   ,p_par_integer_value => 1
   ,p_par_boolean_value => null
   ,p_par_is_modifiable => null
   ,p_par_validation_string => q'^#INTEGER# in (1, 2, 3)^'
   ,p_par_validation_message => q'^Only one of the utl_apex.CONVENTION_... values are allowed.^'
  );

  param_admin.edit_parameter(
    p_par_id => 'ITEM_VALUE_CONVENTION'
   ,p_par_pgr_id => 'UTL_APEX'
   ,p_par_description => 'Sets the convention on whether reading a session value from a non existing item throws an error or not.'
   ,p_par_boolean_value => true
   ,p_par_is_modifiable => null
  );

  param_admin.edit_parameter(
    p_par_id => 'SHOW_ITEM_ERROR_AT_NOTIFICATION'
   ,p_par_pgr_id => 'UTL_APEX'
   ,p_par_description => 'Sets the convention on whether showing page item errors at the item only (FALSE) or at item and notification area (TRUE).'
   ,p_par_boolean_value => true
   ,p_par_is_modifiable => null
  );

  commit;
end;
/