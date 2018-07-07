<p align="center"><a href="https://github.com/crazy-max/docker-librenms" target="_blank"><img height="128"src="https://raw.githubusercontent.com/crazy-max/docker-librenms/master/.res/docker-librenms.jpg"></a></p>

<p align="center">
  <a href="https://microbadger.com/images/crazymax/librenms"><img src="https://images.microbadger.com/badges/version/crazymax/librenms.svg?style=flat-square" alt="Version"></a>
  <a href="https://travis-ci.org/crazy-max/docker-librenms"><img src="https://img.shields.io/travis/crazy-max/docker-librenms/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/librenms/"><img src="https://img.shields.io/docker/stars/crazymax/librenms.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/librenms/"><img src="https://img.shields.io/docker/pulls/crazymax/librenms.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/crazymax/librenms"><img src="https://quay.io/repository/crazymax/librenms/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=962TPYQKMQ2UE"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [LibreNMS](https://www.librenms.org/) Docker image based on Alpine Linux and Nginx.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

## Features

### Included

* Alpine Linux 3.8, Nginx, PHP 7.2
* Cron tasks as a ["sidecar" container](#cron)
* [SSMTP](https://linux.die.net/man/8/ssmtp) for SMTP relay to send emails
* OPCache enabled to store precompiled script bytecode in shared memory

### From docker-compose

* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates
* [Memcached](https://github.com/docker-library/memcached) image ready to use for better scalability
* [RRDcached](https://github.com/crazy-max/rrdcached) image ready to use for better scalability
* [MariaDB](https://github.com/docker-library/mariadb) image as database instance
* Cron jobs as a ["sidecar" container](#cron)

## Docker

### Environment variables

| Key                         | Default           | Description                               
|-----------------------------|-------------------|-------------------------------------------
| `TZ`                        | `UTC`             | Timezone (e.g. `Europe/Paris`)
| `PUID`                      | `1000`            | LibreNMS user id
| `PGID`                      | `1000`            | LibreNMS group id
| `MEMORY_LIMIT`              | `256M`            | PHP memory limit
| `UPLOAD_MAX_SIZE`           | `16M`             | Upload max size
| `OPCACHE_MEM_SIZE`          | `128`             | PHP OpCache memory consumption
| `LIBRENMS_POLLER_THREADS`   | `16`              | Threads that `poller-wrapper.py` runs
| `LIBRENMS_SNMP_COMMUNITY`   | `librenmsdocker`  | Your community string
| `DB_HOST`                   |                   | MySQL database hostname / IP address
| `DB_PORT`                   | `3306`            | MySQL database port
| `DB_NAME`                   | `librenms`        | MySQL database name
| `DB_USER`                   | `librenms`        | MySQL user
| `DB_PASSWORD`               | `librenms`        | MySQL password
| `SSMTP_HOST`                |                   | SMTP server host
| `SSMTP_PORT`                | `25`              | SMTP server port
| `SSMTP_HOSTNAME`            | `$(hostname -f)`  | Full hostname
| `SSMTP_USER`                |                   | SMTP username
| `SSMTP_PASSWORD`            |                   | SMTP password
| `SSMTP_TLS`                 | `NO`              | SSL/TLS
| `MEMCACHED_HOST`            |                   | Hostname / IP address of a Memcached server
| `RRDCACHED_HOST`            |                   | Hostname / IP address of a RRDcached server

### Volumes

* `/data` : Contains configuration, rrd database, logs

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
  crazymax/librenms:latest
```

> `-e "DB_HOST=db"`
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

### Validate

If you want to validate your installation from the CLI, type the following command :

```bash
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
[FAIL]  fping6 location is incorrect or bin not installed.
        [FIX] Install fping6 or manually set the path to fping6 by placing the following in config.php: $config['fping6'] = '/path/to/fping6';
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

### Cron

If you want to enable the cron job, you have to run a "sidecar" container like in the [docker-compose file](examples/compose/docker-compose.yml) or run a simple container like this :

```bash
docker run -d --name librenms-cron \
  --env-file $(pwd)/librenms.env \
  -v librenms:/data \
  crazymax/librenms:latest /usr/local/bin/cron
```

> `-v librenms:/data`
> :warning: `librenms` must be a valid volume already attached to a LibreNMS container

## Upgrade

To upgrade to the latest version of LibreNMS, pull the newer image and launch the container. LibreNMS will upgrade automatically :

```bash
docker-compose pull
docker-compose up -d
```

## How can i help ?

All kinds of contributions are welcomed :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=962TPYQKMQ2UE)

## License

MIT. See `LICENSE` for more details.
