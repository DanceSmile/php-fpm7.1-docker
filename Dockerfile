FROM php:7.1-fpm

RUN apt-get update && apt-get install -y \
        libgearman-dev \
        libmemcached-dev \
        zip \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql mcrypt mbstring  json pdo_mysql mysqli  iconv  pcntl  posix opcache \
    && echo "opcache.enable_cli=0" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && pecl install redis-4.0.1 && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
    #&& pecl install uuid &&  echo "extension=uuid.so" > /usr/local/etc/php/conf.d/uuid.ini \
    && pecl install channel://pecl.php.net/mongodb-1.5.3 && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini \
    && rm -rf /var/lib/apt/lists/* 

COPY etc/gearman-2.0.3.tar.gz  /tmp/

RUN docker-php-ext-configure intl
RUN docker-php-ext-install zip  mcrypt bcmath pdo_mysql intl opcache

RUN cd /tmp/ && tar xvf gearman-2.0.3.tar.gz && cd pecl-gearman-gearman-2.0.3 && phpize && ./configure && make && make install && echo "extension=gearman.so" > /usr/local/etc/php/conf.d/gearman.ini


# RUN pecl install swoole
# RUN cd /root && pecl download swoole && \
#    tar -zxvf swoole* && cd swoole* && \
#    phpize && \
#    ./configure  && \
#    make && make install
# RUN docker-php-ext-enable swoole

# Composer
# ADD etc/composer /usr/local/bin/composer

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer




COPY ./php.ini /usr/local/etc/php/conf.d
WORKDIR /mnt/application
