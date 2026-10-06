import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import 'api_complaint_repository.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository();
});

class ComplaintRepository {
  final ApiComplaintRepository _apiRepository;

  ComplaintRepository([ApiComplaintRepository? apiRepository])
      : _apiRepository = apiRepository ?? ApiComplaintRepository();

  Future<String> submitComplaint(ComplaintModel complaint,
          {File? attachment}) =>
      _apiRepository.submitComplaint(complaint, attachment: attachment);

  Future<ComplaintModel?> getComplaintById(String id) =>
      _apiRepository.getComplaintById(id);

  Stream<List<ComplaintModel>> streamStudentComplaints(String studentId) =>
      _apiRepository.streamStudentComplaints(studentId);

  Stream<List<ComplaintModel>> streamDepartmentComplaints(
          {String? department, String? adviserName, bool isOffice = false}) =>
      _apiRepository.streamDepartmentComplaints(
          department: department, adviserName: adviserName, isOffice: isOffice);

  Stream<List<ComplaintModel>> streamAllComplaints() =>
      _apiRepository.streamAllComplaints();

  Future<void> updateComplaintStatus(
    String id,
    String newStatus, {
    String? adminRemarks,
    String? assignedToId,
    String? assignedTo,
    List<String>? newInvolvedStaff,
  }) =>
      _apiRepository.updateComplaintStatus(
        id,
        newStatus,
        adminRemarks: adminRemarks,
        assignedToId: assignedToId,
        assignedTo: assignedTo,
        newInvolvedStaff: newInvolvedStaff,
      );
}
