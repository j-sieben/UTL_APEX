set verify off
set serveroutput on
set echo off
set feedback off
set lines 120
set pages 9999
whenever sqlerror exit
set termout off

define MIN_UT_VERSION="v3.1"

col ora_name_type new_val ORA_NAME_TYPE format a128
col flag_type new_val FLAG_TYPE format a128
col c_quote new_val C_QUOTE format a128
col default_language new_val DEFAULT_LANGUAGE format a128
col c_true new_val C_TRUE format a128
col c_false new_val C_FALSE format a128

select lower(data_type) || '(' || data_length || case char_used when 'B' then ' byte)' else ' char)' end ORA_NAME_TYPE
  from all_tab_columns
 where table_name = 'USER_TABLES'
   and column_name = 'TABLE_NAME';

select lower(data_type) || '(' || data_length || case char_used when 'B' then ' byte)' else ' char)' end FLAG_TYPE,
       case when data_type in ('CHAR', 'VARCHAR2') then dbms_assert.enquote_literal(pit_util.c_true) else pit_util.c_true end C_TRUE, 
       case when data_type in ('CHAR', 'VARCHAR2') then dbms_assert.enquote_literal(pit_util.c_false) else pit_util.c_false end C_FALSE
  from all_tab_columns
 where table_name = 'PARAMETER_LOCAL'
   and column_name = 'PAL_BOOLEAN_VALUE';

select pit.get_default_language DEFAULT_LANGUAGE
  from dual;
  
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
col ver_le_2002 new_val VER_LE_2002 format a5
col ver_le_21 new_val VER_LE_21 format a5
col ver_le_2101 new_val VER_LE_2101 format a5
col ver_le_2102 new_val VER_LE_2102 format a5
col ver_le_22 new_val VER_LE_22 format a5
col ver_le_2201 new_val VER_LE_2201 format a5
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
       case minor_version
         when 20.2 then 'true'
         else 'false' end ver_le_2002,
       case major_version 
         when 21 then 'true'
         else 'false' end ver_le_21,
       case minor_version
         when 21.1 then 'true'
         else 'false' end ver_le_2101,
       case minor_version
         when 21.2 then 'true'
         else 'false' end ver_le_2102,
       case major_version 
         when 221 then 'true'
         else 'false' end ver_le_22,
       case minor_version
         when 22.1 then 'true'
         else 'false' end ver_le_2201,
       to_char(minor_version, 'fm99.99') apex_version
  from apex_version;

   
define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "

prompt &s1.initialization done.
set termout on
set serveroutput on
