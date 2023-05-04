FROM debian:latest

#RUN mkdir /website
#WORKDIR /website
#install dependencies for PHP
RUN apt update && apt dist-upgrade -y && apt install wget gpg curl lsb-release apt-transport-https ca-certificates -y

#add PHP to sources
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
#install apache2 and php
RUN apt update && apt install apache2  \
    php libapache2-mod-php php8.1-mysql php8.1-common php8.1-mysql php8.1-xml php8.1-xmlrpc \
    php8.1-curl php8.1-gd php8.1-imagick php8.1-cli php8.1-dev php8.1-imap php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-intl -y
#copy apache2 modified default host
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

#change to apache server directory and empty it.
WORKDIR /var/www/html
RUN rm -Rv /var/www/html/*

RUN service apache2 restart





#expose port 80 from container
EXPOSE 80
