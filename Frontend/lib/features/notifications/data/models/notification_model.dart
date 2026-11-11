class NotificationModel {
  final String id;
  final String userId; // The user this notification is for
  final String title;
  final String body;
  final String category; // e.g., 'Complaints', 'Notices', 'System'
  final bool isRead;
  final DateTime timestamp;
  final String? relatedId; // e.g., Complaint ID

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.category,
    this.isRead = false,
    required this.timestamp,
    this.relatedId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    final rawTimestamp = map['timestamp'] ?? map['created_at'];
    final rawRelatedId = map['relatedId'] ??
        (map['reference'] is Map ? map['reference']['id'] : null);

    return NotificationModel(
      id: id.isNotEmpty ? id : (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? map['message'] ?? '').toString(),
      category: (map['category'] ?? map['type'] ?? 'System').toString(),
      isRead: (map['isRead'] ?? map['is_read'] ?? false) == true,
      timestamp: rawTimestamp != null
          ? DateTime.tryParse(rawTimestamp.toString()) ?? DateTime.now()
          : DateTime.now(),
      relatedId: rawRelatedId?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'category': category,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'relatedId': relatedId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? category,
    bool? isRead,
    DateTime? timestamp,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}
