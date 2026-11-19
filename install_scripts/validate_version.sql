-- Run before any database changes, including installation initialization.
set define &
set concat .
set verify off
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
begin
  if '&UTL_APEX_VERSION.' is null
     or '&UTL_APEX_GIT_COMMIT.' is null
     or not regexp_like('&UTL_APEX_VERSION.',
                     '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$', 'c')
     or length('&UTL_APEX_VERSION.') > 100
     or not regexp_like('&UTL_APEX_GIT_COMMIT.', '^([0-9a-f]{40}|[0-9a-f]{64})$', 'c') then
    raise_application_error(-20000, 'Invalid UTL_APEX product version or full Git commit hash. Use an installation launcher.');
  end if;
end;
/
prompt UTL_APEX product version: &UTL_APEX_VERSION.
prompt UTL_APEX Git commit: &UTL_APEX_GIT_COMMIT.
