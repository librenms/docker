<p align="center"><a href="https://github.com/librenms/docker" target="_blank"><img height="128" src="https://raw.githubusercontent.com/librenms/docker/master/.res/docker-librenms.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/librenms/librenms/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/librenms/docker?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/librenms/docker/actions"><img src="https://github.com/librenms/docker/workflows/build/badge.svg" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/librenms/librenms/"><img src="https://img.shields.io/docker/stars/librenms/librenms.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/librenms/librenms/"><img src="https://img.shields.io/docker/pulls/librenms/librenms.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/librenms/librenms"><img src="https://quay.io/repository/librenms/librenms/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.codacy.com/app/librenms/docker"><img src="https://img.shields.io/codacy/grade/42f89bb80153441da8a02a71fb829080.svg?style=flat-square" alt="Code Quality"></a>
  <br /><a href="https://www.patreon.com/crazymax"><img src="https://img.shields.io/badge/donate-patreon-f96854.svg?logo=patreon&style=flat-square" alt="Support me on Patreon"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [LibreNMS](https://www.librenms.org/) Docker image based on Alpine Linux and Nginx.<br />
It's a fork of [CrazyMax's LibreNMS Docker image repository](https://github.com/crazy-max/docker-librenms). If you are interested, [check out](https://hub.docker.com/r/crazymax/) his other 🐳 Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

## Features

* Cron tasks as a ["sidecar" container](doc/notes/crons.md)
* Syslog-ng support through a ["sidecar" container](doc/notes/syslog-ng.md)
* Ability to configure [distributed polling](https://docs.librenms.org/#Extensions/Distributed-Poller/#distributed-poller)
* Ability to add custom Monitoring plugins (Nagios)
* OPCache enabled to store precompiled script bytecode in shared memory
* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates (see [this template](examples/traefik))
* [Memcached](https://github.com/docker-library/memcached) image ready to use for better scalability
* [RRDcached](https://github.com/crazy-max/docker-rrdcached) image ready to use for better scalability
* [Postfix SMTP relay](https://github.com/juanluisbaptiste/docker-postfix) image to send emails
* [MariaDB](https://github.com/docker-library/mariadb) image as database instance
* Cron jobs as a ["sidecar" container](doc/docker/environment-variables.md#cron)
* Syslog-ng support through a ["sidecar" container](doc/docker/environment-variables.md#syslog-ng)

## Documentation

* Docker
  * [Environment variables](doc/docker/environment-variables.md)
  * [Volumes](doc/docker/volumes.md)
  * [Ports](doc/docker/ports.md)
* [Usage](doc/usage.md)
* Notes
  * [Edit configuration](doc/notes/edit-config.md)
  * [Add user](doc/notes/add-user.md)
  * [Validate](doc/notes/validate.md)
  * [Update database](doc/notes/update-database.md)
  * [Crons](doc/notes/crons.md)
  * [Syslog-ng](doc/notes/syslog-ng.md)
  * [Additional Monitoring plugins (Nagios)](doc/notes/additional-monitoring-plugins.md)
* [Upgrade](doc/upgrade.md)

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Support me on Patreon](.res/patreon.png)](https://www.patreon.com/crazymax) 
[![Paypal Donate](.res/paypal.png)](https://www.paypal.me/crazyws)

## License

MIT. See `LICENSE` for more details.
