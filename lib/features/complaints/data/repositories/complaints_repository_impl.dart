import 'dart:io';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/models/paginated_response.dart';
import '../../domain/entities/complaint_entity.dart';
import '../../domain/entities/remark_entity.dart';
import '../../domain/repositories/complaints_repository.dart';
import '../datasources/complaints_remote_data_source.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  final ComplaintsRemoteDataSource _remoteDataSource;

  ComplaintsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<PaginatedResponse<ComplaintEntity>>> getComplaints({
    int page = 1,
    ComplaintStatus? status,
    PriorityLevel? priority,
    String? category,
    String? search,
    bool myComplaintsOnly = false,
  }) async {
    final result = await _remoteDataSource.getComplaints(
      page: page,
      status: status,
      priority: priority,
      category: category,
      search: search,
      myComplaintsOnly: myComplaintsOnly,
    );

    return result.when(
      onSuccess: (paginated) => Result.success(
        PaginatedResponse<ComplaintEntity>(
          items: paginated.items,
          currentPage: paginated.currentPage,
          lastPage: paginated.lastPage,
          total: paginated.total,
          perPage: paginated.perPage,
        ),
      ),
      onError: (failure) => Result.error(failure),
    );
  }

  @override
  Future<Result<ComplaintEntity>> getComplaintDetail(String id) {
    return _remoteDataSource.getComplaintDetail(id);
  }

  @override
  Future<Result<ComplaintEntity>> submitComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    List<File>? attachments,
  }) {
    return _remoteDataSource.submitComplaint(
      title: title,
      description: description,
      category: category,
      priority: priority,
      attachments: attachments,
    );
  }

  @override
  Future<Result<ComplaintEntity>> forwardComplaint({
    required String id,
    required UserRole targetRole,
    required String remarks,
  }) {
    return _remoteDataSource.forwardComplaint(
      id: id,
      targetRole: targetRole,
      remarks: remarks,
    );
  }

  @override
  Future<Result<ComplaintEntity>> resolveComplaint({
    required String id,
    required String remarks,
  }) {
    return _remoteDataSource.resolveComplaint(id: id, remarks: remarks);
  }

  @override
  Future<Result<ComplaintEntity>> rejectComplaint({
    required String id,
    required String remarks,
  }) {
    return _remoteDataSource.rejectComplaint(id: id, remarks: remarks);
  }

  @override
  Future<Result<ComplaintEntity>> returnComplaint({
    required String id,
    required String remarks,
  }) {
    return _remoteDataSource.returnComplaint(id: id, remarks: remarks);
  }

  @override
  Future<Result<RemarkEntity>> addRemark({
    required String complaintId,
    required String content,
    bool isOfficial = false,
  }) {
    return _remoteDataSource.addRemark(
      complaintId: complaintId,
      content: content,
      isOfficial: isOfficial,
    );
  }
}
