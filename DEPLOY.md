# Deploy Guide - Messapp (Railway)

## Cấu trúc trên Railway

Bạn cần tạo **2 services** trong cùng 1 Railway project:

```
Railway Project: messapp
├── Service 1: web        (Laravel API + Frontend)
└── Service 2: reverb     (WebSocket server)
```

---

## Service 1: Web (Laravel App)

### Cấu hình trong Railway Dashboard

**Build Command** (tùy chọn nếu Railway không tự detect):
```
composer install --no-dev --optimize-autoloader && npm install && npm run build
```

**Start Command:**
```
php artisan serve --host=0.0.0.0 --port=$PORT
```

**Hoặc dùng Procfile** (đã tạo sẵn trong repo):
```
web: php artisan serve --host=0.0.0.0 --port=$PORT
```

### Environment Variables (Web Service)

```
APP_NAME=Messapp
APP_ENV=production
APP_KEY=<generate bằng: php artisan key:generate>
APP_DEBUG=false
APP_URL=https://<tên-web-service>.up.railway.app

DB_CONNECTION=mysql
DB_HOST=<từ Railway MySQL addon>
DB_PORT=3306
DB_DATABASE=<từ Railway MySQL addon>
DB_USERNAME=<từ Railway MySQL addon>
DB_PASSWORD=<từ Railway MySQL addon>

BROADCAST_CONNECTION=reverb
REVERB_APP_ID=messapp
REVERB_APP_KEY=messapp-key
REVERB_APP_SECRET=messapp-secret
REVERB_HOST=<tên-reverb-service>.up.railway.app
REVERB_PORT=443
REVERB_SCHEME=https
REVERB_SERVER_HOST=0.0.0.0
REVERB_SERVER_PORT=$PORT

VITE_REVERB_APP_KEY="${REVERB_APP_KEY}"
VITE_REVERB_HOST=<tên-reverb-service>.up.railway.app
VITE_REVERB_PORT=443
VITE_REVERB_SCHEME=https

APP_TIMEZONE=Asia/Ho_Chi_Minh
APP_DISPLAY_TIMEZONE=Asia/Ho_Chi_Minh
```

---

## Service 2: Reverb (WebSocket Server)

### Tạo service mới trong Railway

1. Trong cùng project, click **+ New**
2. Chọn **GitHub Repo** → cùng repo messapp
3. Railway sẽ tạo service thứ 2 từ cùng codebase

### Cấu hình trong Railway Dashboard

**Start Command:**
```
php artisan reverb:start --host=0.0.0.0 --port=$PORT
```

**Hoặc dùng Procfile.reverb** (rename thành Procfile trên service Reverb, hoặc set Start Command trực tiếp).

### Environment Variables (Reverb Service)

Copy **toàn bộ env** từ Web Service, sau đó sửa:

```
APP_URL=https://<tên-web-service>.up.railway.app
REVERB_HOST=<tên-reverb-service>.up.railway.app
REVERB_PORT=443
REVERB_SCHEME=https
```

---

## Deploy Flow

```bash
# 1. Build + Push
npm run build
git add . && git commit -m "deploy" && git push

# 2. Railway tự deploy cả 2 services
# 3. Chạy migration lần đầu
#    Vào Web Service → Railway Terminal:
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## Checklist

- [ ] MySQL addon đã thêm vào project
- [ ] Web service: Start Command đúng (`php artisan serve --host=0.0.0.0 --port=$PORT`)
- [ ] Reverb service: Start Command đúng (`php artisan reverb:start --host=0.0.0.0 --port=$PORT`)
- [ ] `APP_KEY` đã generate
- [ ] `REVERB_HOST` = URL của Reverb service (không phải Web service)
- [ ] `VITE_REVERB_HOST` = URL của Reverb service
- [ ] `REVERB_SCHEME=https`, `REVERB_PORT=443` cho Railway
- [ ] Cả 2 service dùng chung MySQL addon
- [ ] Đã chạy `php artisan migrate --force`

---

## Debug

```bash
# Xem log Web service
# Railway Dashboard → Web Service → Logs

# Xem log Reverb
# Railway Dashboard → Reverb Service → Logs

# Test WebSocket
# Browser Console: check connection
console.log(window.Echo)
```
