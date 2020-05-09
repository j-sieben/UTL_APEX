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
  );

  param_admin.edit_parameter(
    p_par_id => 'ITEM_VALUE_CONVENTION'
   ,p_par_pgr_id => 'UTL_APEX'
   ,p_par_description => 'Sets the convention on whether reading a session value from a non existing item throws an error or not.'
  );

  commit;
end;
/