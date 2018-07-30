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

select user sys_user,
       upper('&1.') install_user
  from dual;
  
col ver_le_0500 new_val VER_LE_0500 format a5
col ver_le_0501 new_val VER_LE_0501 format a5
col ver_le_1801 new_val VER_LE_1801 format a5

select case username
       when 'APEX_050000' then 'true'
       else 'false' end ver_le_0500,
       case username
       when 'APEX_050100' then 'true'
       else 'false' end ver_le_0501,
       case username
       when 'APEX_180100' then 'true'
       else 'false' end ver_le_1801
  from all_users
 where username in ('APEX_050000', 'APEX_050100', 'APEX_180100');

define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "
