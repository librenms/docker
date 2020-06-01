### Validate

If you want to validate your installation from the CLI, type the following command:

```text
$ docker-compose exec --user librenms librenms php validate.php
====================================
Component | Version
--------- | -------
LibreNMS  | 1.64
DB Schema | 2020_04_19_010532_eventlog_sensor_reference_cleanup (165)
PHP       | 7.3.18
Python    | 3.8.2
MySQL     | 10.4.13-MariaDB-1:10.4.13+maria~bionic
RRDTool   | 1.7.2
SNMP      | NET-SNMP 5.8
====================================

[OK]    Installed from the official Docker image; no Composer required
[OK]    Database connection successful
[OK]    Database schema correct
[WARN]  IPv6 is disabled on your server, you will not be able to add IPv6 devices.
[WARN]  Updates are managed through the official Docker image
```
