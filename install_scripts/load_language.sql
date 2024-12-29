-- Parameters:
-- 1: Language to install

define language = &1.
@install_scripts/init.sql

prompt
prompt &section.
prompt &h1.Installing language &1.
@core/messages/&language./MessageGroup_UTL_APEX.sql


prompt &h1.Finished

exit
