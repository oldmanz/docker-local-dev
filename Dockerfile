FROM ubuntu:latest

ARG PHP_VERSION=8.0
ARG PYTHON_VERSION=3.7
ARG NODE_VERSION=12
ARG APACHE_VERSION=

ARG DB_HOST=localhost
ARG DB_DATABASE=spatialDB
ARG DB_USERNAME=postgres_2n
ARG DB_PASSWORD=postgres

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

ENV NODE_VERSION ${NODE_VERSION}

RUN apt-get update && apt-get install --no-install-recommends -y libpq-dev \
  zlib1g-dev \
  libzip-dev \
  libfreetype6-dev \
  libpng-dev \
  libffi-dev \
  libzbar-dev \
  libssl-dev \
  acl \
  postgresql-client \
  git \
  curl \
  nodejs \
  npm \
  apache2 \
  software-properties-common \
  wget \
  gpg-agent \
  sudo \
  nano \
  unzip \
  build-essential \
  libapache2-mod-wsgi-py3 \
  expect


RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install --no-install-recommends -y python3.7 python3-pip python3-venv python3.7-dev python-dev python3-dev

COPY conf/python/agol-requirements.txt /opt/requirements/agol-requirements.txt
COPY conf/python/db-requirements.txt /opt/requirements/db-requirements.txt

RUN add-apt-repository ppa:ondrej/php
RUN add-apt-repository ppa:ondrej/apache2
RUN apt-get update && apt-get install --no-install-recommends -y php8.0 \
    php8.0-simplexml \
    php8.0-xmlreader \
    php8.0-common \
    php8.0-pdo-mysql \
    php8.0-xml \
    php8.0-curl \
    php-imagick \
    php8.0-pdo-pgsql \
    php8.0-sysvmsg \
    php8.0-xsl \
    php8.0-pgsql \
    php8.0-zip \
    php8.0-mbstring \
    php8.0-readline \
    php8.0-gd \
    php8.0-opcache \
    php8.0-pgsql \
    php-pgsql

RUN update-alternatives --set php /usr/bin/php8.0

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt install --no-install-recommends -y postgresql-13-postgis-3

COPY scripts/restore.sh /usr/bin/restore

RUN chmod u+x /usr/bin/restore

RUN a2enmod rewrite
RUN a2enmod wsgi
RUN a2enmod proxy
RUN a2enmod proxy_http
COPY conf/apache/000-default.conf /etc/apache2/sites-available/000-default.conf


RUN mkdir /virtualenv

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/

COPY scripts/setup.sh /opt/setup.sh
CMD bash -c "cd /opt && chmod 777 setup.sh && ./setup.sh"