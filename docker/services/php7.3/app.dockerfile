FROM php:7.3-fpm

WORKDIR /var/www

# Install system dependencies and PHP extensions in one layer
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip \
    libxml2-dev \
    libxslt1-dev \
    libonig-dev \
    libicu-dev \
    libpq-dev \
    && docker-php-ext-install soap xsl mbstring intl bcmath exif pdo_mysql pcntl \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extension installer and extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions zip

# Redis extension for PHP 7.3 (older version)
RUN pecl install redis-5.3.7 && docker-php-ext-enable redis

# Enable extensions
RUN docker-php-ext-enable mbstring exif
    
RUN echo "file_uploads = On\n" \
    "memory_limit = 10000M\n" \
    "upload_max_filesize = 500M\n" \
    "post_max_size = 1000M\n" \
    "max_execution_time = 600\n" \
    > /usr/local/etc/php/conf.d/uploads.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

CMD bash -c "php-fpm"