import 'package:student_complaint_managment_system/core/constants/api_endpoints.dart';
import 'package:student_complaint_managment_system/core/services/api_service.dart';
import 'package:student_complaint_managment_system/core/utils/result.dart';
import 'package:student_complaint_managment_system/features/notice_board/data/models/notice_model.dart';
import 'package:student_complaint_managment_system/shared/enums/notice_target.dart';

abstract class NoticeRemoteDataSource {
  Future<Result<List<NoticeModel>>> getNotices();
  Future<Result<NoticeModel>> createNotice({
    required String title,
    required String content,
    required NoticeTarget target,
    String? targetValue,
    bool isPinned = false,
  });
  Future<Result<void>> deleteNotice(String id);
}

class NoticeRemoteDataSourceImpl implements NoticeRemoteDataSource {
  final ApiService _apiService;

  NoticeRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<List<NoticeModel>>> getNotices() async {
    final result = await _apiService.get(ApiEndpoints.notices);

    return result.when(
      onSuccess: (data) {
        final rawList = data is Map && data.containsKey('data')
            ? data['data'] as List
            : (data is List ? data : []);
        final items = rawList
            .whereType<Map<String, dynamic>>()
            .map((json) => NoticeModel.fromJson(json))
            .toList();
        return Result.success(items);
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<NoticeModel>> createNotice({
    required String title,
    required String content,
    required NoticeTarget target,
    String? targetValue,
    bool isPinned = false,
  }) async {
    final result = await _apiService.post(
      ApiEndpoints.createNotice,
      data: {
        'title': title,
        'content': content,
        'target': target.value,
        if (targetValue != null) 'target_value': targetValue,
        'is_pinned': isPinned,
      },
    );

    return result.when(
      onSuccess: (data) {
        final noticeData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(NoticeModel.fromJson(noticeData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<void>> deleteNotice(String id) async {
    final path = ApiEndpoints.deleteNotice.replaceAll('{id}', id);
    final result = await _apiService.delete(path);

    return result.when(
      onSuccess: (_) => Result.success(null),
      onError: (failure) => Result.error(failure),
    );
  }
}
