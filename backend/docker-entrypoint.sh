#!/bin/sh
set -e
cd /var/www/html

if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
  echo "[pos-api] APP_KEY missing — generating one for this container"
  export APP_KEY="$(php -r "echo 'base64:'.base64_encode(random_bytes(32));")"
fi

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache /run/nginx
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

php artisan config:clear 2>/dev/null || true
php artisan storage:link 2>/dev/null || true

echo "[pos-api] starting php-fpm + nginx on :8000"
php-fpm -D
exec nginx -g 'daemon off;'
