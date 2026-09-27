/// Laravel API Endpoints for DCMS Backend
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL (configurable per environment: localhost, emulator, server IP)
  // Default Android Emulator: 'http://10.0.2.2:8000/api/v1'
  // Default Physical device / Local network: 'http://192.168.1.100:8000/api/v1'
  // Default Web / Localhost: 'http://127.0.0.1:8000/api/v1'
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String completeProfile = '/auth/complete-profile';
  static const String logout = '/auth/logout';
  static const String currentUser = '/auth/user';
  static const String forgotPassword = '/auth/forgot-password';

  // Complaint Endpoints
  static const String complaints = '/complaints';
  static const String myComplaints = '/complaints/my';
  static const String complaintDetail = '/complaints/{id}';
  static const String submitComplaint = '/complaints';
  static const String forwardComplaint = '/complaints/{id}/forward';
  static const String resolveComplaint = '/complaints/{id}/resolve';
  static const String rejectComplaint = '/complaints/{id}/reject';
  static const String returnComplaint = '/complaints/{id}/return';
  static const String addRemark = '/complaints/{id}/remarks';
  static const String complaintTimeline = '/complaints/{id}/timeline';

  // Notice Board Endpoints
  static const String notices = '/notices';
  static const String createNotice = '/notices';
  static const String noticeDetail = '/notices/{id}';
  static const String deleteNotice = '/notices/{id}';

  // Notifications Endpoints
  static const String notifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/{id}/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static const String registerFcmToken = '/notifications/fcm-token';

  // Academic / Batches & Sections
  static const String batches = '/batches';
  static const String sections = '/sections';
  static const String advisers = '/advisers';
  static const String requestAdviser = '/advisers/request';

  // Dashboard & Analytics
  static const String dashboardStats = '/dashboard/stats';
  static const String analytics = '/dashboard/analytics';

  // Admin & User Management
  static const String adminUsers = '/admin/users';
  static const String updateUserRole = '/admin/users/{id}/role';
  static const String systemConfig = '/admin/config';
  static const String archives = '/admin/archives';
}
