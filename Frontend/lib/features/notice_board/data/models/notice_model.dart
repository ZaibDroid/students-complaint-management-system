class NoticeAttachmentItem {
  final String id;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;

  NoticeAttachmentItem({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
  });

  factory NoticeAttachmentItem.fromMap(Map<String, dynamic> map) {
    return NoticeAttachmentItem(
      id: (map['id'] ?? '').toString(),
      fileName: (map['file_name'] ?? map['fileName'] ?? map['name'] ?? '').toString(),
      fileUrl: (map['file_url'] ?? map['fileUrl'] ?? map['url'] ?? map['path'] ?? '').toString(),
      fileType: map['file_type']?.toString() ?? map['fileType']?.toString(),
      fileSize: map['file_size'] is int
          ? map['file_size'] as int
          : int.tryParse(map['file_size']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }
}

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
  final List<NoticeAttachmentItem>? attachmentDetails;

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
    this.attachmentDetails,
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
      'attachmentDetails': attachmentDetails?.map((a) => a.toMap()).toList(),
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map, String documentId) {
    List<String>? parsedAttachments;
    List<NoticeAttachmentItem>? parsedDetails;

    final rawAttachments = map['attachments'] ?? map['attachment_urls'];
    if (rawAttachments is List) {
      parsedAttachments = [];
      parsedDetails = [];

      for (final item in rawAttachments) {
        if (item is Map) {
          final itemMap = Map<String, dynamic>.from(item);
          final url = (itemMap['file_url'] ?? itemMap['fileUrl'] ?? itemMap['url'] ?? itemMap['path'] ?? '').toString();
          if (url.isNotEmpty) {
            parsedAttachments.add(url);
          }
          parsedDetails.add(NoticeAttachmentItem.fromMap(itemMap));
        } else if (item != null) {
          final str = item.toString();
          if (str.isNotEmpty) {
            parsedAttachments.add(str);
            parsedDetails.add(NoticeAttachmentItem(
              id: '',
              fileName: str.split('/').last.split('?').first,
              fileUrl: str,
            ));
          }
        }
      }
    }

    return NoticeModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? '').toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tag: map['tag'] ?? 'General',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      senderId: (map['senderId'] ?? map['sender_id'] ?? '').toString(),
      senderName: (map['senderName'] ?? map['sender_name'] ?? '').toString(),
      targetYear: map['targetYear'] ?? map['target_year'],
      targetBatches: map['targetBatches'] != null
          ? List<String>.from(map['targetBatches'])
          : (map['target_batches'] != null ? List<String>.from(map['target_batches']) : null),
      targetSections: map['targetSections'] != null
          ? List<String>.from(map['targetSections'])
          : (map['target_sections'] != null ? List<String>.from(map['target_sections']) : null),
      targetRoles: map['targetRoles'] != null
          ? List<String>.from(map['targetRoles'])
          : (map['target_roles'] != null ? List<String>.from(map['target_roles']) : null),
      targetCRsOnly: map['targetCRsOnly'] ?? map['target_crs_only'],
      attachments: (parsedAttachments != null && parsedAttachments.isNotEmpty) ? parsedAttachments : null,
      attachmentDetails: (parsedDetails != null && parsedDetails.isNotEmpty) ? parsedDetails : null,
    );
  }
}
