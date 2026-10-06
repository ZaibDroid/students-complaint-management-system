class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String tag; // e.g. Academic, Events, Urgent
  final DateTime createdAt;
  final String senderId;
  final String senderName;
  final String? targetYear;
  final List<String>? targetBatches;
  final List<String>? targetSections;
  final List<String>? targetRoles;
  final bool? targetCRsOnly;
  final List<String>? attachments;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.createdAt,
    required this.senderId,
    required this.senderName,
    this.targetYear,
    this.targetBatches,
    this.targetSections,
    this.targetRoles,
    this.targetCRsOnly,
    this.attachments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
      'targetYear': targetYear,
      'targetBatches': targetBatches,
      'targetSections': targetSections,
      'targetRoles': targetRoles,
      'targetCRsOnly': targetCRsOnly,
      'attachments': attachments,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoticeModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tag: map['tag'] ?? 'General',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      targetYear: map['targetYear'],
      targetBatches: map['targetBatches'] != null ? List<String>.from(map['targetBatches']) : null,
      targetSections: map['targetSections'] != null ? List<String>.from(map['targetSections']) : null,
      targetRoles: map['targetRoles'] != null ? List<String>.from(map['targetRoles']) : null,
      targetCRsOnly: map['targetCRsOnly'],
      attachments: map['attachments'] != null ? List<String>.from(map['attachments']) : null,
    );
  }
}
