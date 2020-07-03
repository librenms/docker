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
DB_DATABASE=${DB_DATABASE:-librenms}
DB_USERNAME=${DB_USERNAME:-librenms}
DB_TIMEOUT=${DB_TIMEOUT:-60}

SIDECAR_DISPATCHER=${SIDECAR_DISPATCHER:-0}
#LIBRENMS_SERVICE_NODE_ID=${LIBRENMS_SERVICE_NODE_ID:-dispatcher1}

LIBRENMS_SERVICE_POLLER_WORKERS=${LIBRENMS_SERVICE_POLLER_WORKERS:-24}
LIBRENMS_SERVICE_SERVICES_WORKERS=${LIBRENMS_SERVICE_SERVICES_WORKERS:-8}
LIBRENMS_SERVICE_DISCOVERY_WORKERS=${LIBRENMS_SERVICE_DISCOVERY_WORKERS:-16}

LIBRENMS_SERVICE_POLLER_FREQUENCY=${LIBRENMS_SERVICE_POLLER_FREQUENCY:-300}
LIBRENMS_SERVICE_SERVICES_FREQUENCY=${LIBRENMS_SERVICE_SERVICES_FREQUENCY:-300}
LIBRENMS_SERVICE_DISCOVERY_FREQUENCY=${LIBRENMS_SERVICE_DISCOVERY_FREQUENCY:-21600}
LIBRENMS_SERVICE_BILLING_FREQUENCY=${LIBRENMS_SERVICE_BILLING_FREQUENCY:-300}
LIBRENMS_SERVICE_BILLING_CALCULATE_FREQUENCY=${LIBRENMS_SERVICE_BILLING_CALCULATE_FREQUENCY:-60}
LIBRENMS_SERVICE_POLLER_DOWN_RETRY=${LIBRENMS_SERVICE_POLLER_DOWN_RETRY:-60}
LIBRENMS_SERVICE_LOGLEVEL=${LIBRENMS_SERVICE_LOGLEVEL:-INFO}
LIBRENMS_SERVICE_UPDATE_FREQUENCY=${LIBRENMS_SERVICE_UPDATE_FREQUENCY:-86400}

LIBRENMS_SERVICE_PING_ENABLED=${LIBRENMS_SERVICE_PING_ENABLED:-false}
LIBRENMS_SERVICE_WATCHDOG_ENABLED=${LIBRENMS_SERVICE_WATCHDOG_ENABLED:-false}

REDIS_HOST=${REDIS_HOST:-localhost}
REDIS_PORT=${REDIS_PORT:-6379}
file_env 'REDIS_PASSWORD'
REDIS_DB=${REDIS_DB:-0}

# Continue only if sidecar dispatcher container
if [ "$SIDECAR_DISPATCHER" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar dispatcher container detected"
echo ">>"

file_env 'DB_PASSWORD'
if [ -z "$DB_PASSWORD" ]; then
  >&2 echo "ERROR: Either DB_PASSWORD or DB_PASSWORD_FILE must be defined"
  exit 1
fi

dbcmd="mysql -h ${DB_HOST} -P ${DB_PORT} -u "${DB_USERNAME}" "-p${DB_PASSWORD}""
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

# Node ID
if [ ! -f "/data/.env" ]; then
  >&2 echo "ERROR: /data/.env file does not exist. Please run the main container first"
  exit 1
fi
cat "/data/.env" >> "${LIBRENMS_PATH}/.env"
if [ -n "$LIBRENMS_SERVICE_NODE_ID" ]; then
  echo "NODE_ID: $LIBRENMS_SERVICE_NODE_ID"
  sed -i "s|^NODE_ID=.*|NODE_ID=$LIBRENMS_SERVICE_NODE_ID|g" "${LIBRENMS_PATH}/.env"
fi

# Configuration
cat > ${LIBRENMS_PATH}/config.d/dispatcher.php <<EOL
<?php
\$config['service_poller_workers']              = ${LIBRENMS_SERVICE_POLLER_WORKERS};
\$config['service_services_workers']            = ${LIBRENMS_SERVICE_SERVICES_WORKERS};
\$config['service_discovery_workers']           = ${LIBRENMS_SERVICE_DISCOVERY_WORKERS};

\$config['service_poller_frequency']            = ${LIBRENMS_SERVICE_POLLER_FREQUENCY};
\$config['service_services_frequency']          = ${LIBRENMS_SERVICE_SERVICES_FREQUENCY};
\$config['service_discovery_frequency']         = ${LIBRENMS_SERVICE_DISCOVERY_FREQUENCY};
\$config['service_billing_frequency']           = ${LIBRENMS_SERVICE_BILLING_FREQUENCY};
\$config['service_billing_calculate_frequency'] = ${LIBRENMS_SERVICE_BILLING_CALCULATE_FREQUENCY};
\$config['service_poller_down_retry']           = ${LIBRENMS_SERVICE_POLLER_DOWN_RETRY};
\$config['service_loglevel']                    = '${LIBRENMS_SERVICE_LOGLEVEL}';
\$config['service_update_frequency']            = ${LIBRENMS_SERVICE_UPDATE_FREQUENCY};

\$config['service_ping_enabled']                = ${LIBRENMS_SERVICE_PING_ENABLED};
\$config['service_watchdog_enabled']            = ${LIBRENMS_SERVICE_WATCHDOG_ENABLED};
EOL

# Create service
mkdir -p /etc/services.d/dispatcher
cat > /etc/services.d/dispatcher/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
/opt/librenms/librenms-service.py -v
EOL
chmod +x /etc/services.d/dispatcher/run
