import 'package:equatable/equatable.dart';

class RemarkEntity extends Equatable {
  final String id;
  final String authorName;
  final String authorRole;
  final String? authorAvatarUrl;
  final String content;
  final bool isOfficial;
  final DateTime createdAt;

  const RemarkEntity({
    required this.id,
    required this.authorName,
    required this.authorRole,
    this.authorAvatarUrl,
    required this.content,
    this.isOfficial = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorName, authorRole, authorAvatarUrl, content, isOfficial, createdAt];
}
