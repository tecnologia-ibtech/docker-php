FROM php:8.5-fpm

# ibtech/php:8.5-dev — imagem de DESENVOLVIMENTO da migracao PHP 8 do geovendas-b2b.
#
# Mesma receita da 8.5-fpm (producao) menos o Datadog, mais:
#   - xdebug 3 (desligado por padrao; XDEBUG_MODE=debug liga — o setup-b2b faz isso
#     com IBTECH_XDEBUG=1). Sem Node dentro do container: o build do b2b roda no host.
#   - php.ini de dev (display_errors On, E_ALL) — o setup-b2b monta ./config_win por
#     cima de /usr/local/etc/php, entao no b2b local quem manda e o php.ini do repo.
# phpredis igual a producao: o motor de galeria em Redis precisa da extensao nos dois.

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

# tokenizer e opcache sao core no 8.5 (nao existem como ext-install)
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

# phpredis pinado como na 8.5-fpm (6.3.0 = ultima do PECL, compila no 8.5)
RUN pecl install redis-6.3.0 && docker-php-ext-enable redis

# xdebug 3: instalado e carregado, mas em xdebug.mode=off (custo zero). Liga por env:
#   XDEBUG_MODE=debug  (e, se precisar, XDEBUG_CONFIG="client_host=... client_port=...")
RUN pecl install xdebug && docker-php-ext-enable xdebug
COPY config/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini

COPY config/php.ini /usr/local/etc/php/php.ini

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
CMD ["php-fpm"]
