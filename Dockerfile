FROM php:8.5-fpm

# Migracao PHP 8 do geovendas-b2b: mesma receita da 7.0-fpm trocando o runtime.
# Diferencas vs 7.0-fpm: sem o hack do Debian archive (stretch); tokenizer e opcache sao compilados no
# core do 8.5 (ext-install falha); ftp nao vem na base e o codebase nao usa; gd precisa de --with-jpeg.

RUN set -ex; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        libjpeg-dev \
        libpng-dev \
        ssh \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        xml \
        gd \
        mysqli \
        soap \
        sockets \
        shmop \
        zip

COPY config/php.ini /usr/local/etc/php/php.ini
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

# Datadog APM + AppSec (auto-instrumentacao). dd-trace 1.25.0 suporta 8.5 (validado em 08/09/2026).
COPY datadog-setup.php /datadog-setup.php
RUN /usr/local/bin/php /datadog-setup.php --php-bin=all --enable-appsec

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
CMD ["php-fpm"]
