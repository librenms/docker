<?php

require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
(new Illuminate\Foundation\Bootstrap\LoadConfiguration)->bootstrap($app);
$proxies = $app['config']->get('trustedproxy.proxies');

// Leave wildcard handling to LibreNMS and log the connection address in Nginx.
if ($proxies === '*' || $proxies === '**') {
    return;
}

echo 'real_ip_recursive on; ';
Symfony\Component\HttpFoundation\Request::setTrustedProxies((array) $proxies, 0);
$proxies = Symfony\Component\HttpFoundation\Request::getTrustedProxies();
foreach ($proxies as $proxy) {
    if ($proxy !== '') {
        [$address, $prefix] = array_pad(explode('/', $proxy, 2), 2, null);
        if (($prefix !== null && !preg_match('/^(0|[1-9][0-9]*)$/D', $prefix))
            || !Symfony\Component\HttpFoundation\IpUtils::checkIp($address, $proxy)) {
            fwrite(STDERR, "Ignoring invalid trusted proxy address: $proxy\n");
            continue;
        }
        echo "set_real_ip_from $proxy; ";
    }
}
