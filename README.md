<p align="center"><a href="https://github.com/librenms/docker" target="_blank"><img height="128" src="https://raw.githubusercontent.com/librenms/docker/master/.github/docker-librenms.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/librenms/librenms/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/librenms/docker?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/librenms/docker/actions?workflow=build"><img src="https://img.shields.io/github/workflow/status/librenms/docker/build?label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/librenms/librenms/"><img src="https://img.shields.io/docker/stars/librenms/librenms.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/librenms/librenms/"><img src="https://img.shields.io/docker/pulls/librenms/librenms.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

[LibreNMS](https://www.librenms.org/) Docker image based on Alpine Linux and Nginx.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

___

* [Features](#features)
* [Demo](#demo)
* [Build locally](#build-locally)
* [Image](#image)
* [Environment variables](#environment-variables)
  * [General](#general)
  * [Redis](#redis)
  * [Dispatcher service](#dispatcher-service)
  * [Syslog-ng](#syslog-ng)
  * [Snmptrapd](#snmptrapd)
  * [Database](#database)
  * [Misc](#misc)
* [Volumes](#volumes)
* [Ports](#ports)
* [Usage](#usage)
  * [Docker Compose](#docker-compose)
  * [Command line](#command-line)
  * [First launch](#first-launch)
* [Upgrade](#upgrade)
* [Configuration Management](#configuration-management)
  * [Initial Configuration](#initial-configuration)
  * [Live Configuration](#live-configuration)
  * [Re-Apply YAML Config](#re-apply-yaml-config)
  * [Live Config](#live-config)
* [Notes](#notes)
  * [LNMS command](#lnms-command)
  * [Validate](#validate)
  * [Dispatcher service container](#dispatcher-service-container)
  * [Syslog-ng container](#syslog-ng-container)
  * [Snmptrapd container](#snmptrapd-container)
  * [Add a LibreNMS plugin](#add-a-librenms-plugin)
  * [Additional Monitoring plugins](#additional-monitoring-plugins)
  * [Custom alert templates](#custom-alert-templates)
* [Contributing](#contributing)
* [License](#license)

## Features

* Run as non-root user
* Multi-platform image
* [Dispatcher service](#dispatcher-service) as "sidecar" container
* Syslog-ng support through a ["sidecar" container](#syslog-ng)
* Snmp-trap support through a ["sidecar" container](#snmptrapd)
* Built-in LibreNMS [Weathermap plugin](https://docs.librenms.org/Extensions/Weathermap/)
* Ability to add custom Monitoring plugins
* Ability to add custom alert templates
* OPCache enabled to store precompiled script bytecode in shared memory
* [s6-overlay](https://github.com/just-containers/s6-overlay/) as process supervisor
* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates (see [this template](examples/traefik))
* [Redis](https://github.com/docker-library/redis) image ready to use for better scalability
* [RRDcached](https://github.com/crazy-max/docker-rrdcached) image ready to use for data caching and graphs
* [msmtpd SMTP relay](https://github.com/crazy-max/docker-msmtpd) image to send emails
* [MariaDB](https://github.com/docker-library/mariadb) image as database instance

## Demo

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/librenms/docker/master/examples/pwd/librenms.yml)

## Build locally

```console
$ git clone https://github.com/librenms/docker.git docker-librenms
$ cd docker-librenms

# Build image and output to docker (default)
$ docker buildx bake

# Build multi-platform image
$ docker buildx bake image-all
```

## Image

Following platforms for this image are available:

```
$ docker run --rm mplatform/mquery librenms/librenms:latest
Image: librenms/librenms:latest
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/386
   - linux/ppc64le
   - linux/s390x
```

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
* `SESSION_DRIVER`: [Driver to use for session storage](https://github.com/librenms/librenms/blob/master/config/session.php) (default `file`)
* `CACHE_DRIVER`: [Driver to use for cache and locks](https://github.com/librenms/librenms/blob/master/config/cache.php) (default `database`)

### Redis

> **Note**
>
> Redis variables should be set on all containers and are required when running
> more than one dispatcher.

* `REDIS_HOST`: Redis host for poller synchronization
* `REDIS_SENTINEL`: Redis Sentinel host for high availability Redis cluster
* `REDIS_SENTINEL_SERVICE`: Redis Sentinel service name (default `librenms`)
* `REDIS_SCHEME`: Redis scheme (default `tcp`)
* `REDIS_PORT`: Redis port (default `6379`)
* `REDIS_PASSWORD`: Redis password
* `REDIS_DB`: Redis database (default `0`)
* `REDIS_CACHE_DB`: Redis cache database (default `1`)

### Dispatcher service

> **Warning**
>
> Only used if you enable and run a [sidecar dispatcher container](#dispatcher-service-container).

* `SIDECAR_DISPATCHER`: Set to `1` to enable sidecar dispatcher mode for this container (default `0`)
* `DISPATCHER_NODE_ID`: Unique node ID for your dispatcher service
* `DISPATCHER_ARGS`: Additional args to pass to the [dispatcher service](https://github.com/librenms/librenms/blob/master/librenms-service.py)

### Syslog-ng

> **Warning**
>
> Only used if you enable and run a [sidecar syslog-ng container](#syslog-ng-container).

* `SIDECAR_SYSLOGNG`: Set to `1` to enable sidecar syslog-ng mode for this container (default `0`)

### Snmptrapd

> **Warning**
>
> Only used if you enable and run a [sidecar snmptrapd container](#snmptrapd-container).

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

## Volumes

* `/data`: Contains configuration, plugins, rrd database, logs, additional Monitoring plugins, additional syslog-ng config files

> **Warning**
>
> Note that the volume should be owned by the user/group with the specified
> `PUID` and `PGID`. If you don't give the volume correct permissions, the
> container may not start.

## Ports

* `8000`: HTTP port
* `514 514/udp`: Syslog ports (only used if you enable and run a [sidecar syslog-ng container](#syslog-ng-container))
* `162 162/udp`: Snmptrapd ports (only used if you enable and run a [sidecar snmptrapd container](#snmptrapd-container))

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of
folder [examples/compose](examples/compose) in `/var/librenms/` on your host
for example. Edit the compose and env files with your preferences and run the
following commands:

```console
$ docker-compose up -d
$ docker-compose logs -f
```

### Command line

You can also use the following minimal command:

```console
$ docker run -d -p 8000:8000 --name librenms \
  -v $(pwd)/data:/data \
  -e "DB_HOST=db" \
  librenms/librenms:latest
```

> **Warning**
>
> `db` must be a running MySQL instance.

### First launch

On first launch, an initial administrator user will be created:

| Login      | Password   |
|------------|------------|
| `librenms` | `librenms` |

> **Note**
>
> You can create another one using the [`lnms` command](#lnms-command).

## Upgrade

To upgrade to the latest version of LibreNMS, pull the newer image and launch
the container. LibreNMS will upgrade automatically:

```console
$ docker-compose down
$ docker-compose pull
$ docker-compose up -d
```

## Configuration Management

### Initial Configuration

You can set the initial configuration of LibreNMS by placing `*.yaml` files inside `/data/config` folder. Let's say you want to edit the [WebUI config](https://docs.librenms.org/Support/Configuration/#webui-settings).
Create a file called for example `/data/config/webui.yaml` with this content :

```yaml
page_refresh: 300
webui.default_dashboard_id: 0
```

This configuration will be seeded into the LibreNMS database when it is first deployed 
and will override the default values.

### Live Configuration

You can edit the running configuration via the LibreNMS web UI or `lnms config:set`

```bash
docker-compose exec librenms lnms config:set page_refresh 300
```

### Re-Apply YAML Config

Set `REAPPLY_YAML_CONFIG=1` to overwrite any settings that are set during initial config
or via user config back to their initial values every time the container is deployed.

### Live Config

Using this config method, configuration changes will be reflected live on the containers, BUT
you will be unable to edit the configured settings from within the LibreNMS web UI or lnms config:set.

The same example using PHP `/data/config/webui.php`

```php
<?php
$config['page_refresh'] = "300";
$config['webui']['default_dashboard_id'] = 0;
```

## Notes

### LNMS command

If you want to use the `lnms` command to perform common server operations like
manage users, database migration, and more, type:

```console
$ docker-compose exec librenms lnms
```

### Validate

If you want to validate your installation from the CLI, type the following
command:

```console
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

### Dispatcher service container

If you want to enable the new [Dispatcher service](https://docs.librenms.org/Extensions/Dispatcher-Service/),
you have to run a "sidecar" container (see dispatcher service in
[docker-compose.yml](examples/compose/docker-compose.yml) example) or run a
simple container like this:

```console
$ docker run -d --name librenms_dispatcher \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_DISPATCHER=1 \
  -e DISPATCHER_NODE_ID=dispatcher1 \
  -v librenms:/data \
  librenms/librenms:latest
```

> **Warning**
>
> `librenms` must be a valid volume already attached to a LibreNMS container.

### Syslog-ng container

If you want to enable syslog-ng, you have to run a "sidecar" container (see
syslog-ng service in [docker-compose.yml](examples/compose/docker-compose.yml)
example) or run a simple container like this:

```console
$ docker run -d --name librenms_syslog \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_SYSLOGNG=1 \
  -p 514 -p 514/udp \
  -v librenms:/data \
  librenms/librenms:latest
```

> **Warning**
>
> `librenms` must be a valid volume already attached to a LibreNMS container.

You have to create a configuration file to enable syslog in LibreNMS too. Create
a file called for example `/data/config/syslog.yaml` with this content :

```yaml
enable_syslog: true
```

### Snmptrapd container

If you want to enable snmptrapd, you have to run a "sidecar" container (see
snmptrapd service in [docker-compose.yml](examples/compose/docker-compose.yml)
example) or run a simple container like this:

```console
$ docker run -d --name librenms_snmptrapd \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_SNMPTRAPD=1 \
  -p 162 -p 162/udp \
  -v librenms:/data \
  librenms/librenms:latest
```

> **Warning**
>
> `librenms` must be a valid volume already attached to a LibreNMS container.

### Add a LibreNMS plugin

You can add [plugins for LibreNMS](https://docs.librenms.org/Extensions/Plugin-System/)
in `/data/plugins/`. If you add a plugin that already exists in LibreNMS, it
will be removed and yours will be used (except for Weathermap).

> **Warning**
>
> Container has to be restarted to propagate changes.

### Additional Monitoring plugins

You can add a custom Monitoring plugin in `/data/monitoring-plugins/`.

Some plugins can be found in the [Monitoring Plugins](https://github.com/monitoring-plugins/monitoring-plugins#readme)
repo, or in the [unofficial fork for Nagios](https://github.com/nagios-plugins/nagios-plugins#readme).

> **Warning**
>
> Container has to be restarted to propagate changes.

### Custom alert templates

You can add [Laravel alert templates](https://docs.librenms.org/Alerting/Templates/#base-templates)
in `/data/alert-templates/`.

> **Warning**
>
> Container has to be restarted to propagate changes.

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star the project, or to raise issues. You
can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max) or by making
a [Paypal donation](https://www.paypal.me/crazyws) to ensure this journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
