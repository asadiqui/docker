#!/usr/bin/env sh
set -eu

WP_PATH=${WP_PATH:-/var/www/html}

DB_NAME=${MARIADB_DATABASE:-wordpress}
DB_USER=${MARIADB_USER:-wpuser}
DB_HOST=${MARIADB_HOST:-mariadb}
DB_PASS=$(cat /run/secrets/db_password)

ADMIN_USER=${WP_ADMIN_USER:-siteboss}
ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}

WP_USER_NAME=${WP_USER:-writer}
WP_USER_PASS=$(cat /run/secrets/wp_user_password)
WP_USER_EMAIL=${WP_USER_EMAIL:-writer@example.com}

WP_TITLE=${WP_TITLE:-Inception WP}
DOMAIN=${DOMAIN_NAME:-localhost}
SITE_URL="https://${DOMAIN}"

mkdir -p "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"

# Wait for DB (bounded attempts to avoid infinite loop)
echo "Waiting for MariaDB at ${DB_HOST}:3306..."
for i in $(seq 1 60); do
  if nc -z -w3 "$DB_HOST" 3306; then
    echo "MariaDB is up."
    break
  fi
  echo "Retry $i/60..."
  sleep 1
done

cd "$WP_PATH"

if [ ! -f wp-config.php ]; then
  echo "Installing wp-cli..."
  curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
  chmod +x /usr/local/bin/wp

  echo "Downloading WordPress core..."
  su -s /bin/sh -c "wp core download --allow-root --path=${WP_PATH}" www-data

  echo "Creating wp-config.php..."
  su -s /bin/sh -c "wp config create \
    --allow-root \
    --path=${WP_PATH} \
    --dbname='${DB_NAME}' \
    --dbuser='${DB_USER}' \
    --dbpass='${DB_PASS}' \
    --dbhost='${DB_HOST}' \
    --dbprefix='wp_' \
    --skip-check" www-data

  echo "Installing WordPress..."
  su -s /bin/sh -c "wp core install \
    --allow-root \
    --path=${WP_PATH} \
    --url='${SITE_URL}' \
    --title='${WP_TITLE}' \
    --admin_user='${ADMIN_USER}' \
    --admin_password='${ADMIN_PASS}' \
    --admin_email='${ADMIN_EMAIL}' \
    --skip-email" www-data

  # Create a secondary user if not exists
  su -s /bin/sh -c "wp user get '${WP_USER_NAME}' --field=ID --allow-root --path=${WP_PATH} >/dev/null 2>&1 || \
    wp user create '${WP_USER_NAME}' '${WP_USER_EMAIL}' --role=author --user_pass='${WP_USER_PASS}' --allow-root --path=${WP_PATH}" www-data
fi

echo "Starting php-fpm..."
exec php-fpm82 -F
