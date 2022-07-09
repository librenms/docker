# Use this image

## Docker Compose

Docker compose is the recommended way to run this image.

### Modular sidecar layout

Copy the content of folder [examples/compose](../examples/compose) to your host. Edit the compose and env files with your preferences and run the following commands:
You should carefully review the Docker compose file and edit it to suit your needs.

```shell
docker-compose up -d
docker-compose logs -f
```

### Stand-alone layout

Install mariadb and librenms as two containers listening on port 8000.
This uses pwgen to generate a random mysql password, alternatively, you may just enter a password.

```shell
wget https://raw.githubusercontent.com/librenms/docker/master/examples/compose/docker-compose-standalone.yml
MYSQL_PASSWORD="`pwgen -Bs1 12`" docker-compose -f docker-compose-standalone.yml up -d
docker-compose logs -f
```

### Stand-alone layout with HTTPS

Use Traefik to generate a letsencrypt ssl certificate and redirect to https.  Uses pwgen.

```shell
wget https://raw.githubusercontent.com/librenms/docker/master/examples/compose/docker-compose-standalone-https.yml
MYSQL_PASSWORD="`pwgen -Bs1 12`" \
LETSENCRYPT_EMAIL="email@example.com" \
LIBRENMS_BASE_URL="public-dns.example.com" \
docker-compose -f docker-compose-standalone-https.yml up -d

docker-compose logs -f
```

## Command line

You can also use the following minimal command :

```bash
docker run -d -p 8000:8000 --name librenms \
  -v $(pwd)/data:/data \
  -e "DB_HOST=db" \
  -e "STANDALONE=1" \
  librenms/librenms:latest
```

> `-e "DB_HOST=db"`<br />
> :warning: `db` must be a running MySQL instance

## First launch

On first launch, an initial administrator user will be created:

| Login      | Password   |
|------------|------------|
| `librenms` | `librenms` |

You can create another one using the [`lnms` command](notes/lnms-command.md).
