## Environment variables

### General

* `TZ`: The timezone assigned to the container (default `UTC`)
* `PUID`: LibreNMS user id (default `1000`)
* `PGID`: LibreNMS group id (default `1000`)
* `MEMORY_LIMIT`: PHP memory limit (default `256M`)
* `UPLOAD_MAX_SIZE`: Upload max size (default `16M`)
* `OPCACHE_MEM_SIZE`: PHP OpCache memory consumption (default `128`)
* `LISTEN_IPV6`: Enable IPv6 for Nginx (default `true`)
* `REAL_IP_FROM`: Trusted addresses that are known to send correct replacement addresses (default `0.0.0.0/32`)
* `REAL_IP_HEADER`: Request header field whose value will be used to replace the client address (default `X-Forwarded-For`)
* `LOG_IP_VAR`: Use another variable to retrieve the remote IP address for access [log_format](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format) on Nginx. (default `remote_addr`)

### Dispatcher service

> :warning: Only used if you enable and run a [sidecar dispatcher container](../notes/dispatcher-service.md)

* `SIDECAR_DISPATCHER`: Set to `1` to enable sidecar dispatcher mode for this container (default `0`)
* `LIBRENMS_SERVICE_POLLER_WORKERS`: Processes spawned for polling (default `24`)
* `LIBRENMS_SERVICE_SERVICES_WORKERS`: Processes spawned for service polling (default `8`)
* `LIBRENMS_SERVICE_DISCOVERY_WORKERS`: Processes spawned for discovery (default `16`)
* `LIBRENMS_SERVICE_POLLER_FREQUENCY`: Seconds between polling attempts (default `300`)
* `LIBRENMS_SERVICE_SERVICES_FREQUENCY`: Seconds between service polling attempts (default `300`)
* `LIBRENMS_SERVICE_DISCOVERY_FREQUENCY`: Seconds between polling attempts (default `21600`)
* `LIBRENMS_SERVICE_BILLING_FREQUENCY`: Seconds between polling attempts (default `300`)
* `LIBRENMS_SERVICE_BILLING_CALCULATE_FREQUENCY`: Billing interval (default `60`)
* `LIBRENMS_SERVICE_POLLER_DOWN_RETRY`: Seconds between failed polling attempts (default `60`)
* `LIBRENMS_SERVICE_LOGLEVEL`: Must be one of 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL' (default `INFO`)
* `LIBRENMS_SERVICE_UPDATE_FREQUENCY`: Seconds between LibreNMS update checks (default `86400`)
* `LIBRENMS_SERVICE_PING_ENABLED`: Enable fast ping scheduler (default `false`)
* `LIBRENMS_SERVICE_WATCHDOG_ENABLED`: Enable watchdog scheduler (default `false`)
* `REDIS_HOST`: Redis host for poller synchronization (default `localhost`)
* `REDIS_PORT`: Redis port (default `6379`)
* `REDIS_PASSWORD`: Redis password
* `REDIS_DB`: Redis database (default `0`)

### Cron (legacy)

> :warning: Only used if you enable and run a [sidecar cron container](../notes/cron.md)

* `SIDECAR_CRON`: Set to `1` to enable sidecar cron mode for this container (default `0`)
* `LIBRENMS_CRON_DISCOVERY_ENABLE`: Enable LibreNMS discovery for this container cronjobs (default `true`)
* `LIBRENMS_CRON_DISCOVERY_WRAPPER_WORKERS`: Spawn multiple discovery.php processes in parallel (default `1`)
* `LIBRENMS_CRON_DAILY_ENABLE`: Enable LibreNMS daily script for this container cronjobs (default `true`)
* `LIBRENMS_CRON_ALERTS_ENABLE`: Enable LibreNMS alerts generation for this container cronjobs (default `true`)
* `LIBRENMS_CRON_BILLING_ENABLE`: Enable LibreNMS billing polling for this container cronjobs (default `true`)
* `LIBRENMS_CRON_BILLING_CALCULATE_ENABLE`: Enable LibreNMS billing for this container cronjobs (default `true`)
* `LIBRENMS_CRON_CHECK_SERVICES_ENABLE`: Enable LibreNMS service checks for this container cronjobs (default `true`)
* `LIBRENMS_CRON_POLLER_ENABLE`: Enable LibreNMS polling for this container cronjobs (default `true`)
* `LIBRENMS_CRON_SNMPSCAN_ENABLE`: Enable LibreNMS SNMP network scanning for this container cronjobs (default `false`)
* `LIBRENMS_CRON_SNMPSCAN_INTERVAL`: SNMP network scanning cron interval (daily, in "Minute Hour", default `5 0`)
* `LIBRENMS_CRON_SNMPSCAN_NETS`: Networks to scan for SNMP network scanning, in CIDR notation.  Multiple networks can be specified separated by a comma.  If this is not set the default is to scan networks defined in `$config['nets']`
* `LIBRENMS_CRON_SNMPSCAN_THREADS`: SNMP network scanning threads to use (default `32`)
* `LIBRENMS_CRON_SNMPSCAN_LOGFILE`: SNMP network scanning cron log file (default `/dev/null`)

### Distributed Poller

* `LIBRENMS_POLLER_THREADS`: Threads that `poller-wrapper.py` runs (default `16`)
* `LIBRENMS_POLLER_INTERVAL`: Interval in minutes at which `poller-wrapper.py` runs (default `5`) [docs](https://docs.librenms.org/Support/1-Minute-Polling/)
* `LIBRENMS_DISTRIBUTED_POLLER_ENABLE`: Enable distributed poller functionality
* `LIBRENMS_DISTRIBUTED_POLLER_NAME`: Optional name of poller (default `$(hostname)`)
* `LIBRENMS_DISTRIBUTED_POLLER_GROUP`: By default, all hosts are shared and have the poller_group = 0. To pin a device to a poller, set it to a value greater than 0 and set the same value here. One can also specify a comma separated string of poller groups. The poller will then poll devices from any of the groups listed. [docs](https://docs.librenms.org/Extensions/Distributed-Poller/)
* `LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST`: Memcached server for poller synchronization (default `$MEMCACHED_HOST`)
* `LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_PORT`: Port of memcached server (default `$MEMCACHED_PORT`)

### Syslog-ng

> :warning: Only used if you enable and run a [sidecar syslog-ng container](../notes/syslog-ng.md)

* `SIDECAR_SYSLOGNG`: Set to `1` to enable sidecar syslog-ng mode for this container (default `0`)

### Database

* `DB_HOST`: MySQL database hostname / IP address
* `DB_PORT`: MySQL database port (default `3306`)
* `DB_NAME`: MySQL database name (default `librenms`)
* `DB_USER`: MySQL user (default `librenms`)
* `DB_PASSWORD`: MySQL password (default `librenms`)
* `DB_TIMEOUT`: Time in seconds after which we stop trying to reach the MySQL server (useful for clusters, default `60`)

### Misc

* `LIBRENMS_SNMP_COMMUNITY`: This container's SNMP v2c community string (default `librenmsdocker`)
* `MEMCACHED_HOST`: Hostname / IP address of a Memcached server
* `MEMCACHED_PORT`: Port of the Memcached server (default `11211`)
* `RRDCACHED_HOST`: Hostname / IP address of a RRDcached server
* `RRDCACHED_PORT`: Port of the RRDcached server (default `42217`)
