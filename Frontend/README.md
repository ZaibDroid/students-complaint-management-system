# Department Complaint Management System (DCMS) - Frontend App

Cross-platform Flutter application for the Department of Computer Science, UET Mardan.

## 📱 Features

- **Multi-Role User Portals**: Tailored interfaces for Students, Class Representatives, Batch Advisers, Coordinators, Chairmen, Office Staff, Deans, and Admins.
- **Complaint Submission & Tracking**: Real-time complaint submission with compressed file/image uploads and step-by-step resolution timeline.
- **Interactive Notice Board**: Announcement feeds filtered by target audience (all students, batch, section).
- **In-App Notifications**: Real-time status update alerts and action tracking.
- **Clean Architecture & Riverpod**: Modular feature-first design with declarative state management.

---

## 🛠 Tech Stack & Dependencies

- **Flutter**: >= 3.19 (Dart >= 3.0)
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Network**: `dio` with HTTP interceptors & secure token management
- **Storage**: `flutter_secure_storage` & `shared_preferences`
- **UI & Icons**: Custom design system based on brand color `#172548`, `google_fonts`, `lucide_icons` / `flutter_vector_icons`

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured in PATH.
- Android Studio / VS Code with Flutter extensions.

### 2. Installation & Run

```bash
# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze

# Launch application on connected device / emulator
flutter run
```

### 3. API Connection Configuration
Configure the base API URL in `lib/core/network/api_client.dart` or environment parameters:
- **Android Emulator**: `http://10.0.2.2:8000/api/v1`
- **iOS Simulator**: `http://localhost:8000/api/v1`
- **Physical Device**: `http://<YOUR_LOCAL_IP>:8000/api/v1`
