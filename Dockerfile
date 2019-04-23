FROM php:7.1.11-fpm

#COPY ssh-ci/id_rsa /root/.ssh/id_rsa
#COPY ssh-ci/id_rsa.pub /root/.ssh/id_rsa.pub
#COPY ssh-ci/known_hosts /root/.ssh/known_hosts
#COPY ssh-ci/config /root/.ssh/config
#RUN chmod 400 ~/.ssh/id_rsa


# Write Permission
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

# Install env
ADD etc/sources.list    /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
        git \
        supervisor \
        libgearman-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        #libcurl4-openssl-dev \
        pkg-config  \
        libicu-dev \
        libssl-dev \
        cron \
        uuid-dev \
        libyaml-dev \
        vim \
        unzip \
        wget \
        && rm -r /var/lib/apt/lists/*


COPY etc/gearman-2.0.3.tar.gz  /tmp/

RUN docker-php-ext-configure intl
RUN docker-php-ext-install zip  mcrypt bcmath pdo_mysql intl opcache
RUN cd /tmp/ && tar xvf gearman-2.0.3.tar.gz && cd pecl-gearman-gearman-2.0.3 && phpize && ./configure && make && make install && echo "extension=gearman.so" > /usr/local/etc/php/conf.d/gearman.ini

RUN pecl install channel://pecl.php.net/mongodb-1.5.3 && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini
RUN pecl install uuid &&  echo "extension=uuid.so" > /usr/local/etc/php/conf.d/uuid.ini
RUN pecl install redis && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
RUN pecl install yaml-2.0.0 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/yaml.ini


RUN echo "opcache.memory_consumption=128\nopcache.interned_strings_buffer=8\nopcache.max_accelerated_files=4000\nopcache.revalidate_freq=1\nopcache.fast_shutdown=1\nopcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# 2018-03-15 add by wuxiaoju begin
RUN pecl install channel://pecl.php.net/swoole-1.9.22 && echo "extension=swoole.so" > /usr/local/etc/php/conf.d/swoole.ini

RUN echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list && \
    curl -sS 'https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg' | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install tideways-php && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN echo "extension=tideways.so\ntideways.auto_prepend_library=0" > /usr/local/etc/php/conf.d/tideways.ini
# 2018-03-15 add by wuxiaoju end

# PHP config
# ADD etc/php.ini    /usr/local/etc/php/php.ini
# ADD etc/php-fpm.conf    /usr/local/etc/php-fpm.conf
# ADD etc/supervisord.conf /etc/supervisor/supervisord.conf

# RUN mkdir -p /var/log/supervisord

# Composer
# ADD etc/composer /usr/local/bin/composer

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Set up cron
# ADD crontab /etc/cron.d/laravel-cron

# Give execution rights on the cron job
# RUN chmod 0644 /etc/cron.d/laravel-cron

# Create the log file to be able to run tail
# RUN touch /var/log/cron.log

# 启动 crontab
# RUN /etc/init.d/cron start

WORKDIR /opt

EXPOSE 9000
VOLUME ["/opt"]

RUN php --version
RUN composer --version

# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

