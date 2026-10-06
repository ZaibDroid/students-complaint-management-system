# Department Complaint Management System (DCMS)

## Project Overview

A Flutter + Firebase complaint management system for the Department of
Computer Science, UET Mardan.

## Branding

-   Primary Color: `#172548`
-   Secondary: White
-   Style: Clean, modern, bright, minimal, professional.

## Tech Stack

-   Flutter (Dart)
-   Firebase Auth
-   Cloud Firestore
-   Firebase Storage
-   Firebase Cloud Messaging
-   Riverpod
-   GoRouter
-   Clean Architecture (Feature-first)

# Functional Requirements

## Roles

-   Student
-   Class Representative (CR)
-   Batch Adviser
-   Coordinator
-   Chairman
-   Office Staff
-   Dean
-   Admin

## Authentication

-   Only `@uetmardan.edu.pk` email addresses.
-   Email verification required.
-   Profile completion after signup.

## Complaint Workflow

Student → Batch Adviser → Coordinator (optional) → Chairman →
Office/Dean (if required) → Chairman → Resolved

Each action supports: - Forward - Reject - Resolve - Return - Remarks -
Notifications - Timeline tracking

## Student Features

-   Submit complaint
-   Track complaint
-   Upload compressed images
-   View notices
-   Adviser request
-   Profile

## Staff Features

Role-based dashboards with complaint queues, remarks, forwarding and
analytics.

## Notice Board

Chairman can target: - All students - Specific year - Batch - Section

# Non-functional Requirements

-   Responsive UI
-   Offline caching
-   Secure Firestore rules
-   Reusable widgets
-   Scalable architecture
-   Push notifications

# Architecture

    lib/
     ├── core/
     │   ├── config/
     │   ├── constants/
     │   ├── services/
     │   ├── routes/
     │   ├── theme/
     │   ├── utils/
     │   └── widgets/
     ├── shared/
     ├── features/
     │   ├── auth/
     │   ├── dashboard/
     │   ├── complaints/
     │   ├── notice_board/
     │   ├── notifications/
     │   ├── profile/
     │   ├── batch/
     │   ├── users/
     │   └── admin/
     └── main.dart

Each feature:

    feature/
     ├── data/
     │   ├── datasource/
     │   ├── models/
     │   └── repositories/
     ├── domain/
     │   ├── entities/
     │   ├── repositories/
     │   └── usecases/
     └── presentation/
         ├── pages/
         ├── providers/
         └── widgets/

# Reusable Widgets

-   PrimaryButton
-   SecondaryButton
-   AppTextField
-   PasswordField
-   SearchBar
-   CustomAppBar
-   DrawerTile
-   DashboardCard
-   ComplaintCard
-   TimelineCard
-   RemarkCard
-   StatusChip
-   UserAvatar
-   ProfileTile
-   EmptyState
-   LoadingWidget
-   ErrorWidget
-   ConfirmationDialog
-   ImagePickerCard
-   NotificationTile
-   NoticeCard
-   FilterBottomSheet
-   PaginationWidget

# Firestore Collections

-   users
-   complaints
-   complaint_history
-   notifications
-   notice_board
-   advisers
-   batches
-   sections
-   archives

# Notifications

Firebase Cloud Messaging for: - Complaint submitted - Forwarded -
Returned - Resolved - Rejected - New notice

# Security

-   Least-privilege access
-   Firestore security rules by role
-   Students access only their own complaints
-   Advisers limited to assigned sections

# Future Scope

-   Web admin portal
-   AI complaint categorization
-   Email/SMS alerts
-   Analytics dashboard
-   Multi-department support

# Prompt for Stitch

Design a premium Flutter application using the above requirements. Use a
clean, modern UI with rounded cards, subtle shadows, whitespace, and
accessible typography. Primary color: #172548. Accent: White. Avoid
clutter. Prefer reusable components and consistent spacing. Generate
production-ready Flutter screens.

# Prompt for Antigravity

Generate a production-ready Flutter application using Clean
Architecture, Riverpod, GoRouter, Firebase Auth, Firestore, Storage, and
FCM. Follow the folder structure exactly. Create reusable widgets,
feature modules, repository pattern, immutable models, and scalable
architecture. Keep business logic out of UI. Prefer StatelessWidgets
where possible.
