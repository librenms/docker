## Syslog-ng

If you want to enable syslog-ng, you have to run a "sidecar" container (see syslog-ng service in [docker-compose.yml](../../examples/compose/docker-compose.yml) example) or run a simple container like this :

```bash
docker run -d --name librenms_syslog \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_SYSLOGNG=1 \
  -p 514 -p 514/udp \
  -v librenms:/data \
  librenms/librenms:latest
```

You have to create a configuration file to enable syslog in LibreNMS too. Create a file called for example `/data/config/syslog.php` with this content :

```php
<?php
$config['enable_syslog'] = 1;
```
