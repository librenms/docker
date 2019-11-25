### Validate

If you want to validate your installation from the CLI, type the following command :

```text
$ docker-compose exec --user librenms librenms php validate.php
====================================
Component | Version
--------- | -------
LibreNMS  | 1.58
DB Schema | 2019_10_03_211702_serialize_config (147)
PHP       | 7.3.11
MySQL     | 10.4.8-MariaDB-1:10.4.8+maria~bionic
RRDTool   | 1.7.2
SNMP      | NET-SNMP 5.8
====================================

[OK]    Installed from package; no Composer required
[OK]    Database connection successful
[OK]    Database schema correct
[WARN]  You have not added any devices yet.
        [FIX] You can add a device in the webui or with ./addhost.php
[WARN]  IPv6 is disabled on your server, you will not be able to add IPv6 devices.
[WARN]  Non-git install, updates are manual or from package
```
