/// User Roles supported in DCMS UET Mardan
enum UserRole {
  student,
  cr,              // Class Representative
  batchAdviser,    // Batch Adviser
  coordinator,     // Department Coordinator
  chairman,        // Department Chairman
  officeStaff,     // Office Staff
  dean,            // Dean
  admin;           // System Admin

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.cr:
        return 'Class Representative';
      case UserRole.batchAdviser:
        return 'Batch Adviser';
      case UserRole.coordinator:
        return 'Coordinator';
      case UserRole.chairman:
        return 'Chairman';
      case UserRole.officeStaff:
        return 'Office Staff';
      case UserRole.dean:
        return 'Dean';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.cr:
        return 'cr';
      case UserRole.batchAdviser:
        return 'batch_adviser';
      case UserRole.coordinator:
        return 'coordinator';
      case UserRole.chairman:
        return 'chairman';
      case UserRole.officeStaff:
        return 'office_staff';
      case UserRole.dean:
        return 'dean';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.student;
    switch (role.toLowerCase()) {
      case 'cr':
      case 'class_representative':
        return UserRole.cr;
      case 'batch_adviser':
      case 'adviser':
        return UserRole.batchAdviser;
      case 'coordinator':
        return UserRole.coordinator;
      case 'chairman':
        return UserRole.chairman;
      case 'office_staff':
      case 'staff':
        return UserRole.officeStaff;
      case 'dean':
        return UserRole.dean;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  bool get isStaff => this != UserRole.student && this != UserRole.cr;
  bool get isChairman => this == UserRole.chairman;
  bool get isAdmin => this == UserRole.admin;
  bool get canCreateNotice => this == UserRole.chairman || this == UserRole.admin;
}
