FROM php:7.1-fpm
RUN apt-get update && apt-get install -y \
         supervisor \
         zlib1g-dev \
         libicu-dev \
         g++ \
         libgearman-dev \
         libmemcached-dev \
         zip \
         unzip \
         git \
         libfreetype6-dev \
         libjpeg62-turbo-dev \
         libmcrypt-dev \
         libpng-dev \
         pkg-config  \
         libicu-dev \
         libssl-dev \
         cron \
         uuid-dev \
         libyaml-dev \
         vim \      
         wget \
    && docker-php-ext-install -j$(nproc) iconv  \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install mcrypt zip bcmath intl  pdo_mysql  mbstring  json pdo_mysql mysqli  iconv  pcntl  posix opcache \
    && echo "opcache.enable_cli=0" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && pecl install redis-4.0.1 \
    && pecl install mongodb gearman swoole \
    && docker-php-ext-enable redis mongodb gearman swoole  \
    && rm -rf /var/lib/apt/lists/*
    
    
    RUN pecl install uuid &&  echo "extension=uuid.so" > /usr/local/etc/php/conf.d/uuid.ini

    RUN pecl install yaml-2.0.0 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/yaml.ini





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
