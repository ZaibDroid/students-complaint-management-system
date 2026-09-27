import '../../../../shared/enums/notice_target.dart';
import '../../domain/entities/notice_entity.dart';

class NoticeModel extends NoticeEntity {
  const NoticeModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorName,
    required super.authorRole,
    required super.target,
    super.targetValue,
    super.isPinned = false,
    required super.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      authorName: json['author_name'] ?? json['author']?['name'] ?? 'Department Chairman',
      authorRole: json['author_role'] ?? json['author']?['role'] ?? 'Chairman',
      target: NoticeTarget.fromString(json['target']?.toString()),
      targetValue: json['target_value'] ?? json['target_identifier'],
      isPinned: json['is_pinned'] == true || json['is_pinned'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_name': authorName,
      'author_role': authorRole,
      'target': target.value,
      'target_value': targetValue,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
