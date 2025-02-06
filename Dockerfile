FROM php:7.3-fpm

# Ajuste para usar os repositórios arquivados do Debian Stretch
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://archive.debian.org/debian-security|' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Instalação de dependências e extensões PHP
RUN set -ex; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        libjpeg-dev \
        libpng-dev \
        ssh \
        libxml2-dev && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install \
        pdo \
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
        zip \
        redis && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalação do Node.js e npm
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g npm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar configuração personalizada do PHP
COPY config/php.ini /usr/local/etc/php/php.ini

# Adicionar e configurar o script de entrada
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Configuração do ponto de entrada e comando padrão
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
CMD ["php-fpm"]
