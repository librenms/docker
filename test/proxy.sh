#!/bin/sh
# Run in a disposable LibreNMS image with this script mounted at /proxy-test.sh:
# docker run --rm --network none --entrypoint sh IMAGE /proxy-test.sh
set -eu

cd /opt/librenms
workdir=$(mktemp -d /tmp/librenms-proxy.XXXXXX)
chmod 755 "$workdir"
mkdir -p /var/run/nginx /var/run/php-fpm

# Exercise the same cached configuration used by web requests at startup.
export APP_TRUSTED_PROXIES=127.0.0.1,192.0.2.10,2001:db8::/32
gosu librenms php artisan config:cache --no-interaction
unset APP_TRUSTED_PROXIES
expected_proxies='["127.0.0.1","192.0.2.10","2001:db8::/32"]'
cat >"$workdir/index.php" <<'PHP'
<?php
require '/opt/librenms/vendor/autoload.php';
$app = require '/opt/librenms/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$middleware = new App\Http\Middleware\TrustProxies;
$middleware->handle(Illuminate\Http\Request::capture(), function ($request) {
    header('Content-Type: application/json');
    echo json_encode([
        'worker_env' => getenv('APP_TRUSTED_PROXIES'),
        'cached_proxies' => config('trustedproxy.proxies'),
        'remote_addr' => $request->server('REMOTE_ADDR'),
        'remote_port' => $request->server('REMOTE_PORT'),
        'scheme' => $request->getScheme(),
        'client_ip' => $request->ip(),
    ]);
});
PHP

sed -e 's/@CLEAR_ENV@/yes/g' \
  -e 's/@FPM_PM_MAX_CHILDREN@/2/g' \
  -e 's/@FPM_PM_START_SERVERS@/1/g' \
  -e 's/@FPM_PM_MIN_SPARE_SERVERS@/1/g' \
  -e 's/@FPM_PM_MAX_SPARE_SERVERS@/1/g' \
  -e 's/@UPLOAD_MAX_SIZE@/16M/g' \
  -e 's/@MEMORY_LIMIT@/256M/g' \
  /tpls/etc/php84/php-fpm.d/www.conf >"$workdir/fpm.conf"
printf 'user = librenms\ngroup = librenms\nlisten.owner = librenms\nlisten.group = librenms\n' >>"$workdir/fpm.conf"
php-fpm84 -d opcache.enable=0 -y "$workdir/fpm.conf" &
fpm_pid=$!
nginx_pid=''
cleanup() {
  if [ -n "$nginx_pid" ]; then
    kill "$nginx_pid" 2>/dev/null || true
  fi
  kill "$fpm_pid" 2>/dev/null || true
}
trap cleanup EXIT

check_proxy() {
  name=$1
  real_ip_from=$2
  source_ip=$3
  forwarded=$4
  expected_scheme=$5
  expected_client=$6
  expected_log_ip=$7

  REAL_IP_FROM="$real_ip_from" /etc/s6-overlay/scripts/config-nginx
  sed -e '1i user librenms;' \
    -e 's/worker_processes auto;/worker_processes 1;/' \
    -e 's#/proc/self/fd/2 info;#/proc/self/fd/2 warn;#' \
    -e 's#include mime.types;#include /etc/nginx/mime.types;#' \
    -e 's#include fastcgi_params;#include /etc/nginx/fastcgi_params;#' \
    -e "s#root /opt/librenms/html;#root $workdir;#" \
    -e "s#access_log /proc/self/fd/1 main;#access_log $workdir/access.log main;#" \
    /etc/nginx/nginx.conf >"$workdir/nginx.conf"
  nginx -t -c "$workdir/nginx.conf"
  nginx -c "$workdir/nginx.conf" -g 'daemon off;' &
  nginx_pid=$!

  set --
  if [ "$forwarded" != no ]; then
    if [ "$forwarded" = yes ]; then
      forwarded=198.51.100.8
    fi
    set -- -H "X-Forwarded-For: $forwarded" -H 'X-Forwarded-Proto: https'
  fi
  curl --fail --silent --show-error --retry 5 --retry-connrefused \
    --interface "$source_ip" "$@" http://127.0.0.1:8000/ >"$workdir/response.json"
  # PHP variables must reach PHP without shell expansion.
  # shellcheck disable=SC2016
  php -r '
    $result = json_decode(file_get_contents($argv[1]), true, flags: JSON_THROW_ON_ERROR);
    if ($result["worker_env"] !== false
        || $result["cached_proxies"] !== json_decode($argv[5], true, flags: JSON_THROW_ON_ERROR)
        || $result["remote_addr"] !== $argv[2]
        || (int) $result["remote_port"] <= 0
        || $result["scheme"] !== $argv[3]
        || !in_array($result["client_ip"], explode(",", $argv[4]), true)) {
        fwrite(STDERR, json_encode($result) . PHP_EOL);
        exit(1);
    }
  ' "$workdir/response.json" "$source_ip" "$expected_scheme" "$expected_client" "$expected_proxies"

  kill -QUIT "$nginx_pid"
  wait "$nginx_pid"
  nginx_pid=''
  if ! grep -q "^$expected_log_ip - " "$workdir/access.log"; then
    echo "Expected Nginx client address: $expected_log_ip" >&2
    cat "$workdir/access.log" >&2
    exit 1
  fi
  : >"$workdir/access.log"
  echo "PASS: $name"
}

check_proxy explicit-log-trust-override 192.0.2.0/24 127.0.0.1 yes https 198.51.100.8 127.0.0.1
check_proxy legacy-example-default 0.0.0.0/32 127.0.0.1 yes https 198.51.100.8 198.51.100.8
check_proxy automatic-client-logging '' 127.0.0.1 yes https 198.51.100.8 198.51.100.8
check_proxy trusted-proxy-chain '' 127.0.0.1 '198.51.100.8, 192.0.2.10' https 198.51.100.8 198.51.100.8
check_proxy untrusted-peer '' 127.0.0.2 yes http 127.0.0.2 127.0.0.2
check_proxy untrusted-with-rewriting 127.0.0.0/8 127.0.0.2 yes http 127.0.0.2 198.51.100.8
check_proxy direct-without-headers '' 127.0.0.1 no http 127.0.0.1 127.0.0.1

for wildcard in '*' '**'; do
  APP_TRUSTED_PROXIES="$wildcard" gosu librenms php artisan config:cache --no-interaction
  expected_proxies="\"$wildcard\""
  check_proxy "wildcard-proxies-$wildcard" '' 127.0.0.2 yes https 198.51.100.8 127.0.0.2
  check_proxy "wildcard-proxy-chain-$wildcard" '' 127.0.0.2 '198.51.100.8, 192.0.2.10' https 192.0.2.10,198.51.100.8 127.0.0.2
  check_proxy "wildcard-log-trust-override-$wildcard" 127.0.0.0/8 127.0.0.2 yes https 198.51.100.8 198.51.100.8
done

APP_TRUSTED_PROXIES='' gosu librenms php artisan config:cache --no-interaction
expected_proxies='""'
check_proxy no-trusted-proxies '' 127.0.0.1 yes http 127.0.0.1 127.0.0.1

APP_TRUSTED_PROXIES='127.0.0.1,traefik, 127.0.0.2,bad#value,bad&value,192.0.2.10/33,2001:db8::/129,192.0.2.10/not-a-prefix' \
  gosu librenms php artisan config:cache --no-interaction
expected_proxies='["127.0.0.1","traefik"," 127.0.0.2","bad#value","bad&value","192.0.2.10/33","2001:db8::/129","192.0.2.10/not-a-prefix"]'
check_proxy invalid-proxies-untrusted-peer '' 127.0.0.2 yes http 127.0.0.2 127.0.0.2
check_proxy invalid-proxies-trusted-peer '' 127.0.0.1 yes https 198.51.100.8 198.51.100.8

APP_TRUSTED_PROXIES='127.0.0.1,private_ranges' gosu librenms php artisan config:cache --no-interaction
expected_proxies='["127.0.0.1","private_ranges"]'
check_proxy private-ranges-alias '' 127.0.0.2 yes https 198.51.100.8 198.51.100.8
