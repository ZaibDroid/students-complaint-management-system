/// All named route paths for DCMS
class RouteNames {
  RouteNames._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String completeProfile = '/complete-profile';
  static const String forgotPassword = '/forgot-password';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Complaints
  static const String complaintsList = '/complaints';
  static const String submitComplaint = '/complaints/submit';
  static const String complaintDetail = '/complaints/:id';
  static const String complaintTracking = '/complaints/:id/tracking';

  // Notice Board
  static const String noticeBoard = '/notices';
  static const String createNotice = '/notices/create';
  static const String noticeDetail = '/notices/:id';

  // Notifications
  static const String notifications = '/notifications';

  // Batches & Advisers
  static const String batchManagement = '/batches';
  static const String adviserRequest = '/batches/adviser-request';

  // Users Management
  static const String usersList = '/users';
  static const String userDetail = '/users/:id';

  // Admin
  static const String adminPanel = '/admin';
  static const String roleManagement = '/admin/roles';
  static const String archives = '/admin/archives';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';

  // Helpers
  static String complaintDetailPath(String id) => '/complaints/$id';
  static String complaintTrackingPath(String id) => '/complaints/$id/tracking';
  static String noticeDetailPath(String id) => '/notices/$id';
  static String userDetailPath(String id) => '/users/$id';
}
