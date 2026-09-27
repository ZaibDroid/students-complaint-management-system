import 'dart:io';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/models/paginated_response.dart';
import '../models/complaint_model.dart';
import '../models/remark_model.dart';

abstract class ComplaintsRemoteDataSource {
  Future<Result<PaginatedResponse<ComplaintModel>>> getComplaints({
    int page = 1,
    ComplaintStatus? status,
    PriorityLevel? priority,
    String? category,
    String? search,
    bool myComplaintsOnly = false,
  });

  Future<Result<ComplaintModel>> getComplaintDetail(String id);

  Future<Result<ComplaintModel>> submitComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    List<File>? attachments,
  });

  Future<Result<ComplaintModel>> forwardComplaint({
    required String id,
    required UserRole targetRole,
    required String remarks,
  });

  Future<Result<ComplaintModel>> resolveComplaint({
    required String id,
    required String remarks,
  });

  Future<Result<ComplaintModel>> rejectComplaint({
    required String id,
    required String remarks,
  });

  Future<Result<ComplaintModel>> returnComplaint({
    required String id,
    required String remarks,
  });

  Future<Result<RemarkModel>> addRemark({
    required String complaintId,
    required String content,
    bool isOfficial = false,
  });
}

class ComplaintsRemoteDataSourceImpl implements ComplaintsRemoteDataSource {
  final ApiService _apiService;

  ComplaintsRemoteDataSourceImpl(this._apiService);

  @override
  Future<Result<PaginatedResponse<ComplaintModel>>> getComplaints({
    int page = 1,
    ComplaintStatus? status,
    PriorityLevel? priority,
    String? category,
    String? search,
    bool myComplaintsOnly = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (status != null) 'status': status.value,
      if (priority != null) 'priority': priority.value,
      if (category != null && category.isNotEmpty && category != 'All Categories') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final path = myComplaintsOnly ? ApiEndpoints.myComplaints : ApiEndpoints.complaints;
    final result = await _apiService.get(path, queryParameters: queryParams);

    return result.when(
      onSuccess: (data) {
        if (data is Map<String, dynamic>) {
          final paginated = PaginatedResponse<ComplaintModel>.fromJson(
            data,
            (itemJson) => ComplaintModel.fromJson(itemJson),
          );
          return Result.success(paginated);
        } else if (data is List) {
          final items = data
              .whereType<Map<String, dynamic>>()
              .map((e) => ComplaintModel.fromJson(e))
              .toList();
          return Result.success(
            PaginatedResponse<ComplaintModel>(
              items: items,
              currentPage: 1,
              lastPage: 1,
              total: items.length,
              perPage: items.length,
            ),
          );
        }
        return Result.error(const ServerFailure('Invalid format received from server'));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintModel>> getComplaintDetail(String id) async {
    final path = ApiEndpoints.complaintDetail.replaceAll('{id}', id);
    final result = await _apiService.get(path);

    return result.when(
      onSuccess: (data) {
        final complaintData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(ComplaintModel.fromJson(complaintData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintModel>> submitComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    List<File>? attachments,
  }) async {
    final fields = {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.value,
    };

    final result = await _apiService.postMultipart(
      ApiEndpoints.submitComplaint,
      fields: fields,
      files: attachments,
      fileKey: 'attachments[]',
    );

    return result.when(
      onSuccess: (data) {
        final complaintData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(ComplaintModel.fromJson(complaintData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintModel>> forwardComplaint({
    required String id,
    required UserRole targetRole,
    required String remarks,
  }) async {
    final path = ApiEndpoints.forwardComplaint.replaceAll('{id}', id);
    final result = await _apiService.post(
      path,
      data: {'target_role': targetRole.value, 'remarks': remarks},
    );

    return result.when(
      onSuccess: (data) {
        final complaintData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(ComplaintModel.fromJson(complaintData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintModel>> resolveComplaint({
    required String id,
    required String remarks,
  }) async {
    final path = ApiEndpoints.resolveComplaint.replaceAll('{id}', id);
    final result = await _apiService.post(
      path,
      data: {'remarks': remarks},
    );

    return result.when(
      onSuccess: (data) {
        final complaintData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(ComplaintModel.fromJson(complaintData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintModel>> rejectComplaint({
    required String id,
    required String remarks,
  }) async {
    final path = ApiEndpoints.rejectComplaint.replaceAll('{id}', id);
    final result = await _apiService.post(
      path,
      data: {'remarks': remarks},
    );

    return result.when(
      onSuccess: (data) {
        final complaintData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(ComplaintModel.fromJson(complaintData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintModel>> returnComplaint({
    required String id,
    required String remarks,
  }) async {
    final path = ApiEndpoints.returnComplaint.replaceAll('{id}', id);
    final result = await _apiService.post(
      path,
      data: {'remarks': remarks},
    );

    return result.when(
      onSuccess: (data) {
        final complaintData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(ComplaintModel.fromJson(complaintData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<RemarkModel>> addRemark({
    required String complaintId,
    required String content,
    bool isOfficial = false,
  }) async {
    final path = ApiEndpoints.addRemark.replaceAll('{id}', complaintId);
    final result = await _apiService.post(
      path,
      data: {'content': content, 'is_official': isOfficial},
    );

    return result.when(
      onSuccess: (data) {
        final remarkData = data is Map && data.containsKey('data') ? data['data'] : data;
        return Result.success(RemarkModel.fromJson(remarkData as Map<String, dynamic>));
      },
      onError: (failure) => Result.error(failure),
    );
  }
}
