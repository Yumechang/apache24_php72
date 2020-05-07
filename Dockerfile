FROM php:7.2-apache-stretch
RUN apt update && apt upgrade -y && apt install -y libpng-dev libmagickwand-dev libpng16-16 libmagickwand-6.q16-3 \
    libzip-dev libzip4 &&\
    pecl install igbinary imagick &&\
    docker-php-ext-install -j $(nproc) gd zip mbstring mysqli exif bcmath pdo pdo_mysql &&\
    docker-php-ext-enable igbinary imagick opcache &&\
    apt remove -y libpng-dev libmagickwand-dev  libzip-dev && apt autoremove -y &&\
    rm -rf /var/lib/apt/lists/ && rm -rf /tmp/pear/

RUN cd /tmp/ && pecl bundle redis && cd redis && phpize && ./configure --enable-redis-igbinary &&\
    make -j $(nproc) && make install && docker-php-ext-enable redis &&\
    rm -rf /tmp/*

RUN a2enmod rewrite expires proxy_http ssl headers ext_filter

# session to redis run
RUN echo 'session.serialize_handler = igbinary\n\
date.timezone = Asia/Taipei\n\
expose_php = off\n\
memory_limit = -1\n'>> /usr/local/etc/php/php.ini
