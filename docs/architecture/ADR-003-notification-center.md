# ADR 003: Notification Center & Event-Driven Architecture

## Purpose
Design a scalable, unified messaging hub that processes system events and delivers notifications to users without coupling distinct modules (like Complaints and Notices) directly to the notification logic.

## Problem
If the `ComplaintService` directly creates database notification rows and sends emails, it violates the Single Responsibility Principle and creates a monolithic, tightly-coupled system that is difficult to maintain and expand.

## Decision
1. **Event-Driven Dispatch:** Business domains (e.g., Complaint Engine, Notice Management) only dispatch standard Laravel Events (e.g., `ComplaintSubmitted`, `NoticePublished`).
2. **`DB::afterCommit` Wrapping:** Listeners that generate notifications are strictly executed inside a `DB::afterCommit` callback. This guarantees that notifications are never dispatched if the parent database transaction rolls back.
3. **Polymorphic References:** The `notifications` table utilizes polymorphic relationships (`reference_type`, `reference_id`) instead of distinct columns for different entities. This allows a single unified table to link to Complaints, Notices, or any future entities seamlessly.
4. **Channel Interfaces:** Notification delivery is abstracted via a `NotificationChannelInterface`, allowing the easy addition of future channels (e.g., SMS, Firebase Push) without altering the core `NotificationService`.

## Alternatives Considered
- *Direct Notification Creation:* Evaluated injecting `NotificationService` into the `ComplaintService`. Rejected to maintain strict decoupling between domain boundaries.
- *Native Laravel Notifications:* Evaluated using Laravel's built-in `Notification` facade. While powerful, building our own `NotificationService` over a polymorphic table provided more precise control over the exact JSON payload and delivery channels required by our specific Flutter frontend.

## Consequences
- Highly decoupled architecture; domain services are unaware of notification mechanisms.
- Requires maintaining Event and Listener classes.
- Ensures atomic consistency between business data and notification dispatches.

## Future Considerations
Transitioning to asynchronous queueing for listeners when user volume increases, ensuring API response times remain unaffected by notification processing.
