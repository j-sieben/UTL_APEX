# UTL_APEX
APEX-Utilities

## What it is
When working with APEX there are repeating tasks to do, such as getting values from the session state, examine the request value, find out which action to perform within the database and others. Plus, the existing APEX-API changes quite often and has some historical flaws which are hard to correct. 

Some examples? You get the application id, -alias and page-id from global variables in package `apex_application`, called `G_FLOW_ID`, `G_FLOW_ALIAS`, `G_FLOW_STEP_ID`. The page alias on the other hand is available named `G_PAGE_ALIAS` ... And even if they were named consistently, there's this old FLOW/FLOW_STEP thing from the early HTML_DB days. Want to add some more? You're probably working in the field of internationalization and need the translated application ids. No problem, just reference `G_TRANSLATED_FLOW_ID` and `G_TRANSLATED_PAGE_ID` in that case. What does those variables contain, if you run your translated application in the default language? And, by the way: those values are available in PL/SQL only as they are variables, not functions. So in order to retrieve them from SQL, you need differently named constants and a function like `v('APP_ID')` and the like.

In regard to finding out whether an `INSERT`, `UPDATE` or `DELETE` has to be performed, over time there have been several strategies:

- Compare the request to a white list of request values
- Adding explicit database action with the meta data of a button
- Column `APEX$ROW_STATUS`

You don't really want every developer to have to have such knowledge present, and you don't want to have to look it up again in every APEX application. If you develop code that is aimed to survive some APEX generations, it's a good idea to centralize the dependencies to APEX in order to cater for the upcoming changes from version to version. This is what `UTL_APEX` is used for. Even from the perspective of clean code this does make sense: To the local code, APEX is a dependency on a third party software vendor which should be encapsulated to limit changes of the external API to the bare minimum.

## What it contains
One very useful thing that `UTL_APEX` contains are version constants as known from `DBMS_DB_VERSION`. They allow for conditional compilation based on the actually installed APEX version. They are set upon installing the package.

Another area defines subtypes to be used in your APEX packages. 

Then it contains trivial getter methods for commonly used APEX related informations. They are desinged as functions and are consistently named. So you have `get_application_id`, `get_application_alias`, `get_page_id` and so on.

On the next »level« there are methods that wrap APEX strategies which changed over time, like finding out what action to take within the database. As an example, there are methods called `inserting`, `updating` and `deleting` returning boolean flags if the respective action was requested. Under the hood, they analyze the request against a white list, try to read the button database action or look at `APEX$ROW_STATUS` to find out what to do.

The most complex methods grant access to the session state. The idea behind these methods is to dynamically copy all elements of the session state into a PL/SQL table, using the element names as keys and the (varchar2) value as payload. The beauty of these methods is that they are able to read the session state, whether you are using an old form, a new form region, or an editable grid on your page. If you use the latter two, you must assign a static ID to your regions and reference them, since it is permissible to use more than one of these region types on a page. This will free your package from APEX logic and make it easier to switch to a new version in case it invites an even newer method of passing on session-status information. By the way, I would like to have a view or a pre-filled PL/SQL table from the APEX team, but I'm afraid I'll have to wait a long time for that...

If you work with these methods, you will get access to the session state using the same API and without the danger of spell errors, as you will receive an error if you access a page item that does not exist. You may also want to look into package `UTL_DEV_APEX`. It supports you while you develop as it generates stub methods for your form pages to copy the session state, convert their values according to the format masks provided on the page and copy them to a record of the table / view you base your form on. This way, the basic PL/SQL block for working with form data within a package is generated.

This package is a work in progress, I add new functionality when I need it, so stay informed on new developments.

## Dependencies
Oracle APEX 5 is no longer supported. Test sessions use `APEX_SESSION` directly.

`UTL_APEX` is dependent on [`PIT`](https://github.com/j-sieben/PIT) as it reuses it's assertion and message providing mechanism. It is also dependent on [`UTL_TEXT`](https://github.com/j-sieben/UTL_TEXT) from which I use the `bulk_replace`methods and my code generator to generate the stubs.

## Installation and product version

The public `UTL_APEX.get_version()` and `UTL_APEX.get_git_commit()` functions return
installation-time constants and can also be called from SQL:

```sql
select utl_apex.get_version(), utl_apex.get_git_commit() from dual;
```

`VERSION` centrally contains `Major.Minor`, initially `1.0`. The third component is
`git rev-list --count <full-commit-hash>`: all commits reachable from the captured
commit, including merged branches. Changing Major/Minor does not reset this count.
The existing `APEX_VERSION` and `VER_LE_*` constants describe Oracle APEX, not this
product, and retain their existing meaning.

Commit your changes before installing or exporting. Launch from any working
directory (paths containing spaces are supported):

```sh
bash "/path/to/UTL_APEX/install.sh"
bash "/path/to/UTL_APEX/install_devtools.sh"
```

On Windows, run `install.bat` or `install_devtools.bat`. They use the existing
PowerShell prerequisite (Windows PowerShell 5.1 or PowerShell 7 for direct `.ps1`
invocation). Git is required for checkout installations; SQL*Plus is required by
the launchers. The SQL scripts also support SQLcl, as shown below. Database
prerequisites remain Oracle APEX, PIT and UTL_TEXT; DevTools require the core.
There is no separate build step or additional database package/table.

The launchers capture one full commit hash before version calculation. All
commit-dependent Git operations use this hash; replacement objects are disabled.
They reject tracked, staged and untracked changes (ordinary Git-ignored local
files are excluded), shallow histories, partial clones, grafts and missing Git
objects before opening a database connection. A valid checkout always takes
precedence over prepared release metadata; a broken checkout does not fall back
to that metadata. Do not change files while an installation is running.

The validated version and full commit hash are passed to the outer SQL script.
It defines `UTL_APEX_VERSION` and `UTL_APEX_GIT_COMMIT` before initialization/DDL.
Substitution is explicitly enabled before the package body is read, replacing
`'&UTL_APEX_VERSION.'` and `'&UTL_APEX_GIT_COMMIT.'` with fixed source literals.
The installer logs both values, verifies that specification and body are VALID,
and calls both functions from SQL to compare their results with the supplied
values. SQL/OS errors return a failure exit status. Oracle DDL commits implicitly;
an installation failure cannot roll back earlier DDL.

For SQLcl, first obtain the same validated values without connecting to a database.
On Unix, run these commands from the repository/distribution root:

```sh
ROOT=$(pwd -P)
source tools/version.sh
resolve_version || exit 1
sql -L 'schema/password@service' @install_scripts/install.sql "$UTL_APEX_VERSION" "$UTL_APEX_GIT_COMMIT"
# DevTools: use @install_scripts/install_devtools.sql instead.
```

On Windows, `powershell.exe -NoProfile -File tools\install.ps1 -Action Resolve`
prints the validated version and commit without connecting. Pass those values as
the two arguments to the same SQL scripts when invoking SQLcl. Low-level SQL
entry points assume host-validated arguments from a clean checkout or prepared
release; invoking them manually bypasses the launchers' Git provenance checks.

### Distributions without Git

There was no release/export pipeline in this repository. Create a distribution
from a complete, clean checkout with either command below. The destination must
be a new directory outside the checkout, and its parent must already exist.
Unix relative destinations are relative to the checkout root; the PowerShell
export uses the same convention. Absolute destinations are recommended.

```sh
bash tools/export.sh "/path/to/releases/UTL_APEX"
```

```powershell
powershell.exe -NoProfile -File tools\install.ps1 -Action Export -Destination "C:\Releases\UTL_APEX"
```

These export the captured commit with `git archive` and add
`install_scripts/version.properties` to the distribution only. The two data
lines contain `UTL_APEX_VERSION` and `UTL_APEX_GIT_COMMIT`; the metadata is parsed
as data and never executed. Installation of this distribution requires no Git.
It uses the same launchers and validates metadata format and agreement with
`VERSION`. The distribution directory may be zipped or copied for delivery.
No checked-in files are rewritten during installation or export.

A plain GitHub source archive or `git archive` without these prepared values
cannot be installed: it has neither history nor reliable version metadata.
Use the export commands instead. Prepared metadata identifies the export commit;
it is not a cryptographic integrity check of a subsequently modified archive.

### Reinstalling an individual body

Re-reading a body from its source file requires the version variables again.
For the new API, first perform a full installation so that the specification
already declares both functions. Obtain validated values using the resolver
above, start SQL*Plus or SQLcl from the distribution root and run:

```sql
-- Replace the placeholders with the validated resolver output, not guessed values.
@install_scripts/version_args.sql <Major.Minor.CommitCount> <full-commit-hash>
@install_scripts/init.sql
@tools/set_compiler_flags.sql
set define &
@core/packages/utl_apex.pkb
@tools/check_version.sql
```

Initialization also sets the existing APEX/PIT substitutions used elsewhere in
the body. Use the matching source distribution and its own version values.
`alter package utl_apex compile body;` recompiles the stored database source,
which already contains fixed literals, and needs no substitution variables.

### Offline checks

Run `python3 tests/test_versioning.py` and `git diff --check`. The tests create
isolated temporary repositories and substitute a fake SQL*Plus executable; they
never connect to a database. PowerShell checks run when `pwsh` is available.
Live compilation and SQL result checks are part of the actual installation.
