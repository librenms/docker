# Changelog

## 1.58-RC1 (2019/11/25)

* LibreNMS 1.58
* Remove useless `.git` folder
* Add `LIBRENMS_DOCKER` env (librenms/librenms#10879)

## 1.57-RC2 (2019/11/19)

* :warning: Run as non-root user (#6)
* Switch to [s6-overlay](https://github.com/just-containers/s6-overlay/) as process supervisor
* Prevent exposing Nginx and PHP version
* :warning: Bind to unprivileged port (8000)
* Remove php-fpm access log (already mirrored by nginx)

> :warning: **UPGRADE NOTES**
> As the Docker container now runs as a non-root user, you have to first stop the container and change permissions to `data` volume:
> ```
> docker-compose stop
> chown -R ${PUID}:${PGID} data/
> docker-compose pull
> docker-compose up -d
> ```

## 1.57-RC1 (2019/10/30)

* LibreNMS 1.57

## 1.56-RC3 (2019/10/26)

* Base image update

## 1.56-RC2 (2019/10/25)

* Fix CVE-2019-11043

## 1.56-RC1 (2019/09/30)

* LibreNMS 1.56

## 1.55-RC2 (2019/09/14)

* Review data permissions
* Remove usermod/groupmod (Issue #38)

## 1.55-RC1 (2019/09/04)

* LibreNMS 1.55

## 1.54-RC2 (2019/08/28)

* Add python3 modules required for new [Dispatcher Service](https://docs.librenms.org/Extensions/Dispatcher-Service/) (PR #36)

## 1.54-RC1 (2019/07/29)

* LibreNMS 1.54

## 1.53.1-RC2 (2019/07/25)

* Add ipmitool location (Issue #34)

## 1.53.1-RC1 (2019/07/02)

* LibreNMS 1.53.1

## 1.53-RC1 (2019/07/01)

* LibreNMS 1.53
* Alpine Linux 3.10 

## 1.52-RC1 (2019/05/28)

* LibreNMS 1.52

## 1.51-RC2 (2019/05/01)

* Sidecar cron and syslog-ng are now respectively enabled through `SIDECAR_CRON` and `SIDECAR_SYSLOGNG` env vars
* Fix snmpd command

> :warning: **UPGRADE NOTES**
> Sidecar cron and syslog-ng are now respectively handled with `SIDECAR_CRON` and `SIDECAR_SYSLOGNG` env vars
> See docker-compose example and README for more info.

## 1.51-RC1 (2019/05/01)

* LibreNMS 1.51

## 1.50.1-RC3 (2019/04/28)

* Add `large_client_header_buffers` Nginx config

## 1.50.1-RC2 (2019/04/21)

* Add ipmitool (PR #29)

## 1.50.1-RC1 (2019/04/17)

* LibreNMS 1.50.1

## 1.50-RC5 (2019/04/15)

* Bind IPv6 (Issue #28)

## 1.50-RC4 (2019/04/13)

* Add `LOG_IP_VAR` environment variable (Issue #22)

## 1.50-RC3 (2019/04/07)

* Use python3 for snmp-scan (Issue #25)
* Add `REAL_IP_FROM` and `REAL_IP_HEADER` environment variables (Issue #22)

## 1.50-RC2 (2019/04/03)

* MEMORY_LIMIT not used by poller (PR #24)

## 1.50-RC1 (2019/04/01)

* LibreNMS 1.50

## 1.49-RC1 (2019/03/06)

* LibreNMS 1.49

## 1.48.1-RC1 (2019/01/31)

* LibreNMS 1.48.1
* Alpine Linux 3.9

## 1.48-RC1 (2019/01/28)

* LibreNMS 1.48

## 1.47-RC1 (2018/12/30)

* LibreNMS 1.47

## 1.46-RC3 (2018/12/29)

* Missing Python 2 memcached module for poller (Issue #9)

## 1.46-RC2 (2018/12/14)

* Add Python 3 (Issue #7)

## 1.46-RC1 (2018/12/02)

* LibreNMS 1.46

## 1.45-RC3 (2018/11/25)

* Fix dbcmd in entrypoint
* Optimize layers

## 1.45-RC2 (2018/11/21)

* Add `php7-ldap` package

## 1.45-RC1 (2018/10/28)

* LibreNMS 1.45

## 1.44-RC1 (2018/10/17)

* LibreNMS 1.44
* Add `busybox-extras` and `bind-tools` packages

## 1.43-RC5 (2018/09/29)

* Ability to add custom Monitoring plugins through `/data/monitoring-plugins`
* Install [Monitoring Plugins](https://www.monitoring-plugins.org/) package
* Services enabled by default

## 1.43-RC4 (2018/09/26)

* Add `ttf-dejavu` package

## 1.43-RC3 (2018/09/24)

* Set default port for `MEMCACHED_PORT` and `RRDCACHED_PORT`

## 1.43-RC2 (2018/09/24)

* Add CAP_NET_RAW on nmap and fping
* Fixes for `validate.php` nologin errors and missing setfacl binaries
* Add fping6 support
* Add `rrdtool_version`
* Ability to configure distributed polling
* Adding python-memcached module required for distributed poller setup
* Configurable DB_TIMEOUT
* Allow setting sensible variables through files
* Ability to override Memcached and RRD ports

## 1.43-RC1 (2018/09/10)

* LibreNMS 1.43

## 1.42.01-RC1 (2018/08/05)

* LibreNMS 1.42.01

## 1.42-RC1 (2018/08/02)

* LibreNMS 1.42
* Add syslog-ng support

## 1.41-RC1 (2018/07/07)

* Initial version based on LibreNMS 1.41
