UTL_APEX is a utility collection of methods aiming at Oracle APEX

It must be installed at the schema that has been granted access by the apex workspace, otherwise the utilities won't work.


To install
- Make sure that PIT and UTL_TEXT are installed, both are available on GitHub
- start a command line
- set NLS_LANG=GERMANY_GERMAN.AL32UTF8 (language does not matter, just the encoding is important)
- walk to the folder where this file resides
- Run pit_install_client
- Start a SQL*Plus session with the APEX wokrkspace user
- Start @utl_apex_install with no parameters. The language of the messages will be derived from the default language of PIT