set verify off
set serveroutput on
set echo off
set feedback off
set lines 120
set pages 9999
whenever sqlerror exit
clear screen

col sys_user new_val SYS_USER format a30
col install_user new_val INSTALL_USER format a30
col default_language new_val DEFAULT_LANGUAGE format a30

select user sys_user,
       upper('&1.') install_user,
       upper('&2.') default_language
  from V$NLS_VALID_VALUES
 where parameter = 'LANGUAGE'
   and value = upper('&2.');
  
col ver_le_0500 new_val VER_LE_0500 format a5
col ver_le_0501 new_val VER_LE_0501 format a5
col ver_le_05 new_val VER_LE_05 format a5
col ver_le_1801 new_val VER_LE_1801 format a5
col ver_le_18 new_val VER_LE_18 format a5

select case when username like 'APEX_05%' then 'true'
       else 'false' end ver_le_05,
       case username
       when 'APEX_050000' then 'true'
       else 'false' end ver_le_0500,
       case username
       when 'APEX_050100' then 'true'
       else 'false' end ver_le_0501,
       case when username like 'APEX_18%' then 'true'
       else 'false' end ver_le_18,
       case username
       when 'APEX_180100' then 'true'
       else 'false' end ver_le_1801
  from all_users
 where regexp_like (username, 'APEX_[0-9]{6}');

define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "
