import 'dart:io';
import '../models/notice_model.dart';
import 'api_notice_repository.dart';

class NoticeRepository {
  final ApiNoticeRepository _apiRepository;

  NoticeRepository([ApiNoticeRepository? apiRepository]) : _apiRepository = apiRepository ?? ApiNoticeRepository();

  Future<void> publishNotice(NoticeModel notice, {List<File>? images}) async {
    await _apiRepository.publishNotice(notice, images: images);
  }

  Future<void> deleteNotice(String id) async {
    await _apiRepository.deleteNotice(id);
  }

  Stream<List<NoticeModel>> streamAllNotices() {
    return _apiRepository.streamAllNotices();
  }
}
