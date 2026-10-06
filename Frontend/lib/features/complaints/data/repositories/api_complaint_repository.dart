import 'dart:io';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/complaint_model.dart';

class ApiComplaintRepository {
  final ApiClient _apiClient;

  ApiComplaintRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<String> submitComplaint(ComplaintModel complaint, {File? attachment}) async {
    final fields = <String, String>{
      'title': complaint.title,
      'description': complaint.description,
      'category': complaint.category,
      if (complaint.priority != null) 'priority': complaint.priority!,
    };

    final response = await _apiClient.postMultipart(
      ApiConfig.complaints,
      fields: fields,
      files: attachment != null ? [attachment] : null,
      fileFieldName: 'attachment',
    );

    if (response is Map<String, dynamic>) {
      return (response['id'] ?? '').toString();
    }
    return '';
  }

  Future<ComplaintModel?> getComplaintById(String id) async {
    try {
      final data = await _apiClient.get('${ApiConfig.complaints}/$id');
      if (data is Map<String, dynamic>) {
        return ComplaintModel.fromMap(data, id);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<ComplaintModel>> getComplaints({String? category, String? status, String? search}) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final data = await _apiClient.get(ApiConfig.complaints, queryParams: queryParams);
    if (data is List) {
      return data
          .map((item) => ComplaintModel.fromMap(item as Map<String, dynamic>, (item['id'] ?? '').toString()))
          .toList();
    }
    return [];
  }

  Stream<List<ComplaintModel>> streamStudentComplaints(String studentId) async* {
    final complaints = await getComplaints();
    yield complaints;
  }

  Stream<List<ComplaintModel>> streamDepartmentComplaints({String? department, String? adviserName, bool isOffice = false}) async* {
    final complaints = await getComplaints(category: department);
    yield complaints;
  }

  Stream<List<ComplaintModel>> streamAllComplaints() async* {
    final complaints = await getComplaints();
    yield complaints;
  }

  Future<void> updateComplaintStatus(
    String id,
    String newStatus, {
    String? adminRemarks,
    String? assignedToId,
    String? assignedTo,
    List<String>? newInvolvedStaff,
  }) async {
    final body = <String, dynamic>{
      'status': newStatus,
    };
    if (assignedToId != null) body['assigned_to_id'] = assignedToId;
    if (adminRemarks != null) body['notes'] = adminRemarks;

    await _apiClient.put('${ApiConfig.complaints}/$id/status', body: body);
  }

  Future<void> addRemark(String complaintId, String remark, {String? actionTaken}) async {
    await _apiClient.post('${ApiConfig.complaints}/$complaintId/remarks', body: {
      'remark': remark,
      'action_taken': ?actionTaken,
    });
  }
}
