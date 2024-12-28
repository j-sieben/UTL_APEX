-- Parameters:
-- 1: Language to install

@install_scripts/init.sql

prompt
prompt &section.
prompt &h1.Installing language &1.
@core/messages/&1./MessageGroup_UTL_APEX.sql


prompt &h1.Finished

exit
