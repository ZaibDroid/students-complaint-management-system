# DCMS Post-Deployment Verification & Smoke Tests

Base URL used below: `https://api.domain.com/api/v1`  
Replace `<TOKEN>` with the Sanctum Bearer token returned by the login step, and replace `ADMIN_PASSWORD` with your rotated production password (default seeded value `123456` must be changed before go-live).

---

## 1. Health Check (`GET /api/v1/health`)

Verifies Nginx/Apache routing, PHP-FPM, Laravel boot, environment (`production`), and timezone (`Asia/Karachi`).

```bash
curl -i -X GET "https://api.domain.com/api/v1/health" \
  -H "Accept: application/json"
```

**Expected Response (`200 OK`):**
```json
{
  "success": true,
  "message": "DCMS API Version 1 is operational",
  "data": {
    "environment": "production",
    "timezone": "Asia/Karachi",
    "version": "1.0.0"
  },
  "meta": {
    "timestamp": "..."
  }
}
```
*(You can also verify Laravel's built-in probe at `GET https://api.domain.com/up`.)*

---

## 2. Login (`POST /api/v1/auth/login`)

Controller: `App\Http\Controllers\Api\V1\AuthController@login`  
Validation (`App\Http\Requests\Auth\LoginRequest`): requires `email` and `password`.  
Rate limit (`AppServiceProvider`): 5 requests/minute per IP on login limiter.

```bash
curl -s -X POST "https://api.domain.com/api/v1/auth/login" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@uetmardan.edu.pk",
    "password": "ADMIN_PASSWORD"
  }'
```

**Expected Response (`200 OK`):**
- `success`: `true`
- `data.token`: Sanctum Bearer token string
- `data.token_type`: `"Bearer"`
- `data.user`: `UserResource` payload (`id`, `name`, `email`, `role`, `roles`, `status`, etc.)

Save the token for subsequent commands:
```bash
export TOKEN="<paste data.token here>"
```

**Postman:** Set Authorization tab → **Type: Bearer Token** → Token: `{{token}}`.

---

## 3. Authenticated Profile Check (`GET /api/v1/auth/me`)

Verifies `auth:sanctum` middleware, `personal_access_tokens` table, and Spatie role loading.

```bash
curl -i -X GET "https://api.domain.com/api/v1/auth/me" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Expected Response (`200 OK`):**
- `success`: `true`
- `data.email`: `"admin@uetmardan.edu.pk"` (or logged-in user)
- `data.role` / `data.roles` populated

---

## 4. Submit Complaint with File Attachment (`POST /api/v1/complaints`)

Endpoint: `POST /api/v1/complaints` (alias for `ApplicationController@store`)  
Authorization: `ApplicationPolicy@create` allows **Student / Class Representative** accounts (login as a student account to test complaint submission, since Admin/Staff roles are not students).

Request rules (`SubmitApplicationRequest`):
- `title` (required, string, max 255)
- `description` (required, string)
- `category` or `category_id` (optional; seeded categories: `Academic`, `Infrastructure`, `Exam`, `General`)
- `priority` (optional: `low`, `medium`, `high`, `urgent`)
- `attachment` (optional single file: `jpeg,png,jpg,webp,pdf,doc,docx`, max `5120` KB) or `attachments[]` (up to 5 files up to `10240` KB each via `UploadAttachmentRequest` at `/complaints/{id}/attachments`)

First log in as a test student account (make sure to disable/rotate after testing):
```bash
export STUDENT_TOKEN="<student login token>"
```

Then submit a multipart complaint with an image/PDF file:
```bash
# Create a small sample file if needed
printf "%%PDF-1.4\n%%test" > /tmp/sample-complaint.pdf

curl -i -X POST "https://api.domain.com/api/v1/complaints" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" \
  -F "title=Post-Deploy Smoke Test Complaint" \
  -F "description=Verifying multipart file upload and public storage symlink." \
  -F "category=Infrastructure" \
  -F "priority=medium" \
  -F "attachment=@/tmp/sample-complaint.pdf"
```

**Expected Response (`201 Created`):**
- `success`: `true`
- `data.ticket_number`: generated ticket sequence
- `data.attachments` / `attachment_path`: public `/storage/Applications/<id>/...` URL

**Verify Storage Symlink & Static Serving:**
Copy the returned attachment URL (e.g., `https://api.domain.com/storage/Applications/1/filename.pdf`) and test:
```bash
curl -I "https://api.domain.com/storage/Applications/1/<filename>.pdf"
```
Must return `200 OK`. If `404 Not Found`, verify `php artisan storage:link` and `chmod -R 775 storage`.

---

## 5. Verify Queue Worker & Timeline Listener (`ShouldQueue`)

After submitting the complaint above:
```bash
curl -s -X GET "https://api.domain.com/api/v1/complaints/<APPLICATION_ID>/timeline" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}"
```
- If Supervisor (`dcms-worker`) is healthy, the `submitted` timeline entry is present and `SELECT COUNT(*) FROM jobs;` returns `0`.
- If `timeline` is empty and rows remain stuck in `jobs`, inspect `/var/www/dcms/Backend/storage/logs/worker.log` and `sudo supervisorctl status`.

---

## 6. Cleanup After Production Verification

1. Delete the smoke-test complaint (`DELETE /api/v1/complaints/<APPLICATION_ID>` or clean test rows from DB) and remove `/tmp/sample-complaint.pdf`.
2. Ensure all default `123456` seeded passwords in `users` have been replaced or test accounts deleted.

