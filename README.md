<p align="center"><a href="https://github.com/librenms/docker" target="_blank"><img height="128"src="https://raw.githubusercontent.com/librenms/docker/master/.res/docker-librenms.jpg"></a></p>

<p align="center">
  <a href="https://microbadger.com/images/librenms/librenms"><img src="https://images.microbadger.com/badges/version/librenms/librenms.svg?style=flat-square" alt="Version"></a>
  <a href="https://travis-ci.com/librenms/docker"><img src="https://img.shields.io/travis/com/librenms/docker/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/librenms/librenms/"><img src="https://img.shields.io/docker/stars/librenms/librenms.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/librenms/librenms/"><img src="https://img.shields.io/docker/pulls/librenms/librenms.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/librenms/librenms"><img src="https://quay.io/repository/librenms/librenms/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.codacy.com/app/librenms/docker"><img src="https://img.shields.io/codacy/grade/42f89bb80153441da8a02a71fb829080.svg?style=flat-square" alt="Code Quality"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=962TPYQKMQ2UE"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [LibreNMS](https://www.librenms.org/) Docker image based on Alpine Linux and Nginx.<br />
It's a fork of [CrazyMax's LibreNMS Docker image repository](https://github.com/crazy-max/docker-librenms). If you are interested, [check out](https://hub.docker.com/r/crazymax/) his other 🐳 Docker images!

## Features

### Included

* Alpine Linux 3.8, Nginx, PHP 7.2
* Cron tasks as a ["sidecar" container](#crons)
* Syslog-ng support through a ["sidecar" container](#syslog-ng)
* Ability to configure [distributed polling](https://docs.librenms.org/#Extensions/Distributed-Poller/#distributed-poller)
* Ability to add custom Monitoring plugins (Nagios)
* OPCache enabled to store precompiled script bytecode in shared memory

### From docker-compose

* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates
* [Memcached](https://github.com/docker-library/memcached) image ready to use for better scalability
* [RRDcached](https://github.com/crazy-max/docker-rrdcached) image ready to use for better scalability
* [Postfix SMTP relay](https://github.com/juanluisbaptiste/docker-postfix) image to send emails
* [MariaDB](https://github.com/docker-library/mariadb) image as database instance
* Cron jobs as a ["sidecar" container](#cron)
* Syslog-ng support through a ["sidecar" container](#syslog-ng)

## Docker

### Environment variables

#### General

* `TZ` : The timezone assigned to the container (default `UTC`)
* `PUID` : LibreNMS user id (default `1000`)
* `PGID`: LibreNMS group id (default `1000`)
* `MEMORY_LIMIT` : PHP memory limit (default `256M`)
* `UPLOAD_MAX_SIZE` : Upload max size (default `16M`)
* `OPCACHE_MEM_SIZE` : PHP OpCache memory consumption (default `128`)

#### (Distributed) Poller

* `LIBRENMS_POLLER_THREADS` : Threads that `poller-wrapper.py` runs (default `16`)
* `LIBRENMS_POLLER_INTERVAL` : Interval in minutes at which `poller-wrapper.py` runs (defaults to `5`) [docs](https://docs.librenms.org/#Support/1-Minute-Polling/)
* `LIBRENMS_DISTRIBUTED_POLLER_ENABLE` : Enable distributed poller functionality
* `LIBRENMS_DISTRIBUTED_POLLER_NAME` : Optional name of poller (defaults to hostname)
* `LIBRENMS_DISTRIBUTED_POLLER_GROUP` : By default, all hosts are shared and have the poller_group = 0. To pin a device to a poller, set it to a value greater than 0 and set the same value here. One can also specify a comma separated string of poller groups. The poller will then poll devices from any of the groups listed. [docs](https://docs.librenms.org/#Extensions/Distributed-Poller/#distributed-poller)
* `LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST` : Memcached server for poller synchronization (Defaults to `$MEMCACHED_HOST`)
* `LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_PORT` : Port of memcached server (Defaults to `$MEMCACHED_PORT`)

#### Cron

* `LIBRENMS_CRON_DISCOVERY_ENABLE` : Enable LibreNMS discovery for this container cronjobs (default `true`)
* `LIBRENMS_CRON_DAILY_ENABLE` : Enable LibreNMS daily script for this container cronjobs (default `true`)
* `LIBRENMS_CRON_ALERTS_ENABLE` : Enable LibreNMS alerts generation for this container cronjobs (default `true`)
* `LIBRENMS_CRON_BILLING_ENABLE` : Enable LibreNMS billing polling for this container cronjobs (default `true`)
* `LIBRENMS_CRON_BILLING_CALCULATE_ENABLE` : Enable LibreNMS billing for this container cronjobs (default `true`)
* `LIBRENMS_CRON_CHECK_SERVICES_ENABLE` : Enable LibreNMS service checks for this container cronjobs (default `true`)
* `LIBRENMS_CRON_POLLER_ENABLE` : Enable LibreNMS polling for this container cronjobs (default `true`)

#### Database

* `DB_HOST` : MySQL database hostname / IP address
* `DB_PORT` : MySQL database port (default `3306`)
* `DB_NAME` : MySQL database name (default `librenms`)
* `DB_USER` : MySQL user (default `librenms`)
* `DB_PASSWORD` : MySQL password (default `librenms`)
* `DB_TIMEOUT` : Time in seconds after which we stop trying to reach the MySQL server (useful for clusters, default `30`)

#### Misc

* `LIBRENMS_SNMP_COMMUNITY` : This container's SNMP v2c community string (default `librenmsdocker`)
* `MEMCACHED_HOST` : Hostname / IP address of a Memcached server
* `MEMCACHED_PORT` : Port of the Memcached server (default `11211`)
* `RRDCACHED_HOST` : Hostname / IP address of a RRDcached server
* `RRDCACHED_PORT` : Port of the RRDcached server (default `42217`)

### Volumes

* `/data` : Contains configuration, rrd database, logs, additional Monitoring plugins, additional syslog-ng config files

### Ports

* `80` : HTTP port

## Use this image

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](examples/compose) in `/var/librenms/` on your host for example. Edit the compose and env files with your preferences and run the following commands :

```bash
touch acme.json
chmod 600 acme.json
docker-compose up -d
docker-compose logs -f
```

### Command line

You can also use the following minimal command :

```bash
docker run -d -p 80:80 --name librenms \
  -v $(pwd)/data:/data \
  -e "DB_HOST=db" \
  librenms/librenms:latest
```

> `-e "DB_HOST=db"`<br />
> :warning: `db` must be a running MySQL instance

## Notes

### Edit configuration

You can edit configuration of LibreNMS by placing `*.php` files inside `/data/config` folder. Let's say you want to edit the [WebUI config](https://docs.librenms.org/#Support/Configuration/#webui-settings). Create a file called for example `/data/config/webui.php` with this content :

```php
<?php
$config['page_refresh'] = "300";
$config['webui']['default_dashboard_id'] = 0;
```

This configuration will be included in LibreNMS and will override the default values.

### Add user

On first launch, an initial administrator user will be created :

| Login      | Password   |
|------------|------------|
| `librenms` | `librenms` |

You can create an other user using the commande line :

```text
$ docker exec -it --user librenms librenms php adduser.php <name> <pass> 10 <email>
```

> :warning: Substitute your desired username `<name>`, password `<pass>` and email address `<email>`

### Validate

If you want to validate your installation from the CLI, type the following command :

```text
$ docker exec -it --user librenms librenms php validate.php
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

### Update database

To update the database manually, type the following command :

```bash
$ docker exec -it --user librenms librenms php build-base.php
```

### Crons

If you want to enable the cron job, you have to run a "sidecar" container like in the [docker-compose file](examples/compose/docker-compose.yml) or run a simple container like this :

```bash
docker run -d --name librenms-cron \
  --env-file $(pwd)/librenms.env \
  -v librenms:/data \
  librenms/librenms:latest /usr/local/bin/cron
```

> `-v librenms:/data`<br />
> :warning: `librenms` must be a valid volume already attached to a LibreNMS container

### Syslog-ng

If you want to enable syslog-ng, you have to run a "sidecar" container like in the [docker-compose file](examples/compose/docker-compose.yml) or run a simple container like this :

```bash
docker run -d --name librenms-syslog-ng \
  --env-file $(pwd)/librenms.env \
  -p 514 -p 514/udp \
  -v librenms:/data \
  librenms/librenms:latest /usr/sbin/syslog-ng -F
```

You have to create a configuration file to enable syslog in LibreNMS too. Create a file called for example `/data/config/syslog.php` with this content :

```php
<?php
$config['enable_syslog'] = 1;
```

## Additional Monitoring plugins (Nagios)

You can add a custom Monitoring (Nagios) plugin in `/data/monitoring-plugins/`.

> ⚠️ Container has to be restarted to propagate changes

## Upgrade

To upgrade to the latest version of LibreNMS, pull the newer image and launch the container. LibreNMS will upgrade automatically :

```bash
docker-compose pull
docker-compose up -d
```

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=962TPYQKMQ2UE)

## License

MIT. See `LICENSE` for more details.
