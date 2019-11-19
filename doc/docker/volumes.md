## Volumes

* `/data`: Contains configuration, rrd database, logs, additional Monitoring plugins, additional syslog-ng config files

> :warning: Note that the volume should be owned by the user/group with the specified `PUID` and `PGID`. If you don't give the volume correct permissions, the container may not start.
