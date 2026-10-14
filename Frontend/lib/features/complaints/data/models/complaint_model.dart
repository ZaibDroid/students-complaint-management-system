class ComplaintModel {
  final String id;
  final String? ticketNumber;
  final String studentId;
  final String studentName;
  final String title;
  final String description;
  final String category;
  final String status; // pending, forwarded, resolved, rejected
  final DateTime createdAt;
  final String? assignedTo; // UID or name of adviser/chairman
  final String? assignedToId;
  final String? studentBatch;
  final String? priority;
  final String? adminRemarks;
  final DateTime? updatedAt;
  final List<String> attachments; // URLs of uploaded files
  final List<Map<String, dynamic>> remarks; // History of remarks
  final List<String> involvedStaffNames;

  ComplaintModel({
    required this.id,
    this.ticketNumber,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.assignedTo,
    this.assignedToId,
    this.studentBatch,
    this.priority,
    this.adminRemarks,
    this.updatedAt,
    this.attachments = const [],
    this.remarks = const [],
    this.involvedStaffNames = const [],
  });

  ComplaintModel copyWith({
    String? id,
    String? ticketNumber,
    String? studentId,
    String? studentName,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? createdAt,
    String? assignedTo,
    String? assignedToId,
    String? studentBatch,
    String? priority,
    String? adminRemarks,
    DateTime? updatedAt,
    List<String>? attachments,
    List<Map<String, dynamic>>? remarks,
    List<String>? involvedStaffNames,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToId: assignedToId ?? this.assignedToId,
      studentBatch: studentBatch ?? this.studentBatch,
      priority: priority ?? this.priority,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
      remarks: remarks ?? this.remarks,
      involvedStaffNames: involvedStaffNames ?? this.involvedStaffNames,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'assignedTo': assignedTo,
      'assignedToId': assignedToId,
      'studentBatch': studentBatch,
      'priority': priority,
      'adminRemarks': adminRemarks,
      'updatedAt': updatedAt?.toIso8601String(),
      'attachments': attachments,
      'remarks': remarks,
      'involvedStaffNames': involvedStaffNames,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String docId) {
    return ComplaintModel(
      id: docId,
      ticketNumber: map['ticketNumber'] ?? map['ticket_number'],
      studentId: (map['studentId'] ?? map['student_id'] ?? '').toString(),
      studentName: map['studentName'] ?? map['student_name'] ?? 'Unknown',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : (map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
      assignedTo: map['assignedTo'] ?? map['assigned_to'],
      assignedToId: (map['assignedToId'] ?? map['assigned_to_id'])?.toString(),
      studentBatch: map['studentBatch'] ?? map['student_batch'],
      priority: map['priority'],
      adminRemarks: map['adminRemarks'] ?? map['admin_remarks'],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : (map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null),
      attachments: List<String>.from(map['attachments'] ?? []),
      remarks: List<Map<String, dynamic>>.from(map['remarks'] ?? []),
      involvedStaffNames: List<String>.from(map['involvedStaffNames'] ?? []),
    );
  }
}
