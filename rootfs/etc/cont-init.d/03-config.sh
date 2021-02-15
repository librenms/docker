#!/usr/bin/with-contenv bash

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

TZ=${TZ:-UTC}

MEMORY_LIMIT=${MEMORY_LIMIT:-256M}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-16M}
CLEAR_ENV=${CLEAR_ENV:-yes}
OPCACHE_MEM_SIZE=${OPCACHE_MEM_SIZE:-128}
LISTEN_IPV6=${LISTEN_IPV6:-true}
REAL_IP_FROM=${REAL_IP_FROM:-"0.0.0.0/32"}
REAL_IP_HEADER=${REAL_IP_HEADER:-"X-Forwarded-For"}
LOG_IP_VAR=${LOG_IP_VAR:-remote_addr}

MEMCACHED_PORT=${MEMCACHED_PORT:-11211}

DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-librenms}
DB_USER=${DB_USER:-librenms}
DB_TIMEOUT=${DB_TIMEOUT:-30}

LIBRENMS_BASE_URL=${LIBRENMS_BASE_URL:-/}

# Timezone
echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# PHP
echo "Setting PHP-FPM configuration..."
sed -e "s/@MEMORY_LIMIT@/$MEMORY_LIMIT/g" \
  -e "s/@UPLOAD_MAX_SIZE@/$UPLOAD_MAX_SIZE/g" \
  -e "s/@CLEAR_ENV@/$CLEAR_ENV/g" \
  /tpls/etc/php7/php-fpm.d/www.conf > /etc/php7/php-fpm.d/www.conf

echo "Setting PHP INI configuration..."
sed -i "s|memory_limit.*|memory_limit = ${MEMORY_LIMIT}|g" /etc/php7/php.ini
sed -i "s|;date\.timezone.*|date\.timezone = ${TZ}|g" /etc/php7/php.ini

# OpCache
echo "Setting OpCache configuration..."
sed -e "s/@OPCACHE_MEM_SIZE@/$OPCACHE_MEM_SIZE/g" \
  /tpls/etc/php7/conf.d/opcache.ini > /etc/php7/conf.d/opcache.ini

# Nginx
echo "Setting Nginx configuration..."
sed -e "s#@UPLOAD_MAX_SIZE@#$UPLOAD_MAX_SIZE#g" \
  -e "s#@REAL_IP_FROM@#$REAL_IP_FROM#g" \
  -e "s#@REAL_IP_HEADER@#$REAL_IP_HEADER#g" \
  -e "s#@LOG_IP_VAR@#$LOG_IP_VAR#g" \
  /tpls/etc/nginx/nginx.conf > /etc/nginx/nginx.conf

if [ "$LISTEN_IPV6" != "true" ]; then
  sed -e '/listen \[::\]:/d' -i /etc/nginx/nginx.conf
fi

# SNMP
echo "Updating SNMP community..."
file_env 'LIBRENMS_SNMP_COMMUNITY' 'librenmsdocker'
sed -i -e "s/RANDOMSTRINGGOESHERE/${LIBRENMS_SNMP_COMMUNITY}/" /etc/snmp/snmpd.conf

# Init files and folders
echo "Initializing LibreNMS files / folders..."
mkdir -p /data/config /data/logs /data/monitoring-plugins /data/rrd /data/weathermap /data/alert-templates
ln -sf /data/weathermap ${LIBRENMS_PATH}/html/plugins/Weathermap/configs
touch /data/logs/librenms.log
rm -rf ${LIBRENMS_PATH}/logs
rm -f ${LIBRENMS_PATH}/config.d/*

echo "Setting LibreNMS configuration..."

# Env file
if [ -z "$DB_HOST" ]; then
  >&2 echo "ERROR: DB_HOST must be defined"
  exit 1
fi
file_env 'DB_PASSWORD'
if [ -z "$DB_PASSWORD" ]; then
  >&2 echo "ERROR: Either DB_PASSWORD or DB_PASSWORD_FILE must be defined"
  exit 1
fi
cat > ${LIBRENMS_PATH}/.env <<EOL
APP_URL=${LIBRENMS_BASE_URL}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
EOL

# Config : Directories
  cat > ${LIBRENMS_PATH}/config.d/directories.php <<EOL
<?php
\$config['install_dir'] = '${LIBRENMS_PATH}';
\$config['log_dir'] = '/data/logs';
\$config['rrd_dir'] = '/data/rrd';
EOL
ln -sf /data/logs ${LIBRENMS_PATH}/logs

# Config : Server
  cat > ${LIBRENMS_PATH}/config.d/server.php <<EOL
<?php
\$config['own_hostname'] = '$(hostname)';
\$config['base_url'] = '${LIBRENMS_BASE_URL}';
EOL

# Config : User
cat > ${LIBRENMS_PATH}/config.d/user.php <<EOL
<?php
\$config['user'] = "librenms";
\$config['group'] = "librenms";
EOL

# Config : Fping
cat > ${LIBRENMS_PATH}/config.d/fping.php <<EOL
<?php
\$config['fping'] = "/usr/sbin/fping";
\$config['fping6'] = "/usr/sbin/fping6";
EOL

# Config : ipmitool
cat > ${LIBRENMS_PATH}/config.d/ipmitool.php <<EOL
<?php
\$config['ipmitool'] = "/usr/sbin/ipmitool";
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
\$config['nagios_plugins'] = "/usr/lib/monitoring-plugins";
EOL

# Config : Memcached
if [ -n "${MEMCACHED_HOST}" ]; then
    cat > ${LIBRENMS_PATH}/config.d/memcached.php <<EOL
<?php
\$config['memcached']['enable'] = true;
\$config['memcached']['host'] = '${MEMCACHED_HOST}';
\$config['memcached']['port'] = ${MEMCACHED_PORT};
EOL
fi

# Config : RRDcached
if [ -n "${RRDCACHED_SERVER}" ]; then
    cat > ${LIBRENMS_PATH}/config.d/rrdcached.php <<EOL
<?php
\$config['rrdcached'] = "${RRDCACHED_SERVER}";
\$config['rrdtool_version'] = "1.7.2";
EOL
fi

# Config : Dispatcher
cat > ${LIBRENMS_PATH}/config.d/dispatcher.php <<EOL
<?php
\$config['service_update_enabled'] = false;
\$config['service_watchdog_enabled'] = false;
EOL

# Fix perms
echo "Fixing perms..."
chown librenms. /data/config /data/monitoring-plugins /data/rrd /data/weathermap /data/alert-templates
chown -R librenms. /data/logs ${LIBRENMS_PATH}/config.d ${LIBRENMS_PATH}/bootstrap ${LIBRENMS_PATH}/logs ${LIBRENMS_PATH}/storage
chmod ug+rw /data/logs /data/rrd ${LIBRENMS_PATH}/bootstrap/cache ${LIBRENMS_PATH}/storage ${LIBRENMS_PATH}/storage/framework/*

# Check additional Monitoring plugins
echo "Checking additional Monitoring plugins..."
mon_plugins=$(ls -l /data/monitoring-plugins | egrep '^-' | awk '{print $9}')
for mon_plugin in ${mon_plugins}; do
  if [ -f "/usr/lib/monitoring-plugins/${mon_plugin}" ]; then
    echo "  WARNING: Official Monitoring plugin ${mon_plugin} cannot be overriden. Skipping..."
    continue
  fi
  if [[ ${mon_plugin} != check_* ]]; then
    echo "  WARNING: Monitoring plugin filename ${mon_plugin} invalid. It must start with 'check_'. Skipping..."
    continue
  fi
  if [[ ! -x "/data/monitoring-plugins/${mon_plugin}" ]]; then
    echo "  WARNING: Monitoring plugin file ${mon_plugin} has to be executable. Skipping..."
    continue
  fi
  echo "  Adding ${mon_plugin} Monitoring plugin"
  ln -sf /data/monitoring-plugins/${mon_plugin} /usr/lib/monitoring-plugins/${mon_plugin}
done

# Check alert templates
echo "Checking alert templates..."
templates=$(ls -l /data/alert-templates | egrep '^-' | awk '{print $9}')
for template in ${templates}; do
  if [ -f "${LIBRENMS_PATH}/resources/views/alerts/templates/${template}" ]; then
    echo "  WARNING: Default alert template ${template} cannot be overriden. Skipping..."
    continue
  fi
  if [[ ${template} != *.php ]]; then
    echo "  WARNING: Alert template filename ${template} invalid. It must end with '.php'. Skipping..."
    continue
  fi
  echo "  Adding ${template} alert template"
  ln -sf /data/alert-templates/${template} ${LIBRENMS_PATH}/resources/views/alerts/templates/${template}
done
