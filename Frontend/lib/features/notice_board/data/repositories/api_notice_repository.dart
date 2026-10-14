import 'dart:convert';
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
      'status': 'published',
    };

    final targets = <Map<String, String>>[];

    if (notice.targetRoles != null && notice.targetRoles!.isNotEmpty) {
      for (final role in notice.targetRoles!) {
        targets.add({'type': 'role', 'value': role});
      }
    }

    if (notice.targetBatches != null && notice.targetBatches!.isNotEmpty) {
      for (final batch in notice.targetBatches!) {
        targets.add({'type': 'batch', 'value': batch});
      }
    }

    if (notice.targetSections != null && notice.targetSections!.isNotEmpty) {
      for (final section in notice.targetSections!) {
        targets.add({'type': 'section', 'value': section});
      }
    }

    if (notice.targetCRsOnly == true) {
      targets.add({'type': 'crs_only', 'value': 'true'});
    }

    if (notice.targetYear != null && notice.targetYear!.isNotEmpty) {
      targets.add({'type': 'year', 'value': notice.targetYear!});
    }

    if (targets.isNotEmpty) {
      fields['targets'] = jsonEncode(targets);
      for (int i = 0; i < targets.length; i++) {
        fields['targets[$i][type]'] = targets[i]['type']!;
        if (targets[i]['value'] != null) {
          fields['targets[$i][value]'] = targets[i]['value']!;
        }
      }
    }

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
