#!/bin/sh

function runas_librenms() {
  su - librenms -s /bin/sh -c "$1"
}

TZ=${TZ:-"UTC"}
PUID=${PUID:-1000}
PGID=${PGID:-1000}

MEMORY_LIMIT=${MEMORY_LIMIT:-"256M"}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-"16M"}
OPCACHE_MEM_SIZE=${OPCACHE_MEM_SIZE:-"128"}

LIBRENMS_POLLER_THREADS=${LIBRENMS_POLLER_THREADS:-"16"}
LIBRENMS_SNMP_COMMUNITY=${LIBRENMS_SNMP_COMMUNITY:-"librenmsdocker"}

DB_PORT=${DB_PORT:-"3306"}
DB_NAME=${DB_NAME:-"librenms"}
DB_USER=${DB_USER:-"librenms"}
DB_PASSWORD=${DB_PASSWORD:-"asupersecretpassword"}

MEMCACHED_PORT=${MEMCACHED_PORT:-"11211"}

RRDCACHED_PORT=${RRDCACHED_PORT:-"42217"}

# Timezone
echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone
sed -i -e "s|date\.timezone.*|date\.timezone = ${TZ}|" /etc/php7/php.ini \

# Change librenms UID / GID
echo "Checking if librenms UID / GID has changed..."
if [ $(id -u librenms) != ${PUID} ]; then
  usermod -u ${PUID} librenms
fi
if [ $(id -g librenms) != ${PGID} ]; then
  groupmod -g ${PGID} librenms
fi

# PHP
echo "Setting PHP-FPM configuration..."
sed -e "s/@MEMORY_LIMIT@/$MEMORY_LIMIT/g" \
  -e "s/@UPLOAD_MAX_SIZE@/$UPLOAD_MAX_SIZE/g" \
  /tpls/etc/php7/php-fpm.d/www.conf > /etc/php7/php-fpm.d/www.conf

# OpCache
echo "Setting OpCache configuration..."
sed -e "s/@OPCACHE_MEM_SIZE@/$OPCACHE_MEM_SIZE/g" \
  /tpls/etc/php7/conf.d/opcache.ini > /etc/php7/conf.d/opcache.ini

# Nginx
echo "Setting Nginx configuration..."
sed -e "s/@UPLOAD_MAX_SIZE@/$UPLOAD_MAX_SIZE/g" \
  /tpls/etc/nginx/nginx.conf > /etc/nginx/nginx.conf

# SNMP
echo "Updating SNMP community..."
sed -i -e "s/RANDOMSTRINGGOESHERE/${LIBRENMS_SNMP_COMMUNITY}/" /etc/snmp/snmpd.conf

# Init files and folders
echo "Initializing LibreNMS files / folders..."
mkdir -p ${DATA_PATH}/config \
  ${DATA_PATH}/logs \
  ${DATA_PATH}/rrd
rm -f ${LIBRENMS_PATH}/config.d/*

echo "Setting LibreNMS configuration..."

# Config : Directories
  cat > ${LIBRENMS_PATH}/config.d/directories.php <<EOL
<?php
\$config['install_dir'] = '${LIBRENMS_PATH}';
\$config['log_dir'] = '${DATA_PATH}/logs';
\$config['rrd_dir'] = '${DATA_PATH}/rrd';
EOL

# Config : Database
if [ -z "$DB_HOST" ]; then
  >&2 echo "ERROR: DB_HOST must be defined"
  exit 1
fi
cat > ${LIBRENMS_PATH}/config.d/database.php <<EOL
<?php
\$config['db_host'] = '${DB_HOST}';
\$config['db_port'] = ${DB_PORT};
\$config['db_user'] = '${DB_USER}';
\$config['db_pass'] = '${DB_PASSWORD}';
\$config['db_name'] = '${DB_NAME}';
EOL
dbcmd="mysql -h ${DB_HOST} -P ${DB_PORT} -u "${DB_USER}" "-p${DB_PASSWORD}""
unset DB_PASSWORD

# Config : User
cat > ${LIBRENMS_PATH}/config.d/user.php <<EOL
<?php
\$config['user'] = "librenms";
EOL

# Config : Fping
cat > ${LIBRENMS_PATH}/config.d/fping.php <<EOL
<?php
\$config['fping'] = "/usr/sbin/fping";
EOL

# Config : Disable autoupdate
cat > ${LIBRENMS_PATH}/config.d/autoupdate.php <<EOL
<?php
\$config['update'] = 0;
EOL

# Config : Memcached
if [ ! -z "${MEMCACHED_HOST}" ]; then
    cat > ${LIBRENMS_PATH}/config.d/memcached.php <<EOL
<?php
\$config['memcached']['enable'] = true;
\$config['memcached']['host'] = '$MEMCACHED_HOST';
\$config['memcached']['port'] = $MEMCACHED_PORT;
EOL
fi

# Config : RRDcached
if [ ! -z "${RRDCACHED_HOST}" ]; then
    cat > ${LIBRENMS_PATH}/config.d/rrdcached.php <<EOL
<?php
\$config['rrdcached'] = "${RRDCACHED_HOST}:${RRDCACHED_PORT}";
EOL
fi

# Sidecar cron container ?
if [ "$1" == "/usr/local/bin/cron" ]; then
  echo ">>"
  echo ">> Sidecar cron container detected"
  echo ">>"

  # Init
  rm -rf ${CRONTAB_PATH}
  mkdir -m 0644 -p ${CRONTAB_PATH}
  touch ${CRONTAB_PATH}/librenms

  # Add crons
  cat ${LIBRENMS_PATH}/librenms.nonroot.cron > ${CRONTAB_PATH}/librenms
  sed -i -e "s/ librenms //" ${CRONTAB_PATH}/librenms
  sed -i -e "s/poller-wrapper.py 16/poller-wrapper.py  ${LIBRENMS_POLLER_THREADS}/g" ${CRONTAB_PATH}/librenms

  # Fix perms
  echo "Fixing permissions..."
  chmod -R 0644 ${CRONTAB_PATH}
elif [ "$1" == "/usr/sbin/syslog-ng" ]; then
  echo ">>"
  echo ">> Sidecar syslog-ng container detected"
  echo ">>"

  # Init
  mkdir -p ${DATA_PATH}/syslog-ng /run/syslog-ng
  chown -R librenms. ${DATA_PATH}/syslog-ng /run/syslog-ng
else
  # Fix perms
  echo "Fixing permissions..."
  chown -R librenms. ${DATA_PATH} \
    ${LIBRENMS_PATH}/config.d \
    ${LIBRENMS_PATH}/bootstrap \
    ${LIBRENMS_PATH}/storage
  chmod ug+rw ${DATA_PATH}/logs \
    ${DATA_PATH}/rrd \
    ${LIBRENMS_PATH}/bootstrap/cache \
    ${LIBRENMS_PATH}/storage \
    ${LIBRENMS_PATH}/storage/framework/*

  echo "Waiting database..."
  waitdb_timeout=30
  counter=1
  while ! ${dbcmd} -e "show databases;" > /dev/null 2>&1; do
      sleep 1
      counter=`expr $counter + 1`
      if [ ${counter} -gt ${waitdb_timeout} ]; then
          >&2 echo "ERROR: Failed to connect to database on $DB_HOST"
          exit 1
      fi;
  done
  echo "Database up!"

  counttables=$(echo 'SHOW TABLES' | ${dbcmd} "$DB_NAME" | wc -l)

  echo "Updating database schema..."
  runas_librenms "php build-base.php"

  if [ "${counttables}" -eq "0" ]; then
    echo "Creating admin user..."
    runas_librenms "php adduser.php librenms librenms 10 librenms@librenms.docker"
  fi
fi

exec "$@"
