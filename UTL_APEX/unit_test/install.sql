define UT_DIR=unit_test/
define pkg_dir=&UT_DIR.packages/
define script_dir=&UT_DIR.scripts/
define type_dir=&UT_DIR.types/
define view_dir=&UT_DIR.views/
define msg_dir=&UT_DIR.messages/&DEFAULT_LANGUAGE./
define apex_dir=&UT_DIR.apex/

prompt
prompt &section.
prompt &h1.Install UTL_APEX unit tests

prompt
prompt &section.
prompt &h2.Views
prompt &s1.View UTL_APEX_UI_HOME_MAIN
@&VIEW_DIR.utl_apex_ui_home_main.vw

prompt
prompt &section.
prompt &h2.Packages
prompt &s1.Package UTL_APEX_TEST
@&PKG_DIR.utl_apex_test.pks

prompt &s1.Package Body UTL_APEX_TEST
@&PKG_DIR.utl_apex_test.pkb

--prompt
--prompt &section.
--prompt &h2.APEX application
--prompt &h3.Prepare APEX import
--@&UT_DIR.prepare_app_import.sql

--prompt &h3.Install application
--@&APEX_DIR.utl_apex.sql

-- After APEX installation, reset output settings
set define on
set verify off
set serveroutput on
set echo off
set feedback off
set lines 120
set pages 9999
whenever sqlerror exit
alter session set current_schema=&INSTALL_USER.;

prompt
prompt &section.
prompt &h1.Installation of UTL_APEX unit tests complete