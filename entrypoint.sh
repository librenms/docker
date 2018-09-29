#!/bin/bash

function runas_librenms() {
  su - librenms -s /bin/sh -c "$1"
}

TZ=${TZ:-"UTC"}
PUID=${PUID:-1000}
PGID=${PGID:-1000}

MEMORY_LIMIT=${MEMORY_LIMIT:-"256M"}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-"16M"}
OPCACHE_MEM_SIZE=${OPCACHE_MEM_SIZE:-"128"}

MEMCACHED_PORT=${MEMCACHED_PORT:-"11211"}
RRDCACHED_PORT=${RRDCACHED_PORT:-"42217"}

LIBRENMS_POLLER_THREADS=${LIBRENMS_POLLER_THREADS:-"16"}
LIBRENMS_POLLER_INTERVAL=${LIBRENMS_POLLER_INTERVAL:-"5"}

LIBRENMS_DISTRIBUTED_POLLER_ENABLE=${LIBRENMS_DISTRIBUTED_POLLER_ENABLE:-false}
LIBRENMS_DISTRIBUTED_POLLER_NAME=${LIBRENMS_DISTRIBUTED_POLLER_NAME:-$(hostname -f)}
LIBRENMS_DISTRIBUTED_POLLER_GROUP=${LIBRENMS_DISTRIBUTED_POLLER_GROUP:-'0'}
LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST=${LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST:-"${MEMCACHED_HOST}"}
LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_PORT=${LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_PORT:-"${MEMCACHED_PORT}"}

LIBRENMS_CRON_DISCOVERY_ENABLE=${LIBRENMS_CRON_DISCOVERY_ENABLE:-true}
LIBRENMS_CRON_DAILY_ENABLE=${LIBRENMS_CRON_DAILY_ENABLE:-true}
LIBRENMS_CRON_ALERTS_ENABLE=${LIBRENMS_CRON_ALERTS_ENABLE:-true}
LIBRENMS_CRON_BILLING_ENABLE=${LIBRENMS_CRON_BILLING_ENABLE:-true}
LIBRENMS_CRON_BILLING_CALCULATE_ENABLE=${LIBRENMS_CRON_BILLING_CALCULATE_ENABLE:-true}
LIBRENMS_CRON_CHECK_SERVICES_ENABLE=${LIBRENMS_CRON_CHECK_SERVICES_ENABLE:-true}
LIBRENMS_CRON_POLLER_ENABLE=${LIBRENMS_CRON_POLLER_ENABLE:-true}

DB_PORT=${DB_PORT:-"3306"}
DB_NAME=${DB_NAME:-"librenms"}
DB_USER=${DB_USER:-"librenms"}
DB_TIMEOUT=${DB_TIMEOUT:-"30"}

MEMCACHED_PORT=${MEMCACHED_PORT:-"11211"}
RRDCACHED_PORT=${RRDCACHED_PORT:-"42217"}

# From https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh#L21-L41
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

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
file_env 'LIBRENMS_SNMP_COMMUNITY' 'librenmsdocker'
sed -i -e "s/RANDOMSTRINGGOESHERE/${LIBRENMS_SNMP_COMMUNITY}/" /etc/snmp/snmpd.conf

# Init files and folders
echo "Initializing LibreNMS files / folders..."
mkdir -p ${DATA_PATH}/config \
  ${DATA_PATH}/logs \
  ${DATA_PATH}/nagios-plugins \
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
file_env 'DB_PASSWORD'
if [ -z "$DB_PASSWORD" ]; then
  >&2 echo "ERROR: Either DB_PASSWORD or DB_PASSWORD_FILE must be defined"
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
echo "/usr/sbin/fping -6 \$@" > /usr/sbin/fping6
chmod +x /usr/sbin/fping6
cat > ${LIBRENMS_PATH}/config.d/fping.php <<EOL
<?php
\$config['fping'] = "/usr/sbin/fping";
\$config['fping6'] = "/usr/sbin/fping6";
EOL

# Config : Disable autoupdate
cat > ${LIBRENMS_PATH}/config.d/autoupdate.php <<EOL
<?php
\$config['update'] = 0;
EOL

# Config : Services
cat > ${LIBRENMS_PATH}/config.d/services.php <<EOL
<?php
\$config['show_services'] = 1;
\$config['nagios_plugins'] = "/usr/lib/nagios/plugins";
EOL

# Config : Memcached
if [ ! -z "${MEMCACHED_HOST}" ]; then
    cat > ${LIBRENMS_PATH}/config.d/memcached.php <<EOL
<?php
\$config['memcached']['enable'] = true;
\$config['memcached']['host'] = '${MEMCACHED_HOST}';
\$config['memcached']['port'] = ${MEMCACHED_PORT};
EOL
fi

# Config : RRDcached
if [ ! -z "${RRDCACHED_HOST}" ]; then
    cat > ${LIBRENMS_PATH}/config.d/rrdcached.php <<EOL
<?php
\$config['rrdcached'] = "${RRDCACHED_HOST}:${RRDCACHED_PORT}";
\$config['rrdtool_version'] = '1.7.0';
EOL
fi

# Config : Ditributed poller
if [ ! -z "${LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST}" -a ! -z "${RRDCACHED_HOST}" -a $LIBRENMS_DISTRIBUTED_POLLER_ENABLE = true ]; then
    cat > ${LIBRENMS_PATH}/config.d/distributed_poller.php <<EOL
<?php
\$config['distributed_poller'] = true;
\$config['distributed_poller_name'] = '${LIBRENMS_DISTRIBUTED_POLLER_NAME}';
\$config['distributed_poller_group'] = '${LIBRENMS_DISTRIBUTED_POLLER_GROUP}';
\$config['distributed_poller_memcached_host'] = '${LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_HOST}';
\$config['distributed_poller_memcached_port'] = ${LIBRENMS_DISTRIBUTED_POLLER_MEMCACHED_PORT};
EOL
fi

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
chmod +x ${DATA_PATH}/nagios-plugins/*

# Check additional nagios plugins
echo "Checking additional nagios plugins..."
nagios_plugins=$(ls -l ${DATA_PATH}/nagios-plugins | egrep '^-' | awk '{print $9}')
for nagios_plugin in ${nagios_plugins}; do
  if [ -f "/usr/lib/nagios/plugins/${nagios_plugin}" ]; then
    echo "  WARNING: Official Nagios plugin ${nagios_plugin} cannot be overriden"
    continue
  fi
  if [[ ${nagios_plugin} != check_* ]]; then
    echo "  WARNING: Nagios plugin filename ${nagios_plugin} invalid. It must start with 'check_'"
    continue
  fi
  echo "  Adding ${nagios_plugin} nagios plugin"
  ln -sf ${DATA_PATH}/nagios-plugins/${nagios_plugin} /usr/lib/nagios/plugins/${nagios_plugin}
done

# Sidecar cron container ?
if [ "$1" == "/usr/local/bin/cron" ]; then
  echo ">>"
  echo ">> Sidecar cron container detected"
  echo ">>"

  # Init
  if [ -z "$CRONTAB_PATH" ]; then
    >&2 echo "ERROR: CRONTAB_PATH must be defined"
    exit 1
  fi

  rm -rf ${CRONTAB_PATH}
  mkdir -m 0644 -p ${CRONTAB_PATH}
  touch ${CRONTAB_PATH}/librenms

  # Add crontab
  cat ${LIBRENMS_PATH}/librenms.nonroot.cron > ${CRONTAB_PATH}/librenms
  sed -i -e "s/ librenms //" ${CRONTAB_PATH}/librenms
  
  if [ $LIBRENMS_CRON_DISCOVERY_ENABLE != true ]; then
    sed -i "/discovery.php/d" ${CRONTAB_PATH}/librenms
  fi

  if [ $LIBRENMS_CRON_DAILY_ENABLE != true ]; then
    sed -i "/daily.sh/d" ${CRONTAB_PATH}/librenms
  fi

  if [ $LIBRENMS_CRON_ALERTS_ENABLE != true ]; then
    sed -i "/alerts.php/d" ${CRONTAB_PATH}/librenms
  fi

  if [ $LIBRENMS_CRON_BILLING_ENABLE != true ]; then
    sed -i "/poll-billing.php/d" ${CRONTAB_PATH}/librenms
  fi

  if [ $LIBRENMS_CRON_BILLING_CALCULATE_ENABLE != true ]; then
    sed -i "/billing-calculate.php/d" ${CRONTAB_PATH}/librenms
  fi

  if [ $LIBRENMS_CRON_CHECK_SERVICES_ENABLE != true ]; then
    sed -i "/check-services.php/d" ${CRONTAB_PATH}/librenms
  fi

  sed -i "/poller-wrapper.py/d" ${CRONTAB_PATH}/librenms
  if [ $LIBRENMS_CRON_POLLER_ENABLE = true ]; then
    cat >> ${CRONTAB_PATH}/librenms <<EOL
*/${LIBRENMS_POLLER_INTERVAL}  *    * * *     /opt/librenms/cronic /opt/librenms/poller-wrapper.py ${LIBRENMS_POLLER_THREADS}
EOL
  fi

  # Fix crontab perms
  echo "Fixing crontab permissions..."
  chmod -R 0644 ${CRONTAB_PATH}
elif [ "$1" == "/usr/sbin/syslog-ng" ]; then
  echo ">>"
  echo ">> Sidecar syslog-ng container detected"
  echo ">>"

  # Init
  mkdir -p ${DATA_PATH}/syslog-ng /run/syslog-ng
  chown -R librenms. ${DATA_PATH}/syslog-ng /run/syslog-ng
else
  echo "Waiting ${DB_TIMEOUT}s for database to be ready..."
  counter=1
  while ! ${dbcmd} -e "show databases;" > /dev/null 2>&1; do
      sleep 1
      counter=`expr $counter + 1`
      if [ ${counter} -gt ${DB_TIMEOUT} ]; then
          >&2 echo "ERROR: Failed to connect to database on $DB_HOST"
          exit 1
      fi;
  done
  echo "Database ready!"

  counttables=$(echo 'SHOW TABLES' | ${dbcmd} "$DB_NAME" | wc -l)

  echo "Updating database schema..."
  runas_librenms "php build-base.php"

  if [ "${counttables}" -eq "0" ]; then
    echo "Creating admin user..."
    runas_librenms "php adduser.php librenms librenms 10 librenms@librenms.docker"
  fi
fi

exec "$@"
