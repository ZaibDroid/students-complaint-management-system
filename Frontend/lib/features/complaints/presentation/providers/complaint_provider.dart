import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/complaint_model.dart';
import '../../data/repositories/api_complaint_repository.dart';

final apiComplaintRepositoryProvider = Provider<ApiComplaintRepository>((ref) {
  return ApiComplaintRepository();
});

final complaintRepositoryProvider = apiComplaintRepositoryProvider;

// Provides the list of complaints submitted by the currently logged-in student.
class StudentComplaintsNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  FutureOr<List<ComplaintModel>> build() async {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null || user.role.toLowerCase() != 'student') {
      return [];
    }
    
    final repository = ref.watch(apiComplaintRepositoryProvider);
    return repository.getComplaints();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(apiComplaintRepositoryProvider);
      return repository.getComplaints();
    });
  }
}

final studentComplaintsProvider = AsyncNotifierProvider<StudentComplaintsNotifier, List<ComplaintModel>>(StudentComplaintsNotifier.new);

// Provides the list of complaints assigned to the logged-in staff's department.
class DepartmentComplaintsNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  FutureOr<List<ComplaintModel>> build() async {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null || user.role.toLowerCase() == 'student') {
      return [];
    }
    
    final repository = ref.watch(apiComplaintRepositoryProvider);
    return repository.getComplaints();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(apiComplaintRepositoryProvider);
      return repository.getComplaints();
    });
  }
}

final departmentComplaintsProvider = AsyncNotifierProvider<DepartmentComplaintsNotifier, List<ComplaintModel>>(DepartmentComplaintsNotifier.new);

// Provides the list of all complaints in the system (typically for Admins)
class AllComplaintsNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  FutureOr<List<ComplaintModel>> build() async {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null || user.role.toLowerCase() != 'admin') {
      return [];
    }
    
    final repository = ref.watch(apiComplaintRepositoryProvider);
    return repository.getComplaints();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(apiComplaintRepositoryProvider);
      return repository.getComplaints();
    });
  }
}

final allComplaintsProvider = AsyncNotifierProvider<AllComplaintsNotifier, List<ComplaintModel>>(AllComplaintsNotifier.new);

// AsyncNotifier for submitting a complaint to handle loading state from UI
class SubmitComplaintNotifier extends AsyncNotifier<void> {
  late final ApiComplaintRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(apiComplaintRepositoryProvider);
  }

  Future<bool> submit(ComplaintModel complaint, {File? attachment}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitComplaint(complaint, attachment: attachment);
      state = const AsyncValue.data(null);
      // Automatically refresh complaints lists so UI is instantly updated
      await ref.read(studentComplaintsProvider.notifier).refresh();
      ref.invalidate(allComplaintsProvider);
      ref.invalidate(departmentComplaintsProvider);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
  
  Future<bool> updateStatus(
    String complaintId,
    String status,
    String remarks, {
    String? assignedToId,
    String? assignedTo,
    List<String>? newInvolvedStaff,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateComplaintStatus(
        complaintId,
        status,
        adminRemarks: remarks,
        assignedToId: assignedToId,
        assignedTo: assignedTo,
        newInvolvedStaff: newInvolvedStaff,
      );
      state = const AsyncValue.data(null);
      await ref.read(studentComplaintsProvider.notifier).refresh();
      await ref.read(departmentComplaintsProvider.notifier).refresh();
      await ref.read(allComplaintsProvider.notifier).refresh();
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final submitComplaintProvider = AsyncNotifierProvider<SubmitComplaintNotifier, void>(SubmitComplaintNotifier.new);
