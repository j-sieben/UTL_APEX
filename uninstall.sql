@init.sql

alter session set current_schema=&INSTALL_USER.;

prompt &h1.State UTL_APEX Deinstallation
@clean_up_install.sql

exit;
