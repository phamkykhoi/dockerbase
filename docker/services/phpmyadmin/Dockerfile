FROM phpmyadmin:latest

LABEL maintainer="SUNTECH <suntechvietnamw@gmail.com>"

# Add volume for sessions to allow session persistence
VOLUME /sessions

# Copy custom configuration
COPY config.inc.php /etc/phpmyadmin/config.inc.php

# We expose phpMyAdmin on port 80
EXPOSE 80
