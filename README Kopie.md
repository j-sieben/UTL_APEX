# UTL_APEX
APEX-Utilities

## Utilities for APEX
Main reason for publishing these utilities is that I use them in the other repositories and I wanted to provide these helpers on a centralized repository. This makes it easier to track the respective version.

## Functionality
UTL_APEX is fast changing and offers methods I found useful in my projects. Most helper deal with the problem of accessing the session state from within PL/SQL easy and errorfree. A part from that, some method deal with downloading CLOB and BLOB as files to the client, to create an APEX session outside a browser and some others more.

## Installation
UTL_APEX must be installed in a schema that is accessible by the APEX workspace. Don't try to install it in a utility user and grant execute to a client, this will not work as und this circumstance UTL_APEX will not be able to get the session state. Therefore, no client install script is provided.