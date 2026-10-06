# Department Complaint Management System (DCMS) - Backend API

Production-ready Laravel 11 / 12 REST API built using **Clean Architecture**, **SOLID Principles**, **Repository Pattern**, **Service Layer**, **Sanctum Authentication**, and **Spatie Role-Based Access Control (RBAC)** for UET Mardan Computer Science Department.

---

## 🏗 Architectural Overview

```text
               ┌──────────────────────────────────────────────┐
               │              Flutter Mobile App              │
               └──────────────────────┬───────────────────────┘
                                      │ HTTP / HTTPS (Sanctum Token)
                                      ▼
               ┌──────────────────────────────────────────────┐
               │    Laravel API Router & Middleware Layer     │
               │  (ForceJsonResponse, Sanctum, Spatie RBAC)   │
               └──────────────────────┬───────────────────────┘
                                      │
                                      ▼
               ┌──────────────────────────────────────────────┐
               │            Thin API Controllers              │
               │  (AuthController, ComplaintController, etc.) │
               └──────────────────────┬───────────────────────┘
                                      │
                                      ▼
               ┌──────────────────────────────────────────────┐
               │                Service Layer                 │
               │  (AuthService, ComplaintService, NoticeSvc)  │
               └──────────────────────┬───────────────────────┘
                                      │
                                      ▼
               ┌──────────────────────────────────────────────┐
               │               Repository Layer               │
               │  (UserRepository, ComplaintRepository, etc.) │
               └──────────────────────┬───────────────────────┘
                                      │
                                      ▼
               ┌──────────────────────────────────────────────┐
               │             MySQL Database Engine            │
               └──────────────────────────────────────────────┘
```

---

## 🚀 Quick Setup & Installation Guide

### Prerequisites
- PHP >= 8.2 with extensions (`pdo_mysql`, `mbstring`, `gd`, `zip`)
- MySQL >= 8.0
- Composer >= 2.5

### 1. Clone & Install Dependencies
```bash
cd Backend
composer install
```

### 2. Environment Configuration
```bash
cp .env.example .env
php artisan key:generate
```
Configure database credentials in `.env`:
```ini
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dcms_db
DB_USERNAME=root
DB_PASSWORD=
```

### 3. Database Migrations & Seeders
```bash
php artisan migrate:fresh --seed
```

### 4. Create Public Storage Symlink
```bash
php artisan storage:link
```

### 5. Run Development Server
```bash
php artisan serve --port=8000
```
API Base URL: `http://localhost:8000/api/v1`

---

## 📱 Flutter Developer Integration Guide

### 1. Base URL & Dio Configuration

In your Flutter app (`lib/core/network/api_client.dart`), configure `dio`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android Emulator
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Accept': 'application/json',
    },
  ));

  final storage = const FlutterSecureStorage();

  ApiClient() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'sanctum_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token expiry / redirect to login
        }
        return handler.next(error);
      },
    ));
  }
}
```

### 2. Authentication Flow

#### Login (`POST /api/v1/auth/login`)
```dart
final response = await apiClient.dio.post('/auth/login', data: {
  'email': '2022cs45@uetmardan.edu.pk',
  'password': 'Password123!',
});

final token = response.data['data']['token'];
await storage.write(key: 'sanctum_token', value: token);
```

#### Fetch Current Profile (`GET /api/v1/auth/me`)
```dart
final response = await apiClient.dio.get('/auth/me');
final userJson = response.data['data'];
```

### 3. Submitting Complaints with File Attachments (`POST /api/v1/complaints`)

```dart
FormData formData = FormData.fromMap({
  'title': 'Leaking Water Dispenser',
  'description': 'Water dispenser in CS Block is leaking.',
  'category': 'Infrastructure',
  'priority': 'medium',
  'attachments': [
    await MultipartFile.fromFile('/path/to/image.jpg', filename: 'dispenser.jpg'),
    await MultipartFile.fromFile('/path/to/doc.pdf', filename: 'report.pdf'),
  ],
});

final response = await apiClient.dio.post('/complaints', data: formData);
```

---

## 🐳 Docker Deployment Guide

Run the full stack with Nginx, MySQL 8.0, and Supervisor queue workers using Docker Compose:

```bash
docker-compose up -d --build
```

Access the API at `http://localhost:8000/api/v1/health`.

---

## 🧪 Running Automated Tests

```bash
php artisan test
```

---

## 📊 Endpoints Summary Reference

- **Auth**: `/api/v1/auth/register`, `/api/v1/auth/login`, `/api/v1/auth/logout`, `/api/v1/auth/me`, `/api/v1/auth/profile`, `/api/v1/auth/password`
- **Complaints**: `/api/v1/complaints`, `/api/v1/complaints/{id}/status`, `/api/v1/complaints/{id}/remarks`, `/api/v1/complaints/{id}/timeline`
- **Notices**: `/api/v1/notices`, `/api/v1/notices/{id}/attachment`
- **Notifications**: `/api/v1/notifications`, `/api/v1/notifications/unread-count`, `/api/v1/notifications/read-all`
- **FCM Tokens**: `/api/v1/fcm-tokens`
- **Dashboard & Analytics**: `/api/v1/dashboard`, `/api/v1/dashboard/charts`
- **Reports & Export**: `/api/v1/reports?type=complaints&format=csv`
- **System Settings**: `/api/v1/settings`

---

### Production Readiness Verification Summary
- **SQL Injection & Mass Assignment**: Shielded using Eloquent `$fillable` arrays and parameter bindings.
- **XSS & File Validation**: Enforced MIME type checks (`jpeg, png, jpg, webp, pdf, doc, docx`) and strict max size caps (10MB).
- **JSON Error Guarantees**: Intercepted in `bootstrap/app.php` to prevent HTML error leaks.
