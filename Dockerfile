FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user=1000
ARG uid=1000

RUN apt-get update && apt-get install -y zlib1g-dev g++ git libicu-dev zip libzip-dev zip \
    && docker-php-ext-install intl opcache pdo pdo_mysql \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip

COPY --chown=www-data:www-data composer.* /var/www/html/

WORKDIR /var/www/html
COPY . .

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

RUN cd /var/www/html \
    && composer install --no-interaction --no-dev --prefer-dist --no-cache 

USER $user

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD /var/www/html/php-fpm-healthcheck