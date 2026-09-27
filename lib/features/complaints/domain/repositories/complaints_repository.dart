import 'dart:io';
import '../../../../core/utils/result.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/models/paginated_response.dart';
import '../entities/complaint_entity.dart';
import '../entities/remark_entity.dart';

abstract class ComplaintsRepository {
  Future<Result<PaginatedResponse<ComplaintEntity>>> getComplaints({
    int page = 1,
    ComplaintStatus? status,
    PriorityLevel? priority,
    String? category,
    String? search,
    bool myComplaintsOnly = false,
  });

  Future<Result<ComplaintEntity>> getComplaintDetail(String id);

  Future<Result<ComplaintEntity>> submitComplaint({
    required String title,
    required String description,
    required String category,
    required PriorityLevel priority,
    List<File>? attachments,
  });

  Future<Result<ComplaintEntity>> forwardComplaint({
    required String id,
    required UserRole targetRole,
    required String remarks,
  });

  Future<Result<ComplaintEntity>> resolveComplaint({
    required String id,
    required String remarks,
  });

  Future<Result<ComplaintEntity>> rejectComplaint({
    required String id,
    required String remarks,
  });

  Future<Result<ComplaintEntity>> returnComplaint({
    required String id,
    required String remarks,
  });

  Future<Result<RemarkEntity>> addRemark({
    required String complaintId,
    required String content,
    bool isOfficial = false,
  });
}
