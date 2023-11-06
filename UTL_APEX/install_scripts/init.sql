set verify off
set serveroutput on
set echo off
set feedback off
set lines 120
set pages 9999

whenever sqlerror continue
alter session set plsql_implicit_conversion_bool = true;

whenever sqlerror exit

set termout off

define MIN_UT_VERSION="v3.1"
variable with_pit_var varchar2(10 byte);
variable flag_type_var varchar2(100);
variable true_var varchar2(10 byte);
variable false_var varchar2(10 byte);
variable default_lang_var varchar2(128 byte);

col ora_name_type new_val ORA_NAME_TYPE format a128
col flag_type new_val FLAG_TYPE format a128
col default_language new_val DEFAULT_LANGUAGE format a128
col c_true new_val C_TRUE format a128
col c_false new_val C_FALSE format a128
col pit_installed new_val PIT_INSTALLED format a128

select lower(data_type) || '(' || data_length || case char_used when 'B' then ' byte)' else ' char)' end ORA_NAME_TYPE
  from all_tab_columns
 where table_name = 'USER_TABLES'
   and column_name = 'TABLE_NAME';

begin
  :with_pit_var := 'true';
  execute immediate 'begin :x := pit_util.C_TRUE; end;' using out :true_var;
  execute immediate 'begin :x := pit_util.C_FALSE; end;' using out :false_var;
  execute immediate 'begin :x := pit.get_default_language; end;' using out :default_lang_var;

select lower(data_type) ||    
         case when data_type in ('CHAR', 'VARCHAR2') then '(' || data_length || case char_used when 'B' then ' byte)' else ' char)' end
         when data_type in ('NUMBER') then '(' || data_precision || ', ' || data_scale || ')'
         else null
       end FLAG_TYPE,
       case when data_type in ('CHAR', 'VARCHAR2') then dbms_assert.enquote_literal(pit_util.c_true) else to_char(pit_util.c_true) end C_TRUE, 
       case when data_type in ('CHAR', 'VARCHAR2') then dbms_assert.enquote_literal(pit_util.c_false) else to_char(pit_util.c_false) end C_FALSE
  from all_tab_columns
 where table_name = 'PARAMETER_LOCAL'
   and column_name = 'PAL_BOOLEAN_VALUE';
  
exception
  when others then
    :with_pit_var := 'false';
    select q'^char(1 byte)^' flag_type, 'Y' C_TRUE, 'N' C_FALSE, 'AMERICAN' default_language
      into :flag_type_var, :true_var, :false_var, :default_lang_var
      from dual;
end;
/


select :flag_type_var FLAG_TYPE, :true_var C_TRUE, :false_var C_FALSE, :default_lang_var, :default_lang_var DEFAULT_LANGUAGE, :with_pit_var PIT_INSTALLED
  from dual;

col ver_le_20 new_val VER_LE_20 format a5
col ver_le_2001 new_val VER_LE_2001 format a5
col ver_le_2002 new_val VER_LE_2002 format a5
col ver_le_21 new_val VER_LE_21 format a5
col ver_le_2101 new_val VER_LE_2101 format a5
col ver_le_2102 new_val VER_LE_2102 format a5
col ver_le_22 new_val VER_LE_22 format a5
col ver_le_2201 new_val VER_LE_2201 format a5
col ver_le_2202 new_val VER_LE_2202 format a5
col ver_le_23 new_val VER_LE_23 format a5
col ver_le_2301 new_val VER_LE_2301 format a5
col apex_version new_val apex_version format a30
with apex_version as(
       select to_number(substr(version_no, 1, instr(version_no, '.', 1) - 1)) major_version, 
              to_number(substr(version_no, 1, instr(version_no, '.', 1, 2) - 1), '99.99') minor_version
         from apex_release r)
select case major_version 
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
         when 22 then 'true'
         else 'false' end ver_le_22,
       case minor_version
         when 22.1 then 'true'
         else 'false' end ver_le_2201,
       case minor_version
         when 22.2 then 'true'
         else 'false' end ver_le_2202,
       case major_version 
         when 23 then 'true'
         else 'false' end ver_le_23,
       case minor_version
         when 23.1 then 'true'
         else 'false' end ver_le_2301,
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
