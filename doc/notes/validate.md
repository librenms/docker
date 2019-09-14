### Validate

If you want to validate your installation from the CLI, type the following command :

```text
$ docker-compose exec --user librenms librenms php validate.php
====================================
Component | Version
--------- | -------
LibreNMS  | 1.41
DB Schema | 253
PHP       | 7.2.7
MySQL     | 10.2.16-MariaDB-10.2.16+maria~jessie
RRDTool   | 1.7.0
SNMP      | NET-SNMP 5.7.3
====================================

[OK]    Composer Version: 1.6.5
[OK]    Dependencies up-to-date.
[OK]    Database connection successful
[OK]    Database schema correct
[WARN]  You have not added any devices yet.
        [FIX] You can add a device in the webui or with ./addhost.php
[WARN]  Your install is over 24 hours out of date, last update: Sat, 30 Jun 2018 21:37:37 +0000
        [FIX] Make sure your daily.sh cron is running and run ./daily.sh by hand to see if there are any errors.
[WARN]  Your local git branch is not master, this will prevent automatic updates.
        [FIX] You can switch back to master with git checkout master
```
