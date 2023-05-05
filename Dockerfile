FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive
ENV ghurl=
#RUN mkdir /website
#WORKDIR /website
#install dependencies for PHP
RUN apt-get update && apt-get install --no-install-recommends wget gpg cron git curl lsb-release apt-transport-https ca-certificates -y \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
#install apache2 and php
RUN apt-get update && apt-get install --no-install-recommends apache2  \
    php libapache2-mod-php  php8.1-common php8.1-mysql php8.1-xml php8.1-xmlrpc \
    php8.1-curl php8.1-gd php8.1-imagick php8.1-cli php8.1-dev  php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-intl -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
#copy apache2 modified default host
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

VOLUME [ "/var/www/html" ]
#change to apache server directory and empty it.
WORKDIR /var/www/html
RUN rm -Rv /var/www/html/* && \
    service apache2 stop && \
    service apache2 start
 #   echo testing > /var/www/html/testing.html
#make cron and redirect logs to console
COPY pull.sh /pull.sh
COPY cron.sh /cron.sh  
#RUN echo '0 5 * * * cd /var/www/html/ && git pull >/dev/null 2>&1' >> /crontab/timer.txt 
RUN mkdir /cronjob && \
    ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
    chmod 777 /pull.sh && chmod 777 /cron.sh && \
    echo '0 5 * * * cd / && ./cron.sh >/dev/null 2>&1' >> /cronjob/timer.txt 
  
#COPY timer.txt /cronjob/timer.txt

#   && git clone ${ghurl} /var/www/html/
#COPY phptest.php /var/www/html/phptest.php
#expose port 80 from container
EXPOSE 80
STOPSIGNAL SIGWINCH
CMD [ "/bin/bash","-c","cd / && ./pull.sh && echo /cronjob/timer.txt > /etc/crontab && cron && apachectl -D FOREGROUND"]

#basic healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1