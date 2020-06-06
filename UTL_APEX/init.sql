set verify off
set serveroutput on
set echo off
set feedback off
set lines 120
set pages 9999
whenever sqlerror exit
clear screen
set termout off

col sys_user new_val SYS_USER format a30
col apex_user new_val APEX_USER format a30
col install_user new_val INSTALL_USER format a30
col remote_user new_val REMOTE_USER format a30
col default_language new_val DEFAULT_LANGUAGE format a30

select user sys_user,
       upper('&1.') install_user,
       upper('&2.') default_language
  from V$NLS_VALID_VALUES
 where parameter = 'LANGUAGE'
   and value = upper('&2.');
   
select username apex_user
  from all_users
 where username like 'APEX_______'
   and oracle_maintained = 'Y'
 order by username desc
 fetch first row only;
   
select owner remote_user
  from dba_tab_privs
 where grantee = '&INSTALL_USER.'
   and table_name = 'PIT_ADMIN';
  
col ver_le_0500 new_val VER_LE_0500 format a5
col ver_le_0501 new_val VER_LE_0501 format a5
col ver_le_05 new_val VER_LE_05 format a5
col ver_le_1801 new_val VER_LE_1801 format a5
col ver_le_1802 new_val VER_LE_1802 format a5
col ver_le_18 new_val VER_LE_18 format a5
col ver_le_19 new_val VER_LE_19 format a5
col ver_le_1901 new_val VER_LE_1901 format a5
col ver_le_1902 new_val VER_LE_1902 format a5
col ver_le_20 new_val VER_LE_20 format a5
col ver_le_2001 new_val VER_LE_2001 format a5
col apex_version new_val apex_version format a30
with apex_version as(
       select to_number(substr(version_no, 1, instr(version_no, '.', 1) - 1)) major_version, 
              to_number(substr(version_no, 1, instr(version_no, '.', 1, 2) - 1), '99.99') minor_version
         from apex_release r)
select case major_version 
         when 5 then 'true'
         else 'false' end ver_le_05,
       case minor_version
         when 5.0 then 'true'
         else 'false' end ver_le_0500,
       case minor_version
         when 5.1 then 'true'
         else 'false' end ver_le_0501,
       case major_version 
         when 18 then 'true'
         else 'false' end ver_le_18,
       case minor_version
         when 18.1 then 'true'
         else 'false' end ver_le_1801,
       case minor_version
         when 18.2 then 'true'
         else 'false' end ver_le_1802,
       case major_version 
         when 19 then 'true'
         else 'false' end ver_le_19,
       case minor_version
         when 19.1 then 'true'
         else 'false' end ver_le_1901,
       case minor_version
         when 19.2 then 'true'
         else 'false' end ver_le_1902,
       case major_version 
         when 20 then 'true'
         else 'false' end ver_le_20,
       case minor_version
         when 20.1 then 'true'
         else 'false' end ver_le_2001,
       to_char(minor_version, 'fm99.99') apex_version
  from apex_version;

col ora_name_type new_val ORA_NAME_TYPE format a30

select 'varchar2(' || data_length || ' byte)' ORA_NAME_TYPE
  from all_tab_columns
 where table_name = 'USER_TABLES'
   and column_name = 'TABLE_NAME';

-- ADJUST THIS SETTING IF YOU WANT ANOTHER TYPE 
define FLAG_TYPE="char(1 byte)";
define C_TRUE="'Y'";
define C_FALSE="'N'";

--define FLAG_TYPE="number(1, 0)";
--define C_TRUE=1;
--define C_FALSE=0;

define MIN_UT_VERSION="v3.1"
   
define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "

prompt &s1.initialization done.
set termout on
set serveroutput on
