# ADR 001: Database Foundation & Structural Constraints

## Purpose
Establish the foundational schema and constraints for the primary entities (Users, Departments, Batches, Sections) to ensure maximum data integrity before writing application logic.

## Problem
Without strict database-level constraints, application-level bugs can result in orphaned records, duplicate entries, or inconsistent relational state. Relying solely on PHP/Laravel validations is insufficient for an enterprise system.

## Decision
1. **Foreign Key Constraints:** All relationships must be enforced with explicit foreign key constraints at the database level (`constrained()`, `cascadeOnDelete()`, `restrictOnDelete()`).
2. **Unique Constraints:** Composite unique constraints are applied where applicable (e.g., `['department_id', 'batch_id', 'section_name']` to prevent duplicate sections within a batch/department).
3. **Soft Deletes:** Adopted sparingly; prefer hard deletes or archival states for most structural entities to prevent masking data integrity issues.
4. **Primary Keys:** Maintained standard auto-incrementing BIGINT `id` for performance and simplicity, rejecting UUIDs as they add unnecessary indexing overhead for this specific internal-use system.

## Alternatives Considered
- *Using UUIDs/ULIDs:* Evaluated for security (unguessable IDs) but rejected because API resources will handle exposing data securely, and integer primary keys provide superior JOIN performance.
- *Application-level constraints only:* Rejected as it exposes the system to race conditions and manual database manipulation errors.

## Consequences
- Migrations are slightly more complex to write and order correctly.
- Seeders must be run in exact dependency order.
- The database acts as the ultimate source of truth for integrity, preventing bad data from ever being committed regardless of application bugs.

## Future Considerations
If the system expands to a multi-tenant SaaS model, tenant IDs and composite primary keys may need to be introduced, which will require revisiting these structural constraints.
