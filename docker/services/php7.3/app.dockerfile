FROM php:7.3-fpm

# RUN apt-get -y install gcc make autoconf libc-dev pkg-config libzip-dev

RUN apt-get update && apt-get install -y

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

# # Miscellaneous
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif
RUN docker-php-ext-install pdo_mysql
RUN install-php-extensions zip

RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

RUN echo "file_uploads = On\n" \
    "memory_limit = 500M\n" \
    "upload_max_filesize = 500M\n" \
    "post_max_size = 500M\n" \
    "max_execution_time = 600\n" \
    > /usr/local/etc/php/conf.d/uploads.ini
    
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

CMD bash -c "cron && php-fpm"