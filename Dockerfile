FROM ubuntu:16.04

# Install nginx, PHP, and other applications required
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install vim nginx php7.0 php7.0-fpm php7.0-pgsql php7.0-xml php7.0-curl php7.0-zip php7.0-mbstring libxrender1 wget supervisor curl git zip unzip
RUN apt-get -y install xvfb libfontconfig wkhtmltopdf postgresql-9.5 make
RUN apt-get -y install ssmtp
RUN apt-get clean

#Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Install composer
RUN mkdir /tmp/composer/ && \
    cd /tmp/composer && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    cd / && \
    rm -rf /tmp/composer

# Change permissions
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# Create file storage
RUN mkdir /mnt/hireplicity

# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Add config files
ADD nginx.conf /etc/nginx/nginx.conf
ADD hireplicity.conf /etc/nginx/sites-available/default

# Configure Services and Port
CMD service php7.0-fpm start
CMD service postgresql start
CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
CMD ["nginx"]

# Expose port 80 and 443.
EXPOSE 80 443 8000
