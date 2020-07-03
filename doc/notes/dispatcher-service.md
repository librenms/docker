## Dispatcher service

If you want to enable the new [Dispatcher service](https://docs.librenms.org/Extensions/Dispatcher-Service/), you have to run a "sidecar" container (see dispatcher service in [docker-compose.yml](../../examples/compose/docker-compose.yml) example) or run a simple container like this:

```bash
docker run -d --name librenms_dispatcher \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_DISPATCHER=1 \
  -v librenms:/data \
  librenms/librenms:latest
```

> `-v librenms:/data`<br />
> :warning: `librenms` must be a valid volume already attached to a LibreNMS container
