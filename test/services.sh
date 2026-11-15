#!/bin/sh
set -eu

services=""
if [ "${SIDECAR_DISPATCHER:-0}" = "1" ]; then
  services="$services dispatcher"
fi
if [ "${SIDECAR_SYSLOGNG:-0}" = "1" ]; then
  services="$services syslogng"
fi
if [ "${SIDECAR_SNMPTRAPD:-0}" = "1" ]; then
  services="$services snmptrapd"
fi
if [ -z "$services" ]; then
  services="nginx php-fpm snmpd cron"
fi

for service in $services; do
  s6-svwait -u -t 120000 "/run/service/$service"
  test "$(s6-svstat -o up,wantedup /run/service/"$service")" = "true true"
done
for service in nginx php-fpm snmpd cron dispatcher syslogng snmptrapd; do
  case " $services " in
    *" $service "*) ;;
    *) test "$(s6-svstat -o up,wantedup /run/service/"$service")" = "false false" ;;
  esac
done
for service in $services; do
  case "$service" in
    nginx|php-fpm|dispatcher)
      pid=$(s6-svstat -o pid /run/service/"$service")
      grep -Eq "^Uid:[[:space:]]+${PUID}[[:space:]]" "/proc/${pid}/status"
      grep -Eq "^Gid:[[:space:]]+${PGID}[[:space:]]" "/proc/${pid}/status"
      ;;
  esac
done

healthcheck
if [ "${SIDECAR_DISPATCHER:-0}" = "1" ]; then
  # Freeze the dispatcher so it cannot refresh the stale heartbeat during the check.
  s6-svc -p /run/service/dispatcher
  touch -d '@1' /opt/librenms/storage/dispatcher-health
  if healthcheck; then
    s6-svc -c /run/service/dispatcher
    echo >&2 "Healthcheck accepted a stale dispatcher heartbeat"
    exit 1
  fi
  s6-svc -c /run/service/dispatcher
fi

for service in $services; do
  s6-svc -d "/run/service/$service"
  s6-svwait -d -t 120000 "/run/service/$service"
  if healthcheck; then
    s6-svc -u "/run/service/$service"
    echo >&2 "Healthcheck accepted stopped service $service"
    exit 1
  fi
  s6-svc -u "/run/service/$service"
  s6-svwait -u -t 10000 "/run/service/$service"
done
timeout 30 sh -c 'until healthcheck; do sleep 1; done'
