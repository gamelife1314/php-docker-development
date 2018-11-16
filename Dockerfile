FROM php:7.2.12-fpm-alpine3.8

RUN sed -i s,http://dl-cdn.alpinelinux.org,http://mirrors.aliyun.com,g  /etc/apk/repositories \
    && apk update 

# build base 
RUN apk add --virtual .build-deps build-base automake autoconf m4

# install composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.7.3

RUN curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://raw.githubusercontent.com/composer/getcomposer.org/b107d959a5924af895807021fcef4ffec5a76aa9/web/installer \
 && php -r " \
    \$signature = '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -rf /tmp/* /tmp/.htaccess

 # imagick extension
 RUN apk add imagemagick-dev \
    && wget -O /tmp/imagick-3.4.3.tgz http://pecl.php.net/get/imagick-3.4.3.tgz \
    && pecl install /tmp/imagick-3.4.3.tgz  \
    && docker-php-ext-enable imagick \
    && rm -f /tmp/imagick-3.4.3.tgz

# xdebug extension
RUN wget -O /tmp/xdebug-2.6.0.tgz http://pecl.php.net/get/xdebug-2.6.0.tgz \
    && pecl install /tmp/xdebug-2.6.0.tgz  \
    && docker-php-ext-enable xdebug \
    && rm -f /tmp/xdebug-2.6.0.tgz

# gd extension
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
  && docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
  && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)  \
  && docker-php-ext-install -j${NPROC} gd  \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# core extension
RUN apk add zlib-dev pcre-dev imap-dev 
RUN docker-php-ext-install pdo pdo_mysql mysqli zip imap 

RUN apk del .build-deps

# nginx supervisor
RUN apk add nginx supervisor

COPY ./docker/supervisor.ini  /etc/supervisor.d/supervisor.ini
COPY ./docker/site.conf /etc/nginx/conf.d/default.conf
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# ports
EXPOSE 80
WORKDIR /var/www

COPY ./index.php /var/www/index.php

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]