FROM php:7.0-fpm

RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://archive.debian.org/debian-security|' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until
    
RUN set -ex; \
	\
	apt-get update && \
	apt-get install -y --no-install-recommends \
	git \
	libjpeg-dev \
	libpng-dev \
	ssh \
	libxml2-dev && \
	apt-get clean && rm -rf /var/lib/apt/lists/*
	; \
	cd /root; \
	apt-get autoremove -y; \
	rm -rf /var/lib/apt/lists/*; \
	apt-get clean; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install pdo pdo_mysql mbstring tokenizer xml gd mysqli opcache soap sockets shmop zip php-redis

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
        && apt update \
        && apt install -y nodejs
RUN npm install -g npm

COPY config/php.ini /usr/local/etc/php/php.ini
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["sh","/docker-entrypoint.sh"]
CMD ["php-fpm"]
