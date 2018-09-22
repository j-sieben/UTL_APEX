UTL_APEX is a utility collection of methods aiming at Oracle APEX

It must be installed at an owner that has been granted access by the apex workspace, otherwise the utilities won't work.

To install
- Make sure that PIT and UTL_TEXT are installed, both are available on GitHub
- start a command line
- set NLS_LANG=GERMANY_GERMAN.AL32UTF8 (language does not matter, its the encoding which is important)
- Run pit_install_client <owner> <target_schema> to grant access to the owner of UTL_APEX
- Run utl_text_install_client  <owner> <target_schema> to grant access to the owner of UTL_APEX
- walk to the folder where this file resides
- Start a SQL*Plus session with a dba user
- Start @utl_apex_install with two parameters:
  - name of owner of the package
  - Oracle language name of the messages (GERMAN|AMERICAN at the moment)
  