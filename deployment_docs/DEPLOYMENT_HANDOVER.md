# DCMS Backend — Physical Server Production Deployment Handover

**Project:** Department Complaint Management System (DCMS)  
**Target Stack:** Laravel `^11.0`, PHP `^8.2`, MySQL `8.0`, Nginx (or Apache), PHP-FPM, Supervisor, Cron  
**API Prefix:** `/api/v1` | **Health Endpoints:** `GET /api/v1/health` (JSON API) & `GET /up` (Framework)

---

## 1. Critical Pre-Deployment Findings (From Codebase Scan)

Review these items before going live—several differ from a generic Laravel app:

1. **Missing `cache` Migration vs. `.env.example` Default:**
   - `Backend/.env.example` sets `CACHE_STORE=database`, **but `Backend/database/migrations/` does not contain a `cache` table migration** (only `jobs` and `sessions` exist in `2026_10_07_*`).
   - Services that call `Cache::remember()` / `Cache::forget()` (`App\Services\DashboardCacheService`), Spatie Permission cache (`config/permission.php`), and API rate limiters (`AppServiceProvider::configureRateLimiting`) will fail if `CACHE_STORE=database` is used without the table.
   - **Action:** Use `CACHE_STORE=file` (or `redis`) in production `.env` (already set in `PRODUCTION_ENV_EXAMPLE.env`), **or** generate and migrate the cache table before going live (`php artisan cache:table && php artisan migrate`).
2. **Queued Event Listeners Require Active Supervisor Workers:**
   - Four listeners implement `Illuminate\Contracts\Queue\ShouldQueue`:
     - `App\Listeners\CreateTimelineEntry`
     - `App\Listeners\SendApplicationNotification`
     - `App\Listeners\SendNoticeNotification`
     - `App\Listeners\ClearDashboardCache`
   - With `QUEUE_CONNECTION=database`, complaint timeline history, notifications, and dashboard cache invalidation **will not run** unless `php artisan queue:work` is running under Supervisor.
   - Optional: create a `failed_jobs` table (`php artisan queue:failed-table && php artisan migrate`) so failed jobs are captured instead of silently lost.
3. **Seeded Demo Accounts & Admin Password Warning:**
   - `Database\Seeders\AdminUserSeeder` creates 7 `@uetmardan.edu.pk` accounts (`student@`, `adviser@`, `coordinator@`, `chairman@`, `office@`, `dean@`, `admin@uetmardan.edu.pk`) **all using password `123456`**.
   - **SECURITY MANDATE:** Never leave the seeded `123456` password active in production. Immediately rotate `admin@uetmardan.edu.pk`'s password and delete or disable unused demo accounts after initial verification.
   - In production, prefer seeding only baseline lookup/RBAC data (`RoleAndPermissionSeeder`, `SettingSeeder`, `ComplaintCategorySeeder`, `BatchAndSectionSeeder`, `AdminUserSeeder`—then change password) and **do not** run `DemoDataSeeder`.
4. **Duplicate CORS / Security Headers Caution:**
   - `App\Auth\Middlewares\SecureHeadersMiddleware` (registered on all `api/*` routes in `bootstrap/app.php`) already sets `X-Frame-Options: DENY`, `X-XSS-Protection: 1; mode=block`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, and `Strict-Transport-Security`. Avoid adding conflicting `X-Frame-Options` headers in Nginx/Apache unless matching.

---

## 2. Server Directory Setup & Code Deployment

Assume deployment path: `/var/www/dcms` (Laravel root at `/var/www/dcms/Backend`, document root at `/var/www/dcms/Backend/public`).

```bash
# 1. Create deployment directory and clone repository
sudo mkdir -p /var/www/dcms
sudo chown -R $USER:www-data /var/www/dcms
git clone https://github.com/ZaibDroid/students-complaint-management-system.git /var/www/dcms

cd /var/www/dcms/Backend

# 2. Install production Composer dependencies (no dev packages)
composer install --no-dev --optimize-autoloader --no-interaction

# 3. Configure production environment
cp /path/to/PRODUCTION_ENV_EXAMPLE.env .env
# Edit .env with real DB credentials, APP_URL=https://api.domain.com, MAIL_*, etc.
nano .env

# 4. Generate application encryption key (only once on initial setup)
php artisan key:generate --force
```

---

## 3. Permissions & Storage Symlink

Uploads are written to the `public` disk (`storage/app/public/` -> `Applications/{id}`, `notices`, `profiles`) and served via `/storage/...` (`config/filesystems.php`).

```bash
cd /var/www/dcms/Backend

# Create storage symlink (public/storage -> storage/app/public)
php artisan storage:link

# Set ownership to web server / PHP-FPM group (www-data on Ubuntu/Debian)
sudo chown -R www-data:www-data /var/www/dcms/Backend/storage /var/www/dcms/Backend/bootstrap/cache

# Required directory & file permissions (775 on writable directories)
sudo chmod -R 775 /var/www/dcms/Backend/storage /var/www/dcms/Backend/bootstrap/cache

# Protect .env file
chmod 640 /var/www/dcms/Backend/.env
```

---

## 4. Database Initialization & Seeding

1. Create the MySQL 8.0 database and dedicated least-privilege database user:
   ```sql
   CREATE DATABASE dcms_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'dcms_user'@'127.0.0.1' IDENTIFIED BY 'STRONG_RANDOM_PASSWORD';
   GRANT ALL PRIVILEGES ON dcms_prod.* TO 'dcms_user'@'127.0.0.1';
   FLUSH PRIVILEGES;
   ```

2. Run migrations and essential seeders (from `/var/www/dcms/Backend`):
   ```bash
   php artisan migrate --force

   # Seed only essential system/RBAC/category/topology seeders (skip DemoDataSeeder in production)
   php artisan db:seed --class=RoleAndPermissionSeeder --force
   php artisan db:seed --class=SettingSeeder --force
   php artisan db:seed --class=ComplaintCategorySeeder --force
   php artisan db:seed --class=BatchAndSectionSeeder --force
   php artisan db:seed --class=AdminUserSeeder --force
   ```

3. **Immediately rotate the Admin password** (replace `NEW_SECURE_ADMIN_PASSWORD`):
   ```bash
   php -r "require 'vendor/autoload.php'; \$app = require 'bootstrap/app.php'; \$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap(); \$u = App\Models\User::where('email', 'admin@uetmardan.edu.pk')->firstOrFail(); \$u->password = Illuminate\Support\Facades\Hash::make('NEW_SECURE_ADMIN_PASSWORD'); \$u->save(); echo 'Admin password updated' . PHP_EOL;"
   ```
   Also review and disable/remove the other 6 seeded `@uetmardan.edu.pk` test accounts (`student@`, `adviser@`, `coordinator@`, `chairman@`, `office@`, `dean@`) or reset their passwords before opening public access.

---

## 5. Laravel Production Optimization & Caching

Run after every deployment or `.env` change:

```bash
cd /var/www/dcms/Backend

php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan permission:cache-reset
```

*(Note: Never store secrets inside `config/*.php` directly; `config:cache` locks in `.env` values at cache build time.)*

---

## 6. Web Server Configuration (Pointing to `/public`)

### Option A: Nginx (Recommended)
Create `/etc/nginx/sites-available/dcms-api.conf`:

```nginx
server {
    listen 80;
    server_name api.domain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.domain.com;

    root /var/www/dcms/Backend/public;
    index index.php;

    # TLS certificates (e.g., Let's Encrypt Certbot)
    ssl_certificate     /etc/letsencrypt/live/api.domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.domain.com/privkey.pem;

    # Upload limits: UploadAttachmentRequest allows up to 5 files x 10MB
    client_max_body_size 64M;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 120;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable and reload Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/dcms-api.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### Option B: Apache2 (`mod_rewrite` + PHP-FPM)
Ensure `a2enmod rewrite ssl headers proxy_fcgi` is enabled, and configure `/etc/apache2/sites-available/dcms-api.conf`:

```apache
<VirtualHost *:443>
    ServerName api.domain.com
    DocumentRoot /var/www/dcms/Backend/public

    SSLEngine on
    SSLCertificateFile    /etc/letsencrypt/live/api.domain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/api.domain.com/privkey.pem

    <Directory /var/www/dcms/Backend/public>
        AllowOverride All
        Require all granted
        Options -Indexes +FollowSymLinks
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/dcms_error.log
    CustomLog ${APACHE_LOG_DIR}/dcms_access.log combined
</VirtualHost>
```

Also verify PHP `php.ini` (`php-fpm` and `cli`):
- `upload_max_filesize = 20M`
- `post_max_size = 64M`
- `memory_limit = 256M`

---

## 7. Supervisor Configuration (Queue Workers)

Adapted from `Backend/supervisord.conf` for a physical server. Create `/etc/supervisor/conf.d/dcms-worker.conf`:

```ini
[program:dcms-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/dcms/Backend/artisan queue:work database --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/dcms/Backend/storage/logs/worker.log
stopwaitsecs=3600
```

Load and start Supervisor workers:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start dcms-worker:*
sudo supervisorctl status
```

*(Note: After deploying code updates, run `php /var/www/dcms/Backend/artisan queue:restart` so workers reload the latest PHP code cleanly.)*

---

## 8. Cron Jobs (Laravel Scheduler & Log Pruning)

`Backend/routes/console.php` schedules `notices:process` (`App\Console\Commands\ProcessNotices`) every minute to publish scheduled notices and expire past-due notices. Additionally, `audit:prune` (`App\Console\Commands\PruneAuditLogs`) cleans audit logs older than `--days=365`.

Add to `www-data` crontab (`sudo crontab -u www-data -e`):

```cron
* * * * * cd /var/www/dcms/Backend && php artisan schedule:run >> /dev/null 2>&1
0 2 * * 0 cd /var/www/dcms/Backend && php artisan audit:prune --days=365 >> /var/www/dcms/Backend/storage/logs/audit-prune.log 2>&1
```

---

## 9. CORS Production Check (`config/cors.php`)

`Backend/config/cors.php` currently ships with wildcard `'allowed_origins' => ['*']` and `'supports_credentials' => true`.
- Native mobile clients (Android/iOS Flutter) do not enforce browser CORS.
- If serving Flutter Web or an Admin SPA, update `Backend/config/cors.php` to replace `['*']` with exact production origin(s) (e.g. `['https://app.domain.com']`), because browsers block `'Access-Control-Allow-Origin: *'` when `'supports_credentials' => true`. Then re-run `php artisan config:cache`.

