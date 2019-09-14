## Use this image

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](../examples/compose) in `/var/librenms/` on your host for example. Edit the compose and env files with your preferences and run the following commands :

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
