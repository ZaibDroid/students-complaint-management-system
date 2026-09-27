import 'dart:io';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/models/paginated_response.dart';
import '../entities/complaint_entity.dart';
import '../entities/remark_entity.dart';
import '../repositories/complaints_repository.dart';

class GetComplaintsUseCase {
  final ComplaintsRepository _repository;
  GetComplaintsUseCase(this._repository);

  Future<Result<PaginatedResponse<ComplaintEntity>>> call({
    int page = 1,
    ComplaintStatus? status,
    PriorityLevel? priority,
    String? category,
    String? search,
    bool myComplaintsOnly = false,
  }) {
    return _repository.getComplaints(
      page: page,
      status: status,
      priority: priority,
      category: category,
      search: search,
      myComplaintsOnly: myComplaintsOnly,
    );
  }
}

class GetComplaintDetailUseCase {
  final ComplaintsRepository _repository;
  GetComplaintDetailUseCase(this._repository);

  Future<Result<ComplaintEntity>> call(String id) {
    return _repository.getComplaintDetail(id);
  }
}

class SubmitComplaintUseCase {
  final ComplaintsRepository _repository;
  SubmitComplaintUseCase(this._repository);

  Future<Result<ComplaintEntity>> call({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    List<File>? attachments,
  }) {
    return _repository.submitComplaint(
      title: title,
      description: description,
      category: category,
      priority: priority,
      attachments: attachments,
    );
  }
}

class ForwardComplaintUseCase {
  final ComplaintsRepository _repository;
  ForwardComplaintUseCase(this._repository);

  Future<Result<ComplaintEntity>> call({
    required String id,
    required UserRole targetRole,
    required String remarks,
  }) {
    return _repository.forwardComplaint(id: id, targetRole: targetRole, remarks: remarks);
  }
}

class ResolveComplaintUseCase {
  final ComplaintsRepository _repository;
  ResolveComplaintUseCase(this._repository);

  Future<Result<ComplaintEntity>> call({
    required String id,
    required String remarks,
  }) {
    return _repository.resolveComplaint(id: id, remarks: remarks);
  }
}

class RejectComplaintUseCase {
  final ComplaintsRepository _repository;
  RejectComplaintUseCase(this._repository);

  Future<Result<ComplaintEntity>> call({
    required String id,
    required String remarks,
  }) {
    return _repository.rejectComplaint(id: id, remarks: remarks);
  }
}

class ReturnComplaintUseCase {
  final ComplaintsRepository _repository;
  ReturnComplaintUseCase(this._repository);

  Future<Result<ComplaintEntity>> call({
    required String id,
    required String remarks,
  }) {
    return _repository.returnComplaint(id: id, remarks: remarks);
  }
}

class AddRemarkUseCase {
  final ComplaintsRepository _repository;
  AddRemarkUseCase(this._repository);

  Future<Result<RemarkEntity>> call({
    required String complaintId,
    required String content,
    bool isOfficial = false,
  }) {
    return _repository.addRemark(complaintId: complaintId, content: content, isOfficial: isOfficial);
  }
}
