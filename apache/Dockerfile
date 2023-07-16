FROM php:8.0-apache

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV APACHE_DOCUMENT_ROOT /var/www/html/public_html

# Change the default document root in Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get update && apt-get install --no-install-recommends -y \
  git \
  gnupg \
  imagemagick \
  libc-client-dev\
  libcurl4-openssl-dev \
  libkrb5-dev \
  libldap-dev \
  libmagickwand-dev \
  libpng-dev \
  libxml2-dev \
  libzip-dev  \
  lsb-release \
  zlib1g-dev \
  # Install Node.js with NodeSource
  # https://github.com/docker-library/official-images/tree/5369615f65d4fee661f3057e5aa8248fae46f5bb#image-build
  && key="9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280" \
  && keyring="/etc/apt/trusted.gpg.d/node.gpg.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys $key \
  && gpg --batch --armor --export $key > $keyring \
  && chmod a+r $keyring \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && apt-key list > /dev/null \
  && DISTRO="$(lsb_release -s -c)" \
  && echo "deb [signed-by=$keyring] https://deb.nodesource.com/node_18.x $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list \
  && echo "deb-src [signed-by=$keyring] https://deb.nodesource.com/node_18.x $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y nodejs --no-install-recommends \
  && npm install --global yarn@1 \
  # Add PHP extensions requered by YetiForceCRM
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j8 imap pdo_mysql curl gd xml zip soap iconv intl bcmath sockets exif ldap opcache \
  && apt-get clean

WORKDIR /opt
RUN php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/70527179915d55b3811bebaec55926afd331091b/web/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer
# docker-php-ext-* does not work with the imagick extension; it must be compiled manually
RUN curl -sL https://github.com/Imagick/imagick/archive/refs/tags/3.7.0.tar.gz -o imagick.tar.gz \
  && tar -xzf imagick.tar.gz \
  && cd imagick-3.7.0 \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && docker-php-ext-enable imagick \
  && cd .. \
  && rm -rf imagick.tar.gz imagick-3.7.0

COPY --chown=www-data:www-data --chmod=644 ./YetiForceCRM /var/www/html

WORKDIR /var/www/html

RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn rm .git && yarn install --modules-folder "./public_html/libraries" --ignore-optional --production=true
WORKDIR /var/www/html/public_html/src
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --ignore-optional --production=true

WORKDIR /var/www/html

RUN --mount=type=cache,target=/root/.composer/cache composer --no-interaction install --no-dev

WORKDIR /var/www/html

RUN install -owww-data -gwww-data -m755 -d config/Modules && find . -type d -exec chown www-data:www-data -- {} \+ && find . -type d -exec chmod 755 -- {} \+

COPY ./YetiForceCRM/tests/setup/php/prod.ini /usr/local/etc/php/conf.d
COPY ./php/docker-config.ini /usr/local/etc/php/conf.d
COPY ./apache/cron-runner.sh ./apache/entrypoint.sh /

SHELL ["/bin/sh", "-c"]
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["apache2-foreground"]

EXPOSE 80
