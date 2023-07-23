FROM php:8.0-fpm AS php-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install --no-install-recommends -y \
  imagemagick \
  libc-client-dev \
  libcurl4-openssl-dev \
  libkrb5-dev \
  libldap-dev \
  libmagickwand-dev \
  libpng-dev \
  libxml2-dev \
  libzip-dev  \
  unixodbc-dev \
  zlib1g-dev \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j8 imap pdo_mysql curl gd xml zip soap iconv intl bcmath sockets exif ldap opcache \
  && apt-get clean \
  && printf "\n" | pecl install imagick \
  && docker-php-ext-enable imagick \
  && printf "\n" | pecl install apcu \
  && docker-php-ext-enable apcu \
  && pecl install pdo_sqlsrv \
  && docker-php-ext-enable pdo_sqlsrv \
  && pecl cache-clear \
  && rm -rf /tmp/pear

FROM node:18-alpine AS build-yarn

RUN apk add --no-cache git

COPY ./YetiForceCRM /opt/YetiForceCRM
WORKDIR /opt/YetiForceCRM
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn rm .git && yarn install --modules-folder "./public_html/libraries" --ignore-optional --production=true
WORKDIR /opt/YetiForceCRM/public_html/src
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --ignore-optional --production=true


FROM php-base AS build-composer

RUN php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/70527179915d55b3811bebaec55926afd331091b/web/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer

COPY --from=build-yarn /opt/YetiForceCRM /opt/YetiForceCRM
WORKDIR /opt/YetiForceCRM
RUN --mount=type=cache,target=/root/.composer/cache composer --no-interaction install --no-dev

FROM php-base AS php-prod

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./YetiForceCRM/tests/setup/php/prod.ini /usr/local/etc/php/conf.d
COPY ./php/docker-config.ini /usr/local/etc/php/conf.d
COPY ./php/fpm.conf /usr/local/etc/php-fpm.d/zzz-docker.conf

WORKDIR /var/www/html
COPY --from=build-composer --chown=www-data:www-data --chmod=644 /opt/YetiForceCRM/ /var/www/html
RUN install -owww-data -gwww-data -m755 -d config/Modules && find . -type d -exec chown www-data:www-data -- {} \+ && find . -type d -exec chmod 755 -- {} \+

FROM php-base AS php-dev

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./YetiForceCRM/tests/setup/php/dev.ini /usr/local/etc/php/conf.d
COPY ./php/docker-config.ini /usr/local/etc/php/conf.d
COPY ./php/fpm.conf /usr/local/etc/php-fpm.d/zzz-docker.conf