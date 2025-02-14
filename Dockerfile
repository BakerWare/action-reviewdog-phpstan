FROM ghcr.io/phpstan/phpstan:1-php8.2

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions intl soap

RUN composer global require phpstan/phpstan-symfony sidz/phpstan-rules phpunit/phpunit ^9

ENV REVIEWDOG_VERSION=v0.20.3

RUN apk --no-cache add git
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/v0.20.3/install.sh | sh -s -- -b /usr/local/bin/

COPY .github/phpstan.dist.neon /config/phpstan.dist.neon

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

