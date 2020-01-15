# Old server

## Docker backup

Backup everything what belongs to LibreNMS:  

> List your docker images with `docker ps`.

- librenms
- librenms_cron
- librenms_db
- librenms_memcached
- librenms_rrdcached
- librenms_smtp
- librenms_syslog
- traefik

```
docker save -o ~/librenms.tar librenms \
docker save -o ~/librenms_cron.tar librenms_cron \
docker save -o ~/librenms_db.tar librenms_db \
docker save -o ~/librenms_memcached.tar librenms_memcached \
docker save -o ~/librenms_rrdcached.tar librenms_rrdcached \
docker save -o ~/librenms_smtp.tar librenms_smtp \
docker save -o ~/librenms_syslog.tar librenms_syslog \
docker save -o ~/traefik.tar traefik
```

### All in one
If you run LibreNMS only in Docker, you can easily create a backup with a single command:
```
docker save $(docker images -q) -o ~/librenms.tar
```

&nbsp;

## LibreNMS local folder

```
tar -czf ~/librenms.tar.gz librenms/
```

### Moving files to new server with rsync
[Multiple files](BACKUP.md#docker-backup):
```
rsync -chavzP ~/librenms* ~/traefik* user@ip:/var/
```

"[_All in one_](BACKUP.md#all-in-one)" file:
```
rsync -chavzP ~/librenms* user@ip:/var/
```

&nbsp;

# New server

## Docker restore
[Multiple files](BACKUP.md#docker-backup):
```
docker load -i /var/librenms.tar librenms \
docker load -i /var/librenms_cron.tar librenms_cron \
docker load -i /var/librenms_db.tar librenms_db \
docker load -i /var/librenms_memcached.tar librenms_memcached \
docker load -i /var/librenms_rrdcached.tar librenms_rrdcached \
docker load -i /var/librenms_smtp.tar librenms_smtp \
docker load -i /var/librenms_syslog.tar librenms_syslog \
docker load -i /var/traefik.tar traefik
...
```

"[_All in one_](BACKUP.md#all-in-one)" file:
```
docker load -i /var/librenms.tar
```

&nbsp;

## LibreNMS local folder
```
tar -xvf /var/librenms.tar.gz
```

### Change docker-compose.yml
If you use a different IP address, you need to change the .yml file.

```
nano /var/librenms/docker-compose.yml
```

&nbsp;

## Update and run
```
cd /var/
docker-compose pull
docker-compose up -d
```