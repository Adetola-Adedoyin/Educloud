#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "Starting Database Server setup..."

# --- DATABASE CREDENTIALS ---
# IMPORTANT: CHANGE THESE FOR PRODUCTION.
# These values MUST match what's used in backend_user_data.sh
MYSQL_ROOT_PASSWORD="jesutomi" # <<< REPLACE THIS with a strong password!
EDUCLOUD_USER_PASSWORD="jesutomi" # <<< REPLACE THIS with a strong password!

# Update and upgrade system
sudo apt update -y
sudo apt upgrade -y

# Install MySQL server (no password prompt during installation)
# This uses debconf to pre-seed the root password, preventing interactive prompts.
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
sudo debconf-set-selections <<< "mysql-server mysql-server/re-root_password password ${MYSQL_ROOT_PASSWORD}"
sudo apt install mysql-server -y

# Start and enable MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Configure MySQL to allow remote connections
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL to apply configuration changes
sudo systemctl restart mysql

# Connect to MySQL and run setup commands
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF_MYSQL_SETUP
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS educloud_db;

CREATE USER IF NOT EXISTS 'educloud_user'@'%' IDENTIFIED BY '${EDUCLOUD_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON educloud_db.* TO 'educloud_user'@'%';
FLUSH PRIVILEGES;
EOF_MYSQL_SETUP

echo "Database Server setup complete."