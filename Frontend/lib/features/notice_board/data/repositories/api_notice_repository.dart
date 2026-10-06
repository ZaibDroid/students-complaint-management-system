import 'dart:io';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/notice_model.dart';

class ApiNoticeRepository {
  final ApiClient _apiClient;

  ApiNoticeRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<void> publishNotice(NoticeModel notice, {List<File>? images}) async {
    final fields = <String, String>{
      'title': notice.title,
      'description': notice.description,
      'tag': notice.tag,
    };

    File? attachment = (images != null && images.isNotEmpty) ? images.first : null;
    List<File>? files = attachment != null ? [attachment] : null;

    await _apiClient.postMultipart(
      ApiConfig.notices,
      fields: fields,
      files: files,
      fileFieldName: 'attachment',
    );
  }

  Future<void> deleteNotice(String id) async {
    await _apiClient.delete('${ApiConfig.notices}/$id');
  }

  Future<List<NoticeModel>> getNotices() async {
    final data = await _apiClient.get(ApiConfig.notices);
    if (data is List) {
      return data
          .map((item) => NoticeModel.fromMap(item as Map<String, dynamic>, (item['id'] ?? '').toString()))
          .toList();
    }
    return [];
  }

  Stream<List<NoticeModel>> streamAllNotices() async* {
    final notices = await getNotices();
    yield notices;
  }
}
