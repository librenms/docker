## Use this image

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](../examples/compose) in `/var/librenms/` on your host for example. Edit the compose and env files with your preferences and run the following commands:

```bash
docker-compose --project-name LibreNMS up -d
docker-compose logs -f
```

### Command line

You can also use the following minimal command :

```bash
docker run -d -p 8000:8000 --name librenms \
  -v $(pwd)/data:/data \
  -e "DB_HOST=db" \
  librenms/librenms:latest
```

> `-e "DB_HOST=db"`<br />
> :warning: `db` must be a running MySQL instance

### First launch

On first launch, an initial administrator user will be created:

| Login      | Password   |
|------------|------------|
| `librenms` | `librenms` |

You can create another one using the [`lnms` command](notes/lnms-command.md).
