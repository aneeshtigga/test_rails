# Contents

## Purpose

This db/data directory contains files used to update, on demand, a single database table (typically static tables but not necessarily) in the primary polaris database.  The difference between the purpose of db/data and db/seeds is that db/data contains files which update on demand a single database table.  The db/seeds directory on the other hand is used via the rake db:seed task to replace many different database tables at once with a common known set of content.

## File Name Convention

The filenames in db/data follow the pattern convention of:

* tablename_YYYYMMDDhhmmss.ext

tablename is the name of the primary database table to be updated.

YYMMDDhhmmss is a timestamp to uniquely identify the file.  This timestamp may or may not relate to a schema migration.  We do not use data migrations; however, having a timestamp between the data file and a migration that changes the schema which was the reason to have a data update is a handy way to document the intent.

ext is the file extension.  It can be either csv or json depending upon the rake task needs.

## Files

This second documents each file present in the db/data directory.

### license_keys_20230327091257.csv

The migration 20230327091257_add_cbo_to_license_keys.rb added the "cbo" column to the license_keys table in accordance with JIRA ticket WEB-821.  The contents of the file come from the data provided in the JIRA ticket.

This file is used by the rake task:

rake dev:data:license_keys:csv:update[filepath]

where filepath is the path to the file.

To update the license_keys table using this file and rake task do the following manual process from the Rails.root directory using a command-line interface:

rake dev:data:license_keys:csv:update[db/data/license_keys_20230327091257.csv]


<!-- Insert the filename and comment for the next file above this line. -->
