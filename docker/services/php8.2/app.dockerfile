FROM php:8.2-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip \
    vim \
    zip

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

RUN install-php-extensions zip

RUN pecl install redis && docker-php-ext-enable redis

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Soap
RUN apt-get update && apt-get install -y libxml2-dev \
    && docker-php-ext-install soap

# XSL (needed by veewee/xml used in codedredd/laravel-soap)
RUN apt-get update && apt-get install -y libxslt1-dev \
    && docker-php-ext-install xsl

# Install PHP extensions
# Graphics Draw
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Multibyte String
RUN apt-get update && apt-get install -y libonig-dev && docker-php-ext-install mbstring 

RUN set -x && \
    apt-get update && \
    apt-get install -y libicu-dev && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

# Miscellaneous
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif
RUN docker-php-ext-install pdo_mysql

#Enable extension
RUN docker-php-ext-enable mbstring
RUN docker-php-ext-enable exif

RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql
    
RUN echo "file_uploads = On\n" \
    "memory_limit = 10000M\n" \
    "upload_max_filesize = 500M\n" \
    "post_max_size = 1000M\n" \
    "max_execution_time = 600\n" \
    > /usr/local/etc/php/conf.d/uploads.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

CMD bash -c "php-fpm"