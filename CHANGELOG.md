# Changelog

## 21.2.0-r1 (2021/03/04)

* Switch to `yasu`

## 21.2.0-r0 (2021/02/16)

* LibreNMS 21.2.0 (#167)
* `s6-overlay` 2.2.0.3 (#162)
* Alpine Linux 3.13 (#162)

## 21.1.0-r2 (2021/02/16)

* Need to specify `rrdtool_version` (librenms/docker@ab027d7)

## 21.1.0-r1 (2021/02/13)

* Downgrade to `s6-overlay` 2.1.0.2 (#164)
* No need to specify `rrdtool_version` (#166)

## 21.1.0-r0 (2021/02/02)

* LibreNMS 21.1.0
* Switch to buildx bake
* Do not fail on permission issue
* Redis - Add scheme to allow TLS (#159)
* Add iputils and fix perms (#131)

## 1.70.1-RC2 (2020/12/10)

* Fix Redis for dispatcher

## 1.70.1-RC1 (2020/12/02)

* LibreNMS 1.70.1
* Add NET_ADMIN capability and fix fping6 (#140)

## 1.69-RC3 (2020/11/22)

* Fix tzdata issue with Alpine (#143)
* Add alert templates (#142)
* Add redis sentinel support (#141)

## 1.69-RC2 (2020/11/04)

* Do not set default value for `RRDCACHED_SERVER`

## 1.69-RC1 (2020/11/03)

* LibreNMS 1.69
* Update to Traefik v2
* Update PWD example (#135)
* Allow to clear env for FPM workers
* Use Docker meta action to handle tags and labels
* Replace `RRDCACHED_HOST` and `RRDCACHED_PORT` with `RRDCACHED_SERVER` env var

## 1.68-RC1 (2020/09/30)

* LibreNMS 1.68

## 1.67-RC2 (2020/09/04)

* Seed through artisan (#122)

## 1.67-RC1 (2020/09/03)

* LibreNMS 1.67
* Now based on [Alpine Linux 3.12 with s6 overlay](https://github.com/crazy-max/docker-alpine-s6/)
* Missing migration seed flag (#122)

## 1.66-RC2 (2020/08/28)

* Fix DB connection for dispatcher service (#108 #118 #119)
* Run maintenance task through a dedicated process (#105)
* Add `DISPATCHER_ARGS` env var

## 1.66-RC1 (2020/07/30)

* LibreNMS 1.66

## 1.65.1-RC2 (2020/07/10)

* Add `LIBRENMS_BASE_URL` env var (#95 #99 #100)

## 1.65.1-RC1 (2020/07/10)

* LibreNMS 1.65.1

## 1.65-RC1 (2020/07/03)

* LibreNMS 1.65
* Remove `LIBRENMS_DISTRIBUTED_POLLER_*` env vars (now handle through WebUI)
* Check database migration completed
* Remove `LIBRENMS_SERVICE_*` env vars (now handle through WebUI)
* Check `poller_cluster` table exists before running dispatcher
* Handle Redis for dispatcher through `.env`
* Remove deprecated sidecar cron container
* Handle APP_KEY and NODE_ID (#91 #93)
* Add artisan command
* Clear cache and reload config cache
* Set user group config
* Alpine Linux 3.12

> :warning: **UPGRADE NOTES**
> Fill in the "Specific URL" (`base_url`) at `https://librenms.example.com/settings/system/server`

## 1.64.1-RC1 (2020/06/01)

* LibreNMS 1.64.1

## 1.64-RC1 (2020/06/01)

* LibreNMS 1.64
* Python 2 removed (librenms/librenms#11531)
* Multi-platform image
* Publish edge image

## 1.63-RC7 (2020/05/28)

* Use recommended `lnms` command
* Remove `--sql-mode` and bump Mariadb to 10.4

## 1.63-RC6 (2020/05/24)

* Bring back Git package

## 1.63-RC5 (2020/05/22)

* Add missing dep and perms for Weathermap plugin (#82)

## 1.63-RC4 (2020/05/21)

* Add LibreNMS Weathermap plugin (#81)
* Fix syslogng version
* Switch to [msmtpd SMTP relay](https://github.com/crazy-max/docker-msmtpd) Docker image

## 1.63-RC3 (2020/05/13)

* Run librenms-service as librenms user (#76)
* Mark sidecar cron container as deprecated

## 1.63-RC2 (2020/05/08)

* Fix poller-wrapper

## 1.63-RC1 (2020/05/08)

* LibreNMS 1.63
* Add sidecar dispatcher container (#70)
* Add `LISTEN_IPV6` env var (#71)
* Alpine Linux 3.11

## 1.62.2-RC2 (2020/04/13)

* Fix log file permissions (#66)
* Switch to Open Container Specification labels as label-schema.org ones are deprecated

## 1.62.2-RC1 (2020/04/04)

* LibreNMS 1.62.2

## 1.61-RC4 (2020/03/27)

* Fix folder creation (#62)

## 1.61-RC3 (2020/03/22)

* Allow multi discovery workers through `LIBRENMS_CRON_DISCOVERY_WRAPPER_WORKERS` env var (#59)

## 1.61-RC2 (2020/03/05)

* Add `php7-sockets` extension (#61)

## 1.61-RC1 (2020/03/02)

* LibreNMS 1.61

## 1.60-RC1 (2020/02/04)

* LibreNMS 1.60

## 1.58.1-RC6 (2020/01/23)

* Move Nginx temp folders to `/tmp` (#55)

## 1.58.1-RC5 (2019/12/20)

* Add snmp-scan option for cron container (#53)

## 1.58.1-RC4 (2019/12/06)

* Fix timezone php.ini

## 1.58.1-RC3 (2019/12/06)

* Bring back timezone management through symlink (#49)

## 1.58.1-RC2 (2019/11/29)

* Fix php date timezone (#49)
* `MEMCACHED_PORT` default port not working (#48)

## 1.58.1-RC1 (2019/11/27)

* LibreNMS 1.58.1

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
