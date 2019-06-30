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
col install_user new_val INSTALL_USER format a30
col remote_user new_val REMOTE_USER format a30
col default_language new_val DEFAULT_LANGUAGE format a30

select user sys_user,
       upper('&1.') install_user,
       upper('&2.') default_language
  from V$NLS_VALID_VALUES
 where parameter = 'LANGUAGE'
   and value = upper('&2.');
   
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

select case when max(username) like 'APEX_05%' then 'true'
       else 'false' end ver_le_05,
       case max(username)
       when 'APEX_050000' then 'true'
       else 'false' end ver_le_0500,
       case max(username)
       when 'APEX_050100' then 'true'
       else 'false' end ver_le_0501,
       case when max(username) like 'APEX_18%' then 'true'
       else 'false' end ver_le_18,
       case max(username)
       when 'APEX_180100' then 'true'
       else 'false' end ver_le_1801,
       case max(username)
       when 'APEX_180200' then 'true'
       else 'false' end ver_le_1802,
       case max(username)
       when 'APEX_190100' then 'true'
       else 'false' end ver_le_19,
       case max(username)
       when 'APEX_190100' then 'true'
       else 'false' end ver_le_1901
  from all_users
 where regexp_like (username, 'APEX_[0-9]{6}');

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

set termout on