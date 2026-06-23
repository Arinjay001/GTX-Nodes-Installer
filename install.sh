#!/bin/bash
set -e

PANEL_DOMAIN="panel.gtxnodes.xyz"
ADMIN_EMAIL="ostwalarinjay1@gmail.com"
ADMIN_USER="Arinjay01"
ADMIN_FIRST="Arinjay"
ADMIN_LAST="Ostwal"
ADMIN_PASS="Arinjay@001"
TIMEZONE="Asia/Kolkata"

DB_NAME="panel"
DB_USER="pterodactyl"
DB_PASS="$(openssl rand -base64 32)"

echo "================================="
echo "GTX Nodes Panel Auto Installer"
echo "================================="

apt update && apt upgrade -y
apt install -y software-properties-common curl apt-transport-https ca-certificates gnupg unzip tar git nginx mariadb-server redis-server certbot python3-certbot-nginx ufw

add-apt-repository -y ppa:ondrej/php
apt update
apt install -y php8.3 php8.3-cli php8.3-gd php8.3-mysql php8.3-mbstring php8.3-bcmath php8.3-xml php8.3-curl php8.3-zip php8.3-fpm php8.3-intl php8.3-redis

curl -sS https://getcomposer.org/installer | php
mv -f composer.phar /usr/local/bin/composer

systemctl enable --now mariadb
systemctl enable --now redis-server

mysql -u root <<MYSQL
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
MYSQL

mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz

chmod -R 755 storage/* bootstrap/cache/

cp -f .env.example .env

composer install --no-dev --optimize-autoloader --no-interaction

php artisan key:generate --force

php artisan p:environment:setup \
  --author="$ADMIN_EMAIL" \
  --url="https://$PANEL_DOMAIN" \
  --timezone="$TIMEZONE" \
  --cache=redis \
  --session=redis \
  --queue=redis \
  --settings-ui=true \
  --no-interaction

php artisan p:environment:database \
  --host=127.0.0.1 \
  --port=3306 \
  --database="$DB_NAME" \
  --username="$DB_USER" \
  --password="$DB_PASS" \
  --no-interaction

php artisan migrate --seed --force

php artisan p:user:make \
  --email="$ADMIN_EMAIL" \
  --username="$ADMIN_USER" \
  --name-first="$ADMIN_FIRST" \
  --name-last="$ADMIN_LAST" \
  --password="$ADMIN_PASS" \
  --admin=1 \
  --no-interaction || true

chown -R www-data:www-data /var/www/pterodactyl
chmod -R 755 storage bootstrap/cache

cat > /etc/systemd/system/pteroq.service <<EOF
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --sleep=3 --tries=3

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name $PANEL_DOMAIN;
    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log /var/log/nginx/pterodactyl.app-error.log error;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf

systemctl daemon-reload
systemctl enable --now php8.3-fpm
systemctl enable --now nginx
systemctl enable --now pteroq

nginx -t
systemctl restart php8.3-fpm
systemctl restart nginx
systemctl restart pteroq

echo "Applying GTX Nodes panel fixes and optimizations..."

cd /var/www/pterodactyl

php artisan optimize:clear
php artisan migrate --seed --force
php artisan queue:restart

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

chown -R www-data:www-data /var/www/pterodactyl
chmod -R 755 storage bootstrap/cache

sed -i 's/^pm.max_children.*/pm.max_children = 80/' /etc/php/8.3/fpm/pool.d/www.conf || true
sed -i 's/^pm.start_servers.*/pm.start_servers = 10/' /etc/php/8.3/fpm/pool.d/www.conf || true
sed -i 's/^pm.min_spare_servers.*/pm.min_spare_servers = 10/' /etc/php/8.3/fpm/pool.d/www.conf || true
sed -i 's/^pm.max_spare_servers.*/pm.max_spare_servers = 25/' /etc/php/8.3/fpm/pool.d/www.conf || true

ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw allow 22/tcp || true

certbot --nginx -d "$PANEL_DOMAIN" --non-interactive --agree-tos -m "$ADMIN_EMAIL" || true

systemctl restart redis-server
systemctl restart php8.3-fpm
systemctl restart nginx
systemctl restart pteroq

echo "================================="
echo "GTX Nodes Panel Installed"
echo "URL: https://$PANEL_DOMAIN"
echo "Email: $ADMIN_EMAIL"
echo "Username: $ADMIN_USER"
echo "Password: $ADMIN_PASS"
echo "Database: $DB_NAME"
echo "Database user: $DB_USER"
echo "Database password: $DB_PASS"
echo "================================="
