# ADR 004: Enterprise Dashboard Architecture

## Purpose
Design a performant, unified API that delivers role-specific dashboard metrics, trends, and recent activity in a single payload to the Flutter frontend, minimizing HTTP requests and reducing server load.

## Problem
A naive dashboard implementation results in the frontend making 5-10 separate API calls to aggregate data. Furthermore, performing calculations via PHP collections (`Complaint::all()->where('status', 'pending')->count()`) drastically degrades performance as dataset size increases. Massive monolithic repositories with massive conditional blocks (`switch(role)`) create a maintenance nightmare.

## Decision
1. **Factory & Builder Patterns:** The `DashboardService` utilizes a `DashboardFactory` to resolve a role-specific `DashboardBuilderInterface` implementation (e.g., `StudentDashboardBuilder`, `ChairmanDashboardBuilder`).
2. **Data Transfer Objects (DTO):** Builders orchestrate queries and populate a strongly-typed `DashboardDTO`.
3. **Repository Segregation:** The monolithic repository was split into role-specific repositories (e.g., `CoordinatorDashboardRepository`), enforcing strict access scopes (like `department_id` limits).
4. **Native SQL Aggregations:** All repositories exclusively use optimized native SQL for aggregations (`SUM(CASE WHEN...)`, `TIMESTAMPDIFF()`) instead of loading Eloquent collections into memory.
5. **Centralized Granular Caching:** `DashboardCacheService` manages highly specific cache keys (e.g., `dashboard:coordinator:department_3`). Global cache flushing is banned. Cache invalidation is handled surgically via event listeners upon specific actions.

## Alternatives Considered
- *Monolithic Controller/Service:* Rejected due to high cyclomatic complexity and violation of the Open/Closed Principle.
- *GraphQL:* Evaluated for frontend query flexibility. Rejected to keep the tech stack unified around standard REST patterns, pushing the aggregation burden to the dedicated Backend Builders.

## Consequences
- The architecture is slightly more verbose (more classes: Factories, Builders, Repositories, DTOs).
- The `DashboardResource` is extremely clean, only formatting properties from the DTO.
- The system easily scales to support new roles by simply adding a new Builder and updating the Factory.

## Future Considerations
The strictly structured `DashboardDTO` sets a perfect foundation for exporting these metrics into PDF/Excel reports by simply reusing the existing Builders.
