FROM php:5.6-fpm
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/* 



RUN  pecl install redis-4.0.1 \
    && docker-php-ext-enable redis 

# RUN pecl install swoole
# RUN cd /root && pecl download swoole && \
#    tar -zxvf swoole* && cd swoole* && \
#    phpize && \
#    ./configure  && \
#    make && make install
# RUN docker-php-ext-enable swoole

COPY ./php.ini /usr/local/etc/php/conf.d
WORKDIR /mnt/application
