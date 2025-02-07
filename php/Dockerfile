ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm-alpine as dev

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_ENABLED="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

ARG PHP_EXTENSIONS
ARG PHP_ENVIRONMENT

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ${PHP_EXTENSIONS}

COPY php/${PHP_ENVIRONMENT}/conf.d/* $PHP_INI_DIR/conf.d/
COPY php/${PHP_ENVIRONMENT}/php-fpm.d/* $PHP_INI_DIR/../php-fpm.d/

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_ENABLED="0" 

ARG PHP_DEV_COMPOSER_PACKAGES

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" && \
    install-php-extensions @composer xdebug && \
    adduser -u 1000 -h /home/app -s /bin/bash -D app && \
    mkdir /home/app/.composer && \
    chown -R 1000:1000 /home/app/.composer && \
    touch /var/log/xdebug.log && \
    chown -R 1000:1000 /var/log/xdebug.log && \
    PATH=$PATH:/usr/src/apps/vendor/bin:bin && \
    apk add git patch

COPY php/auth.json /home/app/.composer/auth.json
COPY php/dev/composer.config.json /home/app/.composer/config.json

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/v0.20.1/install.sh | sh -s -- -b /usr/local/bin/

COPY .github/phpstan.dist.neon /config/phpstan.dist.neon

WORKDIR /usr/src/app
USER app

RUN [ -z "${PHP_DEV_COMPOSER_PACKAGES}" ] || composer -n global require $PHP_DEV_COMPOSER_PACKAGES
ENV PATH="${PATH}:/home/app/.composer/vendor/bin"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
