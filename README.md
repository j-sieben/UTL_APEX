# UTL_APEX
APEX-Utilities

## Wht it is
When working with APEX there are repeating tasks to do, such as getting values from the session state, examine the request value, find out which action to perform within the database and others. Plus, the existing APEX-API changes quite often and has some historical flaws which are hard to correct. 

Some examples? You get the application id, -alias and page-id from global variables in package apex_application, called G_FLOW_ID, G_FLOW_ALIAS, G_FLOW_STEP_ID. The page alias on the other hand is available named G_PAGE_ALIAS ... And even if they were named consistently, there's this old FLOW/FLOW_STEP thing from the early HTML_DB days. And, by the way: those values are available in PL/SQL only as they are variables, not functions. So in order to get them from SQL, you need differently named constants like v('APP_ID' and the like.

In regard to finding out whether an INSERT, UPDATE or DELETE has to be performed, over time there have been several strategies:

- Compare the request to a white list of request values
- Adding explicit database action with the meta data of a button
- Column APEX$ROW_STATUS

If you develop code that is aimed to survive some APEX generations, it's a good idea to centralize the dependencies to APEX in order to cater for the upcoming changes from version to version. This is what UTL_APEX is used for.

## What it contains
One very useful thing is that UTL_APEX contains verion constants as known from DBMS_DB_VERSION. They allow for conditional compilation based on the actually installed APEX version.

Then it contains trivial getter methods for commonly used APEX related informations. They are desinged as functions and they are consistently named. So you have get_application_id, get_applciation_alias, get_page_id and so on.

On the next »level« there are methods that wrap APEX strategies which changed over time, like finding out what action to take within the database. As an example, there are methods called `inserting´, `updating` and `deleting` returning boolean flags if the respective action was requested. Under the hood, they analyze the request against a white list, try to read the button database action or look at `APEX$ROW_STATUS` to find out what to do.

The most complex methods grant access to the session state. The idea behind those methods is to dynamically copy all session state items into a PL/SQL table, using their item names as the key and their (`varchar2`) value as the payload. The beauty of those methods is that they are able to read the session state, regardless whether you have an old form, a new form region or an editable grid on your page. If you use the latter two, you have to assign a static ID to your regions and reference them as it is allowed to have more than one of those region type on a page.

If you work with those methods, you will get access to the session state without the danger of spell errors, as you will receive an error if you access a page item that does not exist. You may also want to look into the UTL_DEV_APEX that allows you to generate stub methods for your packages which copy the session state, convert their values according to the format masks provided on the page and copy them to a record of the table / view you base your form on. This way, the basic PL/SQL block for working with form data within a package is generated.

This package is a work in progress, I add new functionality when I need it, so stay informed on new developments.
