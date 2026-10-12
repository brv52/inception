#!/bin/bash
set -e

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

SITE_URL="https://${DOMAIN_NAME}"
if [ -n "${NGINX_PORT}" ] && [ "${NGINX_PORT}" != "443" ]; then
    SITE_URL="${SITE_URL}:${NGINX_PORT}"
fi

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
        --url="${SITE_URL}" \
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

    # Publish comments of registered users without manual approval
    wp option update comment_previously_approved 0 --allow-root --path=/var/www/wordpress

    chown -R www-data:www-data /var/www/wordpress
fi

# Keep the site URL in sync with the published HTTPS port (NGINX_PORT in .env),
# so changing the port does not redirect the browser back to :443.
wp option update home "${SITE_URL}" --allow-root --path=/var/www/wordpress
wp option update siteurl "${SITE_URL}" --allow-root --path=/var/www/wordpress

exec "$@"