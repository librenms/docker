## Crons

If you want to enable the cronjob, you have to run a "sidecar" container (see cron service in [docker-compose.yml](../../examples/compose/docker-compose.yml) example) or run a simple container like this :

```bash
docker run -d --name librenms_cron \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_CRON=1 \
  -v librenms:/data \
  librenms/librenms:latest
```

> `-v librenms:/data`<br />
> :warning: `librenms` must be a valid volume already attached to a LibreNMS container
