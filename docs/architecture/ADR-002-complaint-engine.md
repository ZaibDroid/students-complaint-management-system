# ADR 002: Complaint Processing Engine Architecture

## Purpose
Define the architecture for the core business logic of the application: how complaints transition between states, how assignments occur, and how database transactions are managed.

## Problem
State transitions in complaints (e.g., Pending -> In Progress -> Forwarded -> Resolved) are highly complex. If controllers manually update status strings, the system risks entering invalid states (e.g., resolving an unassigned complaint) and suffering from race conditions if two staff members act simultaneously.

## Decision
1. **Strict Service Layer Encapsulation:** Controllers never mutate models directly. All complaint actions route through `ComplaintService`.
2. **Database Transactions (`DB::transaction`):** Every state transition that updates a complaint, assigns a user, and logs a timeline entry is wrapped in a transaction. If one part fails, the entire operation rolls back.
3. **Pessimistic Locking (`lockForUpdate`):** When a staff member initiates a state transition (e.g., resolving), the row is locked (`->lockForUpdate()`) until the transaction completes, preventing concurrent mutation race conditions.
4. **Timeline Automation:** A dedicated `ComplaintTimeline` model tracks every state change to provide a permanent, immutable audit trail of the complaint's lifecycle.

## Alternatives Considered
- *Laravel State Machine Packages:* Evaluated using a dedicated state machine package. Rejected to minimize external dependencies, opting for a robust Service/Repository pattern instead which provides enough structure for our current needs.
- *Observer Pattern for Timeline:* Evaluated using Eloquent Observers to create timeline entries. Rejected because Observers often obscure business logic and make testing difficult. Explicit service-level coordination is preferred.

## Consequences
- Business logic is strictly centralized, making controllers incredibly thin (only handling HTTP req/res).
- The system is resilient to concurrent requests.
- Adding new states requires modifying the Service layer and ensuring valid transition paths.

## Future Considerations
If the complaint workflow becomes dynamic (e.g., customizable workflows per department), we will need to transition from hardcoded service logic to a database-driven workflow engine.
