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

DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-librenms}
DB_USER=${DB_USER:-librenms}
DB_TIMEOUT=${DB_TIMEOUT:-60}

SIDECAR_CRON=${SIDECAR_CRON:-0}
SIDECAR_SYSLOGNG=${SIDECAR_SYSLOGNG:-0}

if [ "$SIDECAR_CRON" = "1" ] || [ "$SIDECAR_SYSLOGNG" = "1" ]; then
  exit 0
fi

file_env 'DB_PASSWORD'
if [ -z "$DB_PASSWORD" ]; then
  >&2 echo "ERROR: Either DB_PASSWORD or DB_PASSWORD_FILE must be defined"
  exit 1
fi

dbcmd="mysql -h ${DB_HOST} -P ${DB_PORT} -u "${DB_USER}" "-p${DB_PASSWORD}""
unset DB_PASSWORD

echo "Waiting ${DB_TIMEOUT}s for database to be ready..."
counter=1
while ! ${dbcmd} -e "show databases;" > /dev/null 2>&1; do
  sleep 1
  counter=$((counter + 1))
  if [ ${counter} -gt ${DB_TIMEOUT} ]; then
    >&2 echo "ERROR: Failed to connect to database on $DB_HOST"
    exit 1
  fi;
done
echo "Database ready!"
counttables=$(echo 'SHOW TABLES' | ${dbcmd} "$DB_NAME" | wc -l)

echo "Updating database schema..."
su-exec librenms:librenms php build-base.php

if [ "${counttables}" -eq "0" ]; then
  echo "Creating admin user..."
  su-exec librenms:librenms php adduser.php librenms librenms 10 librenms@librenms.docker
fi

mkdir -p /etc/services.d/nginx
cat > /etc/services.d/nginx/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
nginx -g "daemon off;"
EOL
chmod +x /etc/services.d/nginx/run

mkdir -p /etc/services.d/php-fpm
cat > /etc/services.d/php-fpm/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
php-fpm7 -F
EOL
chmod +x /etc/services.d/php-fpm/run

mkdir -p /etc/services.d/snmpd
cat > /etc/services.d/snmpd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/snmpd -f -c /etc/snmp/snmpd.conf
EOL
chmod +x /etc/services.d/snmpd/run
