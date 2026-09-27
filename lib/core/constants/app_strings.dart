/// String Constants for DCMS (Department Complaint Management System)
class AppStrings {
  AppStrings._();

  // General App Info
  static const String appName = 'DCMS - UET Mardan';
  static const String appFullName = 'Department Complaint Management System';
  static const String departmentName = 'Department of Computer Science';
  static const String universityName = 'UET Mardan';
  static const String allowedEmailDomain = '@uetmardan.edu.pk';

  // Auth Strings
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in with your official university email';
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Register with your @uetmardan.edu.pk email';
  static const String emailVerificationTitle = 'Verify Your Email';
  static const String emailVerificationSubtitle = 'We sent a verification link/code to your university email.';
  static const String completeProfileTitle = 'Complete Profile';
  static const String completeProfileSubtitle = 'Provide your academic/staff details to continue';

  // Role Names
  static const String roleStudent = 'Student';
  static const String roleCR = 'Class Representative (CR)';
  static const String roleAdviser = 'Batch Adviser';
  static const String roleCoordinator = 'Coordinator';
  static const String roleChairman = 'Chairman';
  static const String roleStaff = 'Office Staff';
  static const String roleDean = 'Dean';
  static const String roleAdmin = 'Administrator';

  // Complaint Actions
  static const String actionSubmit = 'Submit Complaint';
  static const String actionForward = 'Forward Complaint';
  static const String actionResolve = 'Resolve Complaint';
  static const String actionReject = 'Reject Complaint';
  static const String actionReturn = 'Return to Student/Previous';
  static const String actionAddRemark = 'Add Remark';
  static const String actionTrack = 'Track Progress';

  // Error Messages
  static const String invalidEmailError = 'Only @uetmardan.edu.pk email addresses are allowed';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network connection failed. Please check your internet.';
  static const String sessionExpired = 'Your session has expired. Please log in again.';
}
