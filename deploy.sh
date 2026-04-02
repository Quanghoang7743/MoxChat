#!/bin/bash
set -e

SERVER_IP="${1:-192.168.1.200}"
SERVER_USER="${2:-www-data}"
PROJECT_DIR="${3:-/var/www/messapp}"

echo "=== Messapp Deploy Script ==="
echo "Server: $SERVER_IP"
echo ""

# 1. Build frontend locally
echo "[1/5] Building frontend..."
npm run build

# 2. Git commit & push
echo "[2/5] Pushing to git..."
git add .
git commit -m "deploy: $(date +%Y%m%d-%H%M)" || echo "No changes to commit"
git push

# 3. Deploy on server (SSH)
echo "[3/5] Deploying on server..."
ssh $SERVER_IP << ENDSSH
cd $PROJECT_DIR

# Pull latest code
git pull origin main 2>/dev/null || git pull

# PHP dependencies
composer install --optimize-autoloader --no-dev

# If you need to build on server:
# npm install && npm run build

# Laravel cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Permissions
chmod -R 775 storage bootstrap/cache
chown -R $SERVER_USER:$SERVER_USER storage bootstrap/cache

# Restart services
supervisorctl restart reverb 2>/dev/null || echo "Reverb not managed by supervisor"
systemctl restart php8.3-fpm 2>/dev/null || true
systemctl restart nginx 2>/dev/null || true

echo "Deploy done!"
ENDSSH

echo ""
echo "=== Deploy Complete ==="
echo "Frontend: http://$SERVER_IP:8000"
echo "Reverb WS: ws://$SERVER_IP:8080"
