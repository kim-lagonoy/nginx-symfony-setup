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

# Install wkhtmltopdf
RUN mkdir /tmp/wkhtml && \
    cd /tmp/wkhtml \
    wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
    tar vxf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
    cp wkhtmltox/bin/wk* /usr/local/bin/ \
    rm -rf /tmp/wkhtml
RUN apt-get install -y --allow-downgrades libssl1.0.0=1.0.2g-1ubuntu4
RUN apt-get update
RUN apt-get install -y libssl-dev=1.0.2g-1ubuntu4

# Enable php-fpm on nginx virtualhost configuration
ADD nginx.conf ${nginx_conf}
ADD hireplicity.conf ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}

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
RUN chmod -R 775 /var/www/html

# Create file storage
RUN mkdir /mnt/hireplicity
RUN mkdir /etc/hireplicity
RUN mkdir /etc/hireplicity/resumes

# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Configure Services and Port
RUN service php7.0-fpm start
RUN service postgresql start
CMD ["/usr/bin/supervisord", "-n"]
CMD ["nginx"]

# Expose port 80 and 443.
EXPOSE 80 443
