## Environment variables

### General

* `TZ`: The timezone assigned to the container (default `UTC`)
* `PUID`: LibreNMS user id (default `1000`)
* `PGID`: LibreNMS group id (default `1000`)
* `MEMORY_LIMIT`: PHP memory limit (default `256M`)
* `MAX_INPUT_VARS`: PHP max input vars (default `1000`)
* `UPLOAD_MAX_SIZE`: Upload max size (default `16M`)
* `CLEAR_ENV`: Clear environment in FPM workers (default `yes`)
* `OPCACHE_MEM_SIZE`: PHP OpCache memory consumption (default `128`)
* `LISTEN_IPV6`: Enable IPv6 for Nginx (default `true`)
* `REAL_IP_FROM`: Trusted addresses that are known to send correct replacement addresses (default `0.0.0.0/32`)
* `REAL_IP_HEADER`: Request header field whose value will be used to replace the client address (default `X-Forwarded-For`)
* `LOG_IP_VAR`: Use another variable to retrieve the remote IP address for access [log_format](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format) on Nginx. (default `remote_addr`)

### Dispatcher service

> :warning: Only used if you enable and run a [sidecar dispatcher container](../notes/dispatcher-service.md)

* `SIDECAR_DISPATCHER`: Set to `1` to enable sidecar dispatcher mode for this container (default `0`)
* `DISPATCHER_NODE_ID`: Unique node ID for your dispatcher service
* `DISPATCHER_ARGS`: Additional args to pass to the [dispatcher service](https://github.com/librenms/librenms/blob/master/librenms-service.py)
* `REDIS_HOST`: Redis host for poller synchronization
* `REDIS_SENTINEL`: Redis Sentinel host for high availability Redis cluster
* `REDIS_SENTINEL_SERVICE`: Redis Sentinel service name (default `librenms`)
* `REDIS_SCHEME`: Redis scheme (default `tcp`)
* `REDIS_PORT`: Redis port (default `6379`)
* `REDIS_PASSWORD`: Redis password
* `REDIS_DB`: Redis database (default `0`)

### Syslog-ng

> :warning: Only used if you enable and run a [sidecar syslog-ng container](../notes/syslog-ng.md)

* `SIDECAR_SYSLOGNG`: Set to `1` to enable sidecar syslog-ng mode for this container (default `0`)

### Snmptrapd

> :warning: Only used if you enable and run a [sidecar snmptrapd container](../notes/snmptrapd.md)

* `SIDECAR_SNMPTRAPD`: Set to `1` to enable sidecar snmptrapd mode for this container (default `0`)
* `SNMP_PROCESSING_TYPE`: Sets which type of processing (`log`, `execute`, and/or `net`) to use with the SNMP trap (default `log,execute,net`)
* `SNMP_USER`: Defines what username to authenticate with (default `librenms_user`)
* `SNMP_AUTH`: Defines what password to authenticate with (default `auth_pass` should not be used, but will work)
* `SNMP_PRIV`: Defines what password to encrypt packages with (default `priv_pass` should not be used, but will work)
* `SNMP_AUTH_PROTO`: Sets what protocol (`MD5`|`SHA`) to use for authentication (default `SHA`)
* `SNMP_PRIV_PROTO`: Sets what protocol (`DES`|`AES`) to use for encryption of packages (default `AES`)
* `SNMP_SECURITY_LEVEL`: Sets what security level (`noauth`|`priv`) to use (default `priv`)
* `SNMP_ENGINEID`: Defines what SNMP EngineID to use (default `1234567890`)
* `SNMP_DISABLE_AUTHORIZATION`: Will disable the above access control checks, and revert to the previous behaviour of accepting all incoming notifications. (default `yes`)

### Database

* `DB_HOST`: MySQL database hostname / IP address
* `DB_PORT`: MySQL database port (default `3306`)
* `DB_NAME`: MySQL database name (default `librenms`)
* `DB_USER`: MySQL user (default `librenms`)
* `DB_PASSWORD`: MySQL password (default `librenms`)
* `DB_TIMEOUT`: Time in seconds after which we stop trying to reach the MySQL server (useful for clusters, default `60`)

### Misc

* `LIBRENMS_BASE_URL`: URL of your LibreNMS instance (default `/`)
* `LIBRENMS_SNMP_COMMUNITY`: This container's SNMP v2c community string (default `librenmsdocker`)
* `LIBRENMS_WEATHERMAP`: Enable LibreNMS [Weathermap plugin](https://docs.librenms.org/Extensions/Weathermap/) (default `false`)
* `LIBRENMS_WEATHERMAP_SCHEDULE`: CRON expression format (default `*/5 * * * *`)
* `MEMCACHED_HOST`: Hostname / IP address of a Memcached server
* `MEMCACHED_PORT`: Port of the Memcached server (default `11211`)
* `RRDCACHED_SERVER`: RRDcached server (eg. `rrdcached:42217`)
