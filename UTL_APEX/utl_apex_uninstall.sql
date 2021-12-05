
@init.sql

prompt
prompt &section.
prompt &h1.UTL_APEX Deinstallation
@core/uninstall.sql

@check_unit_test_exists.sql "unit_test/uninstall.sql" "deinstallation"

prompt &h1.Finished UTL_APEX Deinstallation

exit
