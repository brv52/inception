#!/bin/bash
set -e

DB_ROOT_PASS=$(cat /run/secrets/db_root_password)
DB_PASS=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
	mariadb --user=mysql --boostrap << EOF
USE mysql;
FLUSH PRIVELEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'\%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVELEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVELEGES;
EOF
fi

exec "$@"
