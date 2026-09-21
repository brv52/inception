#!/bin/bash
set -e

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

echo "MariaDB validity check..."
MAX_TRIES=30
COUNT=0
until mariadb-admin ping -h"mariadb" -u"${MYSQL_USER}" -p"${DB_PASS}" --silent; do
    COUNT=$((COUNT + 1))
    if [ $COUNT -ge $MAX_TRIES ]; then
        echo "Error: Database is not available after 30s"
        exit 1
    fi
    sleep 1
done

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root --path=/var/www/wordpress

    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="mariadb:3306" \
        --path=/var/www/wordpress

    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path=/var/www/wordpress

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASS}" \
        --role=author \
        --allow-root \
        --path=/var/www/wordpress

    chown -R www-data:www-data /var/www/wordpress
fi

exec "$@"