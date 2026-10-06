# ADR 005: Centralized Media & File Management

## Purpose
Design a unified, centralized file storage and management system capable of handling uploads and secure downloads for any entity in the application (Complaints, Notices, Profiles, etc.).

## Problem
Allowing individual modules to handle their own file storage logic (`$request->file('attachment')->store(...)`) leads to fragmented storage paths, duplicated validation logic, inconsistent security, and structural tech debt when migrating to external storage (e.g., S3). 

## Decision
1. **Polymorphic Media Table:** Introduce a `media` table utilizing Eloquent polymorphic relationships (`model_type`, `model_id`) to associate files with any parent entity (Complaint, Notice, User).
2. **Centralized Service/Controller:** A dedicated `MediaController` and `MediaService` will handle all file uploads, MIME type validation, file hashing, and storage abstraction.
3. **Private Storage & Streamed Downloads:** All files are stored in `storage/app/private/`. Direct public access is strictly disabled. Downloads are managed via a protected `/api/v1/media/{media}/download` endpoint that streams the file directly to the client after verifying authorization through a `MediaPolicy`.
4. **Standardized API Payload:** The frontend receives a standardized `MediaResource` object containing the file metadata and the download URL, shielding it from internal backend storage paths.

## Alternatives Considered
- *Spatie Media Library:* Evaluated utilizing the popular `spatie/laravel-medialibrary` package. Rejected because it includes many heavy features (image conversions, responsive images) that are unnecessary for our primary use case (storing raw PDFs and basic image attachments). A lightweight, custom polymorphic solution is preferred for maximum control.
- *Signed URLs:* Evaluated using Laravel's temporary signed URLs for downloading private files. Rejected in favor of a dedicated controller stream endpoint because managing and renewing short-lived signed URLs in a mobile application (Flutter) adds unnecessary state-management complexity compared to a standard bearer-token authenticated endpoint.

## Consequences
- Requires a migration to remove any legacy `attachment_path` columns from existing tables.
- All frontend file interactions must adapt to the standardized `MediaResource` payload.
- File serving consumes PHP resources (since they are streamed through Laravel instead of served directly by Nginx/Apache), which is acceptable for the expected load and necessary for strict authorization checks.

## Future Considerations
- Hooking in a virus scanning service (e.g., ClamAV) into the `MediaService` upload pipeline.
- If file sizes and traffic grow significantly, offloading storage to AWS S3 and utilizing S3 Pre-Signed URLs may become necessary to alleviate the PHP server.
