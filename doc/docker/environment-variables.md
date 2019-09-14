## Environment variables

### General

* `TZ` : The timezone assigned to the container (default `UTC`)
* `PUID` : LibreNMS user id (default `1000`)
* `PGID`: LibreNMS group id (default `1000`)
* `MEMORY_LIMIT` : PHP memory limit (default `256M`)
* `UPLOAD_MAX_SIZE` : Upload max size (default `16M`)
* `OPCACHE_MEM_SIZE` : PHP OpCache memory consumption (default `128`)
* `REAL_IP_FROM` : Trusted addresses that are known to send correct replacement addresses (default `0.0.0.0/32`)
* `REAL_IP_HEADER` : Request header field whose value will be used to replace the client address (default `X-Forwarded-For`)
* `LOG_IP_VAR` : Use another variable to retrieve the remote IP address for access [log_format](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format) on Nginx. (default `remote_addr`)

### (Distributed) Poller

* `LIBRENMS_POLLER_THREADS` : Threads that `poller-wrapper.py` runs (default `16`)
* `LIBRENMS_POLLER_INTERVAL` : Interval in minutes at which `poller-wrapper.py` runs (defaults to `5`) [docs](https://docs.librenms.org/#Support/1-Minute-Polling/)
* `LIBRENMS_DISTRIBUTED_POLLER_ENABLE` : Enable distributed poller functionality
* `LIBRENMS_DISTRIBUTED_POLLER_NAME` : Optional name of poller (defaults to hostname)
* `LIBRENMS_DISTRIBUTED_POLLER_GROUP` : By default, all hosts are shared and have the poller_group = 0. To pin a device to a poller, set it to a value greater than 0 and set the same value here. One can also specify a comma separated string of poller groups. The poller will then poll devices from any of the groups listed. [docs](https://docs.librenms.org/#Extensions/Distributed-Poller/#distributed-poller)
* `LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST` : Memcached server for poller synchronization (Defaults to `$MEMCACHED_HOST`)
* `LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_PORT` : Port of memcached server (Defaults to `$MEMCACHED_PORT`)

### Cron

> :warning: Only used if you enabled and run a [sidecar cron container](../notes/crons.md)

* `SIDECAR_CRON` : Set to `1` to enable sidecar cron mode for this container (default `0`)
* `LIBRENMS_CRON_DISCOVERY_ENABLE` : Enable LibreNMS discovery for this container cronjobs (default `true`)
* `LIBRENMS_CRON_DAILY_ENABLE` : Enable LibreNMS daily script for this container cronjobs (default `true`)
* `LIBRENMS_CRON_ALERTS_ENABLE` : Enable LibreNMS alerts generation for this container cronjobs (default `true`)
* `LIBRENMS_CRON_BILLING_ENABLE` : Enable LibreNMS billing polling for this container cronjobs (default `true`)
* `LIBRENMS_CRON_BILLING_CALCULATE_ENABLE` : Enable LibreNMS billing for this container cronjobs (default `true`)
* `LIBRENMS_CRON_CHECK_SERVICES_ENABLE` : Enable LibreNMS service checks for this container cronjobs (default `true`)
* `LIBRENMS_CRON_POLLER_ENABLE` : Enable LibreNMS polling for this container cronjobs (default `true`)

### Syslog-ng

> :warning: Only used if you enabled and run a [sidecar syslog-ng container](../notes/syslog-ng.md)

* `SIDECAR_SYSLOGNG` : Set to `1` to enable sidecar syslog-ng mode for this container (default `0`)

### Database

* `DB_HOST` : MySQL database hostname / IP address
* `DB_PORT` : MySQL database port (default `3306`)
* `DB_NAME` : MySQL database name (default `librenms`)
* `DB_USER` : MySQL user (default `librenms`)
* `DB_PASSWORD` : MySQL password (default `librenms`)
* `DB_TIMEOUT` : Time in seconds after which we stop trying to reach the MySQL server (useful for clusters, default `30`)

### Misc

* `LIBRENMS_SNMP_COMMUNITY` : This container's SNMP v2c community string (default `librenmsdocker`)
* `MEMCACHED_HOST` : Hostname / IP address of a Memcached server
* `MEMCACHED_PORT` : Port of the Memcached server (default `11211`)
* `RRDCACHED_HOST` : Hostname / IP address of a RRDcached server
* `RRDCACHED_PORT` : Port of the RRDcached server (default `42217`)
