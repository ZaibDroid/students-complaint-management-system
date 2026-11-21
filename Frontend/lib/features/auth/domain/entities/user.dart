class User {
  final String id;
  final String name;
  final String email;
  final String? registrationNumber;
  final String role; // e.g. Student, Chairman, etc.
  final String? department;
  final String? departmentId;
  final String? year;
  final String? batch;
  final String? batchId;
  final String? section;
  final String? sectionId;
  final String? semester;
  final String? adviser;
  final bool isCR;
  final String status;
  final String? profileImageUrl;
  final String? phone;
  final List<Map<String, dynamic>>? assignedSections;
  final String? assignedPassword;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.registrationNumber,
    this.role = 'Student',
    this.department,
    this.departmentId,
    this.year,
    this.batch,
    this.batchId,
    this.section,
    this.sectionId,
    this.semester,
    this.adviser,
    this.isCR = false,
    this.status = 'approved',
    this.profileImageUrl,
    this.phone,
    this.assignedSections,
    this.assignedPassword,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final emailStr = (json['email'] ?? '').toString();
    String? derivedRegNo;
    if (emailStr.contains('@')) {
      derivedRegNo = emailStr.split('@')[0].toUpperCase();
    }

    final rawAssignedSections = json['assignedSections'] ?? json['assigned_sections'];
    List<Map<String, dynamic>>? parsedAssignedSections;
    if (rawAssignedSections != null && rawAssignedSections is List) {
      parsedAssignedSections = rawAssignedSections
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    String? parsedBatch = json['batch'] ?? json['batch_name'] ?? (json['batch_details'] is Map ? json['batch_details']['name'] : null);
    if ((parsedBatch == null || parsedBatch == 'N/A' || parsedBatch.isEmpty) && parsedAssignedSections != null && parsedAssignedSections.isNotEmpty) {
      parsedBatch = parsedAssignedSections.first['batch']?.toString();
    }

    String? parsedSection = json['section'] ?? json['section_name'] ?? (json['section_details'] is Map ? json['section_details']['name'] : null);
    if ((parsedSection == null || parsedSection == 'N/A' || parsedSection.isEmpty) && parsedAssignedSections != null && parsedAssignedSections.isNotEmpty) {
      final secNames = parsedAssignedSections.map((s) => s['section'] ?? s['name']).where((s) => s != null && s.toString().isNotEmpty).toSet().join(', ');
      if (secNames.isNotEmpty) {
        parsedSection = secNames;
      }
    }

    return User(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      email: emailStr,
      registrationNumber: json['registrationNumber'] ?? json['registration_number'] ?? json['reg_no'] ?? derivedRegNo,
      role: json['role'] ?? 'Student',
      department: json['department'] ?? json['department_name'] ?? json['departmentName'] ?? (json['department_details'] is Map ? json['department_details']['name'] : null),
      departmentId: (json['department_id'] ?? json['departmentId'] ?? (json['department_details'] is Map ? json['department_details']['id'] : null))?.toString(),
      year: json['year'] ?? json['semester'] ?? (json['current_semester'] != null ? 'Semester ${json['current_semester']}' : null),
      batch: parsedBatch,
      batchId: (json['batch_id'] ?? (json['batch_details'] is Map ? json['batch_details']['id'] : null))?.toString(),
      section: parsedSection,
      sectionId: (json['section_id'] ?? (json['section_details'] is Map ? json['section_details']['id'] : null))?.toString(),
      semester: json['semester'] ?? json['year'] ?? (json['current_semester'] != null ? 'Semester ${json['current_semester']}' : null),
      adviser: json['adviser'] ?? (json['adviser_details'] is Map ? json['adviser_details']['name'] : null),
      isCR: json['isCR'] ?? false,
      status: json['status'] ?? 'approved',
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      phone: json['phone'],
      assignedSections: parsedAssignedSections ?? (parsedBatch != null && parsedSection != null ? [{'batch': parsedBatch, 'section': parsedSection}] : null),
      assignedPassword: json['assigned_password']?.toString() ?? json['assignedPassword']?.toString(),
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
      'batchId': batchId,
      'section': section,
      'sectionId': sectionId,
      'semester': semester,
      'adviser': adviser,
      'isCR': isCR,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
      'assignedSections': assignedSections,
      'assigned_password': assignedPassword,
      'assignedPassword': assignedPassword,
    };
  }
}
