#!/bin/bash

cd /var/www/wordpress

if [ ! -f "wp-login.php" ]; then
    wp core download --allow-root
fi

until mariadb -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --ssl=0 -e "SELECT 1;"; do
    echo "Waiting for MariaDB connection..."
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --skip-check \
        --allow-root
fi

if ! wp core is-installed --allow-root; then
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
        
    chown -R www-data:www-data /var/www/wordpress
fi

exec php-fpm8.2 -F