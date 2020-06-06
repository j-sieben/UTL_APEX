UTL_APEX is a utility collection of methods aiming at Oracle APEX

It must be installed at an owner that has been granted access by the apex workspace, otherwise the utilities won't work.

Prior to installation decide upon the specification of FLAG_TYPE, the datatype used for boolean values.
As per default, CHAR(1 BYTE) is used with Y|N as the values for true and false. If you want to change that, adjust the settings in INIT.SQL

To install
- Make sure that PIT and UTL_TEXT are installed, both are available on GitHub
- start a command line
- set NLS_LANG=GERMANY_GERMAN.AL32UTF8 (language does not matter, just the encoding is important)
- Run pit_install_client <owner> <target_schema> to grant access to the owner of UTL_APEX
- Run utl_text_install_client  <owner> <target_schema> to grant access to the owner of UTL_APEX
- walk to the folder where this file resides
- Start a SQL*Plus session with a dba user
- Start @utl_apex_install with two parameters:
  - name of owner of the package
  - Oracle language name of the messages (GERMAN|AMERICAN at the moment)
  