# syntax=docker/dockerfile:1

ARG LIBRENMS_VERSION="23.11.0"
ARG WEATHERMAP_PLUGIN_COMMIT="0b2ff643b65ee4948e4f74bb5cad5babdaddef27"
ARG ALPINE_VERSION="3.17"

FROM crazymax/yasu:latest AS yasu
FROM crazymax/alpine-s6:${ALPINE_VERSION}-2.2.0.3
COPY --from=yasu / /
RUN apk --update --no-cache add \
    busybox-extras \
    acl \
    bash \
    bind-tools \
    binutils \
    ca-certificates \
    coreutils \
    curl \
    file \
    fping \
    git \
    graphviz \
    imagemagick \
    ipmitool \
    iputils \
    libcap-utils \
    mariadb-client \
    monitoring-plugins \
    mtr \
    net-snmp \
    net-snmp-tools \
    nginx \
    nmap \
    openssl \
    openssh-client \
    perl \
    php81 \
    php81-cli \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-fileinfo \
    php81-fpm \
    php81-gd \
    php81-gmp \
    php81-json \
    php81-ldap \
    php81-mbstring \
    php81-mysqlnd \
    php81-opcache \
    php81-openssl \
    php81-pdo \
    php81-pdo_mysql \
    php81-pecl-memcached \
    php81-pear \
    php81-phar \
    php81-posix \
    php81-session \
    php81-simplexml \
    php81-snmp \
    php81-sockets \
    php81-tokenizer \
    php81-xml \
    php81-zip \
    python3 \
    py3-pip \
    rrdtool \
    runit \
    sed \
    shadow \
    syslog-ng=3.38.1-r0 \
    ttf-dejavu \
    tzdata \
    util-linux \
    whois \
  && apk --update --no-cache add -t build-dependencies \
    build-base \
    make \
    mariadb-dev \
    musl-dev \
    python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install python-memcached mysqlclient --upgrade \
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && apk del build-dependencies \
  && rm -rf /var/www/* /tmp/* \
  && echo "/usr/sbin/fping -6 \$@" > /usr/sbin/fping6 \
  && chmod +x /usr/sbin/fping6 \
  && chmod u+s,g+s \
    /bin/ping \
    /bin/ping6 \
    /usr/lib/monitoring-plugins/check_icmp \
  && setcap cap_net_raw+ep /usr/bin/nmap \
  && setcap cap_net_raw+ep /usr/sbin/fping \
  && setcap cap_net_raw+ep /usr/sbin/fping6 \
  && setcap cap_net_raw+ep /usr/lib/monitoring-plugins/check_icmp \
  && setcap cap_net_raw+ep /usr/lib/monitoring-plugins/check_ping

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  LIBRENMS_PATH="/opt/librenms" \
  LIBRENMS_DOCKER="1" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

RUN addgroup -g ${PGID} librenms \
  && adduser -D -h /home/librenms -u ${PUID} -G librenms -s /bin/sh -D librenms \
  && curl -sSLk -q https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro -o /usr/bin/distro \
  && chmod +x /usr/bin/distro

WORKDIR ${LIBRENMS_PATH}
ARG LIBRENMS_VERSION
ARG WEATHERMAP_PLUGIN_COMMIT
RUN apk --update --no-cache add -t build-dependencies \
    build-base \
    linux-headers \
    musl-dev \
    python3-dev \
  && echo "Installing LibreNMS https://github.com/librenms/librenms.git#${LIBRENMS_VERSION}..." \
  && git clone --depth=1 --branch ${LIBRENMS_VERSION} https://github.com/librenms/librenms.git . \
  && pip3 install --ignore-installed -r requirements.txt --upgrade \
  && COMPOSER_CACHE_DIR="/tmp" composer install --no-dev --no-interaction --no-ansi \
  && mkdir config.d \
  && cp config.php.default config.php \
  && cp snmpd.conf.example /etc/snmp/snmpd.conf \
  && sed -i '/runningUser/d' lnms \
  && echo "foreach (glob(\"/data/config/*.php\") as \$filename) include \$filename;" >> config.php \
  && echo "foreach (glob(\"${LIBRENMS_PATH}/config.d/*.php\") as \$filename) include \$filename;" >> config.php \
  && ( \
    git clone https://github.com/librenms-plugins/Weathermap.git ./html/plugins/Weathermap \
    && cd ./html/plugins/Weathermap \
    && git reset --hard $WEATHERMAP_PLUGIN_COMMIT \
  ) \
  && chown -R nobody:nogroup ${LIBRENMS_PATH} \
  && apk del build-dependencies \
  && rm -rf .git \
    html/plugins/Test \
    html/plugins/Weathermap/.git \
    html/plugins/Weathermap/configs \
    doc/ \
    tests/ \
    /tmp/*

COPY rootfs /

EXPOSE 8000 514 514/udp 162 162/udp
VOLUME [ "/data" ]

ENTRYPOINT [ "/init" ]
