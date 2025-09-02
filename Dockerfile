FROM php:7.0-fpm

# Ajustar repositórios para os arquivos arquivados do Debian Stretch
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    sed -i '/security/d' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until



RUN curl -fsSL https://deb.debian.org/debian-archive/pool/updates/main/d/debconf/debconf_1.5.63_all.deb -o /tmp/debconf.deb && \
    dpkg -i /tmp/debconf.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
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

# **Instalar a versão correta da extensão Redis via PECL**
RUN pecl install redis-4.3.0 && docker-php-ext-enable redis

# Instalar Node.js e npm
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
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
