FROM nginx:1.21

# Copy nginx configuration files
COPY ./sites/php-switch.conf /etc/nginx/conf.d/default.conf

# Copy phpinfo file for testing
COPY ./phpinfo.php /var/www/phpinfo.php

# Create logs directory and set up logging
RUN mkdir -p /var/log/nginx
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Create nginx user and set permissions
RUN chown -R nginx:nginx /var/log/nginx
RUN chown -R nginx:nginx /var/www

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1