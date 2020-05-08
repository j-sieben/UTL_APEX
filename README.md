# UTL_APEX
APEX-Utilities

## What it is
When working with APEX there are repeating tasks to do, such as getting values from the session state, examine the request value, find out which action to perform within the database and others. Plus, the existing APEX-API changes quite often and has some historical flaws which are hard to correct. 

Some examples? You get the application id, -alias and page-id from global variables in package `apex_application`, called `G_FLOW_ID`, `G_FLOW_ALIAS`, `G_FLOW_STEP_ID`. The page alias on the other hand is available named `G_PAGE_ALIAS` ... And even if they were named consistently, there's this old FLOW/FLOW_STEP thing from the early HTML_DB days. And, by the way: those values are available in PL/SQL only as they are variables, not functions. So in order to get them from SQL, you need differently named constants like `v('APP_ID')` and the like.

In regard to finding out whether an `INSERT`, `UPDATE` or `DELETE` has to be performed, over time there have been several strategies:

- Compare the request to a white list of request values
- Adding explicit database action with the meta data of a button
- Column `APEX$ROW_STATUS`

If you develop code that is aimed to survive some APEX generations, it's a good idea to centralize the dependencies to APEX in order to cater for the upcoming changes from version to version. This is what `UTL_APEX` is used for.

## What it contains
One very useful thing that `UTL_APEX` contains are version constants as known from `DBMS_DB_VERSION`. They allow for conditional compilation based on the actually installed APEX version. They are set upon installing the package.

Another area defines subtypes to be used in your APEX packages. 

Then it contains trivial getter methods for commonly used APEX related informations. They are desinged as functions and are consistently named. So you have `get_application_id`, `get_application_alias`, `get_page_id` and so on.

On the next »level« there are methods that wrap APEX strategies which changed over time, like finding out what action to take within the database. As an example, there are methods called `inserting`, `updating` and `deleting` returning boolean flags if the respective action was requested. Under the hood, they analyze the request against a white list, try to read the button database action or look at `APEX$ROW_STATUS` to find out what to do.

The most complex methods grant access to the session state. The idea behind these methods is to dynamically copy all elements of the session state into a PL/SQL table, using the element names as keys and the (varchar2) value as payload. The beauty of these methods is that they are able to read the session state, whether you are using an old form, a new form region, or an editable grid on your page. If you use the latter two, you must assign a static ID to your regions and reference them, since it is permissible to use more than one of these region types on a page. This will free your package from APEX logic and make it easier to switch to a new version in case it invites an even newer method of passing on session-status information. By the way, I would like to have a view or a pre-filled PL/SQL table from the APEX team, but I'm afraid I'll have to wait a long time for that...

If you work with these methods, you will get access to the session state using the same API and without the danger of spell errors, as you will receive an error if you access a page item that does not exist. You may also want to look into package `UTL_DEV_APEX`. It supports you while you develop as it generates stub methods for your form pages to copy the session state, convert their values according to the format masks provided on the page and copy them to a record of the table / view you base your form on. This way, the basic PL/SQL block for working with form data within a package is generated.

This package is a work in progress, I add new functionality when I need it, so stay informed on new developments.

## Dependencies
`UTL_APEX` is dependent on [`PIT`](https://github.com/j-sieben/PIT) as it reuses it's assertion and message providing mechanism. It is also dependent on [`UTL_TEXT`](https://github.com/j-sieben/UTL_TEXT) from which I use the `bulk_replace`methods and my code generator to generate the stubs.

I know that it's boring if a GIT project is not self sufficient but relies on other repositories, but it is even worse to copy the respective code around. If you feel that you don't want to install the other libraries, you may still find this package useful as a seed for your own implementation.
