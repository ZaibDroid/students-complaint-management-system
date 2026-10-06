class User {
  final String id;
  final String name;
  final String email;
  final String? registrationNumber;
  final String role; // e.g. Student, Chairman, etc.
  final String? department;
  final String? year;
  final String? batch;
  final String? section;
  final String? semester;
  final String? adviser;
  final bool isCR;
  final String status;
  final String? profileImageUrl;
  final String? phone;
  final List<Map<String, dynamic>>? assignedSections;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.registrationNumber,
    this.role = 'Student',
    this.department,
    this.year,
    this.batch,
    this.section,
    this.semester,
    this.adviser,
    this.isCR = false,
    this.status = 'approved',
    this.profileImageUrl,
    this.phone,
    this.assignedSections,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final emailStr = (json['email'] ?? '').toString();
    String? derivedRegNo;
    if (emailStr.contains('@')) {
      derivedRegNo = emailStr.split('@')[0].toUpperCase();
    }

    return User(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      email: emailStr,
      registrationNumber: json['registrationNumber'] ?? json['registration_number'] ?? json['reg_no'] ?? derivedRegNo,
      role: json['role'] ?? 'Student',
      department: json['department'],
      year: json['year'],
      batch: json['batch'],
      section: json['section'],
      semester: json['semester'],
      adviser: json['adviser'],
      isCR: json['isCR'] ?? false,
      status: json['status'] ?? 'approved',
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      phone: json['phone'],
      assignedSections: json['assignedSections'] != null 
          ? List<Map<String, dynamic>>.from(json['assignedSections']) 
          : (json['batch'] != null && json['section'] != null 
              ? [{'batch': json['batch'], 'section': json['section']}] 
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'registrationNumber': registrationNumber,
      'role': role,
      'department': department,
      'year': year,
      'batch': batch,
      'section': section,
      'semester': semester,
      'adviser': adviser,
      'isCR': isCR,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
      'assignedSections': assignedSections,
    };
  }
}
