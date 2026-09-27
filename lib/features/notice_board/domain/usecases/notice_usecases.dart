import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/entities/notice_entity.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/repositories/notice_repository.dart';
import 'package:student_complaint_managment_system/shared/enums/notice_target.dart';

class GetNoticesUseCase {
  final NoticeRepository _repository;
  GetNoticesUseCase(this._repository);

  Future<Result<List<NoticeEntity>>> call() {
    return _repository.getNotices();
  }
}

class CreateNoticeUseCase {
  final NoticeRepository _repository;
  CreateNoticeUseCase(this._repository);

  Future<Result<NoticeEntity>> call({
    required String title,
    required String content,
    required NoticeTarget target,
    String? targetValue,
    bool isPinned = false,
  }) {
    return _repository.createNotice(
      title: title,
      content: content,
      target: target,
      targetValue: targetValue,
      isPinned: isPinned,
    );
  }
}

class DeleteNoticeUseCase {
  final NoticeRepository _repository;
  DeleteNoticeUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteNotice(id);
  }
}
