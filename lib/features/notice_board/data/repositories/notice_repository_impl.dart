import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notice_board/data/datasources/notice_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/entities/notice_entity.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/repositories/notice_repository.dart';
import 'package:student_complaint_managment_system/shared/enums/notice_target.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  final NoticeRemoteDataSource _remoteDataSource;

  NoticeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<NoticeEntity>>> getNotices() {
    return _remoteDataSource.getNotices();
  }

  @override
  Future<Result<NoticeEntity>> createNotice({
    required String title,
    required String content,
    required NoticeTarget target,
    String? targetValue,
    bool isPinned = false,
  }) {
    return _remoteDataSource.createNotice(
      title: title,
      content: content,
      target: target,
      targetValue: targetValue,
      isPinned: isPinned,
    );
  }

  @override
  Future<Result<void>> deleteNotice(String id) {
    return _remoteDataSource.deleteNotice(id);
  }
}
