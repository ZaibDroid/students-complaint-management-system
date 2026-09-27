import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/entities/notice_entity.dart';
import 'package:student_complaint_managment_system/shared/enums/notice_target.dart';

abstract class NoticeRepository {
  Future<Result<List<NoticeEntity>>> getNotices();
  Future<Result<NoticeEntity>> createNotice({
    required String title,
    required String content,
    required NoticeTarget target,
    String? targetValue,
    bool isPinned = false,
  });
  Future<Result<void>> deleteNotice(String id);
}
