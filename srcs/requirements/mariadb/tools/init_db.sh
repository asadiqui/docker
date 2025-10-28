#!/usr/bin/env sh
set -eu

DATA_DIR=/var/lib/mysql
RUN_DIR=/run/mysqld

mkdir -p "$RUN_DIR"
chown -R mysql:mysql "$RUN_DIR" "$DATA_DIR"

# Initialize database if empty
if [ ! -d "$DATA_DIR/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mariadb-install-db --user=mysql --datadir="$DATA_DIR" >/dev/null

  DB_NAME=${MARIADB_DATABASE:-wordpress}
  DB_USER=${MARIADB_USER:-wpuser}
  ROOT_PW=$(cat /run/secrets/db_root_password)
  USER_PW=$(cat /run/secrets/db_password)

  cat > /tmp/bootstrap.sql <<SQL
-- Secure install and create database/user
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$USER_PW';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PW';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test; 
FLUSH PRIVILEGES;
SQL

  echo "Bootstrapping MariaDB with initial users and database..."
  mysqld --user=mysql --datadir="$DATA_DIR" --bootstrap < /tmp/bootstrap.sql
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir="$DATA_DIR"
