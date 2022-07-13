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

## Demo

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/librenms/docker/master/examples/pwd/librenms.yml)

## Features

* Run as non-root user
* Multi-platform image
* [Dispatcher service](doc/docker/environment-variables.md#dispatcher-service) as "sidecar" container
* Syslog-ng support through a ["sidecar" container](doc/docker/environment-variables.md#syslog-ng)
* Snmp-trap support through a ["sidecar" container](doc/docker/environment-variables.md#snmptrapd)
* Sidecar modular service mode or monolitic mode
* Built-in LibreNMS [Weathermap plugin](https://docs.librenms.org/Extensions/Weathermap/)
* Ability to add custom Monitoring plugins
* Ability to add custom alert templates
* OPCache enabled to store precompiled script bytecode in shared memory
* [s6-overlay](https://github.com/just-containers/s6-overlay/) as process supervisor
* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates (see [this template](examples/traefik))
* [Redis](https://github.com/docker-library/redis) image ready to use for better scalability
* [RRDcached](https://github.com/crazy-max/docker-rrdcached) Either by sidecar or external image for data caching and graphs
* [msmtpd SMTP relay](https://github.com/crazy-max/docker-msmtpd) image to send emails
* [MariaDB](https://github.com/docker-library/mariadb) image as database instance

## Docker Compose Recipes

Visit the [usage documentation](doc/usage.md) and run the stand-alone docker compose.

## Build locally

```shell
git clone https://github.com/librenms/docker.git docker-librenms
cd docker-librenms

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Multi-platform image

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

## Documentation

* Docker
  * [Environment variables](doc/docker/environment-variables.md)
  * [Volumes](doc/docker/volumes.md)
  * [Ports](doc/docker/ports.md)
* [Usage](doc/usage.md)
* Notes
  * [Edit configuration](doc/notes/edit-config.md)
  * [LNMS command](doc/notes/lnms-command.md)
  * [Validate](doc/notes/validate.md)
  * [Dispatcher service](doc/notes/dispatcher-service.md)
  * [Add a LibreNMS plugin](doc/notes/plugins.md)
  * [Syslog-ng](doc/notes/syslog-ng.md)
  * [Additional Monitoring plugins](doc/notes/additional-monitoring-plugins.md)
  * [Custom alert templates](doc/notes/alert-templates.md)
* [Upgrade](doc/upgrade.md)

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star the project, or to raise issues. You
can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max) or by making
a [Paypal donation](https://www.paypal.me/crazyws) to ensure this journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
