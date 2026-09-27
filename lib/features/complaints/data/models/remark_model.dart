import '../../domain/entities/remark_entity.dart';

class RemarkModel extends RemarkEntity {
  const RemarkModel({
    required super.id,
    required super.authorName,
    required super.authorRole,
    super.authorAvatarUrl,
    required super.content,
    super.isOfficial = false,
    required super.createdAt,
  });

  factory RemarkModel.fromJson(Map<String, dynamic> json) {
    return RemarkModel(
      id: json['id']?.toString() ?? '',
      authorName: json['author_name'] ?? json['user']?['name'] ?? 'User',
      authorRole: json['author_role'] ?? json['user']?['role'] ?? 'Authority',
      authorAvatarUrl: json['author_avatar'] ?? json['user']?['avatar_url'],
      content: json['content'] ?? json['comment'] ?? '',
      isOfficial: json['is_official'] == true || json['is_official'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'author_role': authorRole,
      'author_avatar': authorAvatarUrl,
      'content': content,
      'is_official': isOfficial,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
