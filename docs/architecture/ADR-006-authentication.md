# ADR 006: Authentication & Authorization Strategy

## Purpose
Define a secure, stateless authentication mechanism for the Flutter mobile application, alongside a unified authorization strategy for backend endpoints.

## Problem
A mobile application requires a mechanism to securely identify users across sessions without relying on traditional cookie-based sessions, which are designed for web browsers and expose mobile clients to CSRF vulnerabilities and state management overhead.

## Decision
1. **Laravel Sanctum (Tokens):** Adopted Laravel Sanctum for API token authentication. Each login generates a Bearer token that Flutter includes in the `Authorization` header.
2. **Stateless API:** The backend remains entirely stateless. Sessions are not used. 
3. **Role-Based Access Control (RBAC):** Using Spatie Laravel Permission. Every user is assigned a specific role (Student, Batch Adviser, Coordinator, Chairman, Admin).
4. **Policy Enforcement:** Middleware is used to enforce authentication (`auth:sanctum`), but fine-grained authorization is strictly handled by Laravel Policies (`$this->authorize('view', $complaint)`). Controllers do not contain manual `if ($user->role == ...)` checks.

## Alternatives Considered
- *JWT (JSON Web Tokens):* Evaluated using `tymondesigns/jwt-auth`. Rejected because Laravel Sanctum provides a simpler, native, and database-backed token management system out of the box that easily handles token revocation, whereas standard JWTs are difficult to revoke before expiration.
- *Laravel Passport:* Evaluated for OAuth2 support. Rejected because the system is a first-party mobile application, not a public API intended for third-party consumer apps. Sanctum is the lighter, more appropriate tool for first-party SPAs and mobile apps.

## Consequences
- Requires Flutter to securely store the Sanctum token (e.g., using `flutter_secure_storage`).
- Token expiration and rotation must be handled manually or by issuing long-lived tokens with device-tracking.

## Future Considerations
- Implementing token rotation (refresh tokens).
- Tracking devices (e.g., storing device names and last used IP/Date alongside the Sanctum tokens) to allow users to remotely log out of lost devices.
