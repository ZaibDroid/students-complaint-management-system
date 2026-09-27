import 'package:equatable/equatable.dart';
import '../../../../shared/enums/notice_target.dart';

class NoticeEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorRole;
  final NoticeTarget target;
  final String? targetValue;
  final bool isPinned;
  final DateTime createdAt;

  const NoticeEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.target,
    this.targetValue,
    this.isPinned = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, authorName, authorRole, target, targetValue, isPinned, createdAt];
}
