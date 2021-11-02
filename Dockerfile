FROM alpine:latest

ARG PHP_VERSION=8.0
ARG PYTHON_VERSION=3.7.3
ARG NODE_VERSION=12
ARG APACHE_VERSION=

ARG DB_HOST=localhost
ARG DB_DATABASE=spatialDB
ARG DB_USERNAME=postgres_2n
ARG DB_PASSWORD=postgres



RUN apk update; \
    apk upgrade; \
    apk add apache2; \
    apk add acl; \

COPY demo.apache.conf /usr/local/apache2/conf/demo.apache.conf

RUN cat /usr/local/apache2/conf/demo.apache.conf >> /usr/local/apache2/conf/httpd.conf

CMD  [ "/usr/sbin/httpd", "-D", "FOREGROUND"]