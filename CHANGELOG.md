# Changelog

## 1.45-RC1 (2018/10/28)
 * Upgrade to LibreNMS 1.45

## 1.44-RC1 (2018/10/17)

* Upgrade to LibreNMS 1.44
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

* Upgrade to LibreNMS 1.43

## 1.42.01-RC1 (2018/08/05)

* Upgrade to LibreNMS 1.42.01

## 1.42-RC1 (2018/08/02)

* Upgrade to LibreNMS 1.42
* Add syslog-ng support

## 1.41-RC1 (2018/07/07)

* Initial version based on LibreNMS 1.41
