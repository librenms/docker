## Snmptrapd

If you want to enable snmptrapd, you have to run a "sidecar" container (see snmptrapd service in [docker-compose.yml](../../examples/compose/docker-compose.yml) example) or run a simple container like this :

```bash
docker run -d --name librenms_snmptrapd \
  --env-file $(pwd)/librenms.env \
  -e SIDECAR_SNMPTRAPD=1 \
  -p 162 -p 162/udp \
  -v librenms:/data \
  librenms/librenms:latest
```
