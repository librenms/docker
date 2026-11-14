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
