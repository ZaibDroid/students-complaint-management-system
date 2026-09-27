# DCMS Laravel REST API Backend - UET Mardan

A Laravel REST API backend for the **Department Complaint Management System (DCMS)** for the Department of Computer Science, UET Mardan.

---

## 🌟 Key Features

1. **Official Domain Validation:** Enforces `@uetmardan.edu.pk` email addresses for registration with 6-digit OTP verification.
2. **Multi-Role Hierarchy:**
   - Student & Class Representative (CR)
   - Batch Adviser
   - Coordinator
   - Chairman
   - Office Staff
   - Dean
   - Administrator
3. **Complaint Workflow Engine:**
   - Student → Batch Adviser → Coordinator → Chairman → Office/Dean → Resolved/Rejected/Returned
   - Full timeline audit logging for every status change
   - Real-time remarks thread
4. **Push Notifications (FCM):**
   - Push notifications to Flutter mobile app via Firebase Cloud Messaging
5. **Notice Board & Circulars:**
   - Pinned circulars, targeted by Year, Batch, or Section
6. **Role-Adaptive Dashboard Metrics:**
   - Live grievance statistics aggregated per role

---

## 🚀 Quick Setup Instructions

### 1. Requirements
- PHP >= 8.2 with `pdo`, `mbstring`, `openssl`, `fileinfo` extensions
- Composer >= 2.x
- MySQL / MariaDB (or SQLite)

### 2. Installation Steps

```bash
# 1. Navigate to backend directory
cd backend_laravel

# 2. Install PHP dependencies
composer install

# 3. Setup Environment
cp .env.example .env

# 4. Generate Application Key
php artisan key:generate

# 5. Create storage symlink for file uploads
php artisan storage:link
```

### 3. Database Migration & Pre-Seeded Users

Configure your database in `.env` (or use MySQL default):

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dcms_uetmardan
DB_USERNAME=root
DB_PASSWORD=
```

Run migrations and database seeder:

```bash
php artisan migrate:fresh --seed
```

---

## 🔑 Pre-Seeded Test Credentials

All accounts have default password: **`Password123!`**

| Role | Email | Purpose / Capability |
| :--- | :--- | :--- |
| **Student** | `student.cs@uetmardan.edu.pk` | Lodge complaints, track timeline, view notices |
| **CR** | `cr.2022@uetmardan.edu.pk` | Class representative view & section grievances |
| **Batch Adviser** | `adviser.2022@uetmardan.edu.pk` | Review batch complaints, forward to Coordinator |
| **Coordinator** | `coordinator.cs@uetmardan.edu.pk` | Review academic complaints, forward to Chairman |
| **Chairman** | `chairman.cs@uetmardan.edu.pk` | Executive department authority, resolve/reject/forward |
| **Office Staff** | `office.cs@uetmardan.edu.pk` | Office tasks & administrative complaints |
| **Dean** | `dean.fet@uetmardan.edu.pk` | Faculty-level escalated grievances |
| **Admin** | `admin@uetmardan.edu.pk` | Full system control, role assignment, archives |

---

## 📱 Connecting Flutter App to Backend

### Start Laravel Dev Server:

```bash
# Start on all network interfaces
php artisan serve --host=0.0.0.0 --port=8000
```

### Flutter `AppConfig` URL settings:
- **Android Emulator:** `http://10.0.2.2:8000/api/v1`
- **Physical Device (WiFi):** `http://<your-local-computer-ip>:8000/api/v1` (e.g. `http://192.168.1.50:8000/api/v1`)
- **iOS Simulator / Web:** `http://127.0.0.1:8000/api/v1`

---

## 📡 API Endpoints Overview

- **Auth:** `POST /api/v1/auth/login`, `POST /api/v1/auth/register`, `POST /api/v1/auth/verify-email`
- **Complaints:** `GET /api/v1/complaints`, `POST /api/v1/complaints`, `GET /api/v1/complaints/{id}`, `POST /api/v1/complaints/{id}/forward`, `POST /api/v1/complaints/{id}/resolve`, `POST /api/v1/complaints/{id}/reject`, `POST /api/v1/complaints/{id}/return`, `POST /api/v1/complaints/{id}/remarks`
- **Dashboard:** `GET /api/v1/dashboard/stats`, `GET /api/v1/dashboard/analytics`
- **Notices:** `GET /api/v1/notices`, `POST /api/v1/notices`, `DELETE /api/v1/notices/{id}`
- **Academic:** `GET /api/v1/batches`, `GET /api/v1/advisers`, `POST /api/v1/advisers/request`
- **Admin:** `GET /api/v1/admin/users`, `PUT /api/v1/admin/users/{id}/role`
