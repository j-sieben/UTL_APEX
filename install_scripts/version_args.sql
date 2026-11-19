-- Only validated launcher/release values may be passed as SQL*Plus arguments.
set define &
set concat .
set verify off
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
define UTL_APEX_VERSION = "&1."
define UTL_APEX_GIT_COMMIT = "&2."
@@validate_version.sql
