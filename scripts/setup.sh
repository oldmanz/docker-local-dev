#!/bin/bash

DB_DATABASE=spatialdb

echo "listen_addresses='*'" >> /etc/postgresql/13/main/postgresql.conf
echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/13/main/pg_hba.conf	

service postgresql start
service apache2 start

sudo -u postgres psql -c "create user postgres_2n with encrypted password 'postgres';"
sudo -u postgres psql -c "alter user postgres_2n with superuser;"
sudo -u postgres psql -c "create database spatialdb owner postgres_2n;"


####### Setup api ##########

if [ -d "/var/www/html/api" ]; then

	cd /var/www/html/api
	
	if [ ! -d "storage/logs" ]; then
		mkdir storage/logs
	fi

	if [ ! -d "vendor" ]; then
		composer install
	fi

	if [ ! -f ".env" ]; then

		cp .env.example .env
		sed -i "s/DB_DATABASE=spatialDB/DB_DATABASE=${DB_DATABASE}/g" .env

		sed -i "s!# PYTHON_ENV=/home/jenkins/.virtualenv/agol-scripts/bin/python!PYTHON_ENV=/virtualenv/agol-scripts/bin/python!g" .env
		sed -i "s!# PYTHON_DIR=/var/www/python/agol_scripts/!PYTHON_DIR=/var/www/python/agol-scripts!g" .env

		sed -i "s!# PYTHON_DB_FUNCTIONS_ENV=/home/jenkins/.virtualenv/db-functions/bin/python!PYTHON_DB_FUNCTIONS_ENV=/virtualenv/db-functions/bin/python!g" .env
		sed -i "s!# PYTHON_DB_FUNCTIONS_DIR=/var/www/python/db_functions/!PYTHON_DB_FUNCTIONS_DIR=/var/www/python/db-functions!g" .env

	fi

	if [ ! -f "phpunit.xml" ]; then
		cp phpunit.xml.example phpunit.xml
	fi

	chmod 777 -R storage/logs
	chmod 777 -R storage/clockwork

fi


####### Setup 2nform #########
if [ -d "/var/www/html/2nform" ]; then

	cd /var/www/html/2nform

	if [ ! -d "node_modules" ]; then
		npm ci
		npm run gulp build
	fi
fi

####### Setup rambo #########
if [ -d "/var/www/html/ram" ]; then

	cd /var/www/html/ram

	if [ ! -d "node_modules" ]; then
		npm ci
		npm run gulp build
	fi
fi

####### Setup report ########
if [ -d "/var/www/html/report" ]; then

	cd /var/www/html/report

	if [ ! -d "node_modules" ]; then
		npm ci
		npm run gulp build
	fi
fi



pip3 install pip-upgrader
pip-upgrade /opt/requirements/* -p all --skip-package-installation 




###### Setup agol-scripts ########
if [ ! -d "/virtualenv/agol-scripts" ]; then
	python3 -m venv /virtualenv/agol-scripts
	source /virtualenv/agol-scripts/bin/activate
	pip3 install wheel
	pip3 install -r /opt/requirements/agol-requirements.txt
	deactivate
fi

if [ -d "/var/www/python/agol-scripts" ]; then

	cd /var/www/python/agol-scripts


    cp agol_scripts/example.config.ini agol_scripts/config.ini

    sed -i "s/hostname = <host>/hostname = localhost/g" agol_scripts/config.ini
    sed -i "s/username = <username-db>/username = postgres_2n/g" agol_scripts/config.ini
    sed -i "s/password = <password-db>/password = postgres/g" agol_scripts/config.ini
    sed -i "s/database = <database>/database = spatialdb/g" agol_scripts/config.ini

    sed -i "s!agol_scripts_dir = /path/to/agol_scripts!agol_scripts_dir = /var/www/python/agol-scripts!g" agol_scripts/config.ini

fi


####### Setup db-functions  ######

if [ ! -d "/virtualenv/db-functions" ]; then
	python3 -m venv /virtualenv/db-functions
	source /virtualenv/db-functions/bin/activate
	pip3 install wheel
	pip3 install -r /opt/requirements/db-requirements.txt
	deactivate
fi

if [ -d "/var/www/python/db-functions" ]; then

	cd /var/www/python/db-functions

	cp db_functions/example.config.ini db_functions/config.ini

    sed -i "s/hostname = <host>/hostname = localhost/g" db_functions/config.ini
    sed -i "s/username = <username-db>/username = postgres_2n/g" db_functions/config.ini
    sed -i "s/password = <password-db>/password = postgres/g" db_functions/config.ini
    sed -i "s/database = <database>/database = spatialdb/g" db_functions/config.ini

    touch /var/www/python//db-functions/db_functions.log
    chmod 777 /var/www/python/db-functions/db_functions.log

fi




tail -f /dev/null