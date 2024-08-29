FROM ghcr.io/phpstan/phpstan:latest-php8.2

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions intl soap

RUN composer global require sidz/phpstan-rules 

ENV REVIEWDOG_VERSION=v0.9.17

RUN apk --no-cache add git
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/

COPY .github/phpstan.neon /config/phpstan.neon
COPY .github/phpstan.dist.neon /config/phpstan.dist.neon

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

