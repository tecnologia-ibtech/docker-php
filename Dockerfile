FROM php:7.0-fpm

# Ajustar repositórios para os arquivos arquivados do Debian Stretch
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    sed -i '/security/d' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Instalar dependências necessárias
RUN set -ex; \
    apt-get update && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
        git \
        libjpeg-dev \
        libpng-dev \
        ssh \
        libxml2-dev \
        libzip-dev \
        unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar e instalar extensões PHP
RUN docker-php-ext-configure gd \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        tokenizer \
        xml \
        gd \
        mysqli \
        opcache \
        soap \
        sockets \
        shmop \
        zip

# Copiar configuração personalizada do PHP
COPY config/php.ini /usr/local/etc/php/php.ini

# Adicionar e configurar o script de entrada
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

COPY datadog-setup.php /datadog-setup.php
RUN /usr/local/bin/php /datadog-setup.php --php-bin=all --enable-appsec

# Configuração do ponto de entrada e comando padrão
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
CMD ["php-fpm"]
