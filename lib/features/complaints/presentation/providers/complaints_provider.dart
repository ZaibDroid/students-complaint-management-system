import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/complaints/data/datasources/complaints_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/complaints/data/repositories/complaints_repository_impl.dart';
import 'package:student_complaint_managment_system/features/complaints/domain/entities/complaint_entity.dart';
import 'package:student_complaint_managment_system/features/complaints/domain/entities/remark_entity.dart';
import 'package:student_complaint_managment_system/features/complaints/domain/repositories/complaints_repository.dart';
import 'package:student_complaint_managment_system/features/complaints/domain/usecases/complaints_usecases.dart';
import 'package:student_complaint_managment_system/shared/enums/complaint_status.dart';
import 'package:student_complaint_managment_system/shared/enums/priority_level.dart';
import 'package:student_complaint_managment_system/shared/enums/user_role.dart';

// Dependency Providers
final complaintsRemoteDataSourceProvider = Provider<ComplaintsRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ComplaintsRemoteDataSourceImpl(api);
});

final complaintsRepositoryProvider = Provider<ComplaintsRepository>((ref) {
  final remote = ref.watch(complaintsRemoteDataSourceProvider);
  return ComplaintsRepositoryImpl(remote);
});

final getComplaintsUseCaseProvider = Provider<GetComplaintsUseCase>((ref) {
  return GetComplaintsUseCase(ref.watch(complaintsRepositoryProvider));
});

final getComplaintDetailUseCaseProvider = Provider<GetComplaintDetailUseCase>((ref) {
  return GetComplaintDetailUseCase(ref.watch(complaintsRepositoryProvider));
});

final submitComplaintUseCaseProvider = Provider<SubmitComplaintUseCase>((ref) {
  return SubmitComplaintUseCase(ref.watch(complaintsRepositoryProvider));
});

final forwardComplaintUseCaseProvider = Provider<ForwardComplaintUseCase>((ref) {
  return ForwardComplaintUseCase(ref.watch(complaintsRepositoryProvider));
});

final resolveComplaintUseCaseProvider = Provider<ResolveComplaintUseCase>((ref) {
  return ResolveComplaintUseCase(ref.watch(complaintsRepositoryProvider));
});

final rejectComplaintUseCaseProvider = Provider<RejectComplaintUseCase>((ref) {
  return RejectComplaintUseCase(ref.watch(complaintsRepositoryProvider));
});

final returnComplaintUseCaseProvider = Provider<ReturnComplaintUseCase>((ref) {
  return ReturnComplaintUseCase(ref.watch(complaintsRepositoryProvider));
});

final addRemarkUseCaseProvider = Provider<AddRemarkUseCase>((ref) {
  return AddRemarkUseCase(ref.watch(complaintsRepositoryProvider));
});

// Complaints List State
class ComplaintsListState {
  final bool isLoading;
  final List<ComplaintEntity> complaints;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final ComplaintStatus? selectedStatus;
  final PriorityLevel? selectedPriority;
  final String? selectedCategory;
  final String searchQuery;

  const ComplaintsListState({
    this.isLoading = false,
    this.complaints = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.selectedStatus,
    this.selectedPriority,
    this.selectedCategory,
    this.searchQuery = '',
  });

  ComplaintsListState copyWith({
    bool? isLoading,
    List<ComplaintEntity>? complaints,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    ComplaintStatus? selectedStatus,
    PriorityLevel? selectedPriority,
    String? selectedCategory,
    String? searchQuery,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return ComplaintsListState(
      isLoading: isLoading ?? this.isLoading,
      complaints: complaints ?? this.complaints,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      selectedStatus: clearFilters ? null : (selectedStatus ?? this.selectedStatus),
      selectedPriority: clearFilters ? null : (selectedPriority ?? this.selectedPriority),
      selectedCategory: clearFilters ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ComplaintsListNotifier extends StateNotifier<ComplaintsListState> {
  final GetComplaintsUseCase _getComplaintsUseCase;
  final bool _isStudent;

  ComplaintsListNotifier(
    this._getComplaintsUseCase,
    this._isStudent,
  ) : super(const ComplaintsListState()) {
    fetchComplaints();
  }

  Future<void> fetchComplaints({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true, currentPage: page);

    final result = await _getComplaintsUseCase(
      page: page,
      status: state.selectedStatus,
      priority: state.selectedPriority,
      category: state.selectedCategory,
      search: state.searchQuery,
      myComplaintsOnly: _isStudent,
    );

    result.when(
      onSuccess: (paginated) {
        state = state.copyWith(
          isLoading: false,
          complaints: paginated.items,
          currentPage: paginated.currentPage,
          totalPages: paginated.lastPage,
          clearError: true,
        );
      },
      onError: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    fetchComplaints(page: 1);
  }

  void applyFilters({
    ComplaintStatus? status,
    PriorityLevel? priority,
    String? category,
  }) {
    state = state.copyWith(
      selectedStatus: status,
      selectedPriority: priority,
      selectedCategory: category,
    );
    fetchComplaints(page: 1);
  }

  void resetFilters() {
    state = state.copyWith(clearFilters: true);
    fetchComplaints(page: 1);
  }
}

final complaintsListProvider = StateNotifierProvider<ComplaintsListNotifier, ComplaintsListState>((ref) {
  final useCase = ref.watch(getComplaintsUseCaseProvider);
  final userRole = ref.watch(authProvider).user?.role;
  final isStudent = userRole == UserRole.student || userRole == UserRole.cr;
  return ComplaintsListNotifier(useCase, isStudent);
});

// Single Complaint Detail State
class ComplaintDetailState {
  final bool isLoading;
  final ComplaintEntity? complaint;
  final String? errorMessage;
  final bool isSubmittingAction;

  const ComplaintDetailState({
    this.isLoading = false,
    this.complaint,
    this.errorMessage,
    this.isSubmittingAction = false,
  });

  ComplaintDetailState copyWith({
    bool? isLoading,
    ComplaintEntity? complaint,
    String? errorMessage,
    bool? isSubmittingAction,
    bool clearError = false,
  }) {
    return ComplaintDetailState(
      isLoading: isLoading ?? this.isLoading,
      complaint: complaint ?? this.complaint,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmittingAction: isSubmittingAction ?? this.isSubmittingAction,
    );
  }
}

class ComplaintDetailNotifier extends StateNotifier<ComplaintDetailState> {
  final GetComplaintDetailUseCase _getDetailUseCase;
  final ForwardComplaintUseCase _forwardUseCase;
  final ResolveComplaintUseCase _resolveUseCase;
  final RejectComplaintUseCase _rejectUseCase;
  final ReturnComplaintUseCase _returnUseCase;
  final AddRemarkUseCase _addRemarkUseCase;

  ComplaintDetailNotifier(
    this._getDetailUseCase,
    this._forwardUseCase,
    this._resolveUseCase,
    this._rejectUseCase,
    this._returnUseCase,
    this._addRemarkUseCase,
  ) : super(const ComplaintDetailState());

  Future<void> loadComplaint(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getDetailUseCase(id);

    result.when(
      onSuccess: (complaint) {
        state = state.copyWith(isLoading: false, complaint: complaint, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  Future<bool> forward(String id, UserRole targetRole, String remarks) async {
    state = state.copyWith(isSubmittingAction: true, clearError: true);
    final result = await _forwardUseCase(id: id, targetRole: targetRole, remarks: remarks);

    return result.when(
      onSuccess: (updated) {
        state = state.copyWith(isSubmittingAction: false, complaint: updated);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSubmittingAction: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> resolve(String id, String remarks) async {
    state = state.copyWith(isSubmittingAction: true, clearError: true);
    final result = await _resolveUseCase(id: id, remarks: remarks);

    return result.when(
      onSuccess: (updated) {
        state = state.copyWith(isSubmittingAction: false, complaint: updated);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSubmittingAction: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> reject(String id, String remarks) async {
    state = state.copyWith(isSubmittingAction: true, clearError: true);
    final result = await _rejectUseCase(id: id, remarks: remarks);

    return result.when(
      onSuccess: (updated) {
        state = state.copyWith(isSubmittingAction: false, complaint: updated);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSubmittingAction: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> returnBack(String id, String remarks) async {
    state = state.copyWith(isSubmittingAction: true, clearError: true);
    final result = await _returnUseCase(id: id, remarks: remarks);

    return result.when(
      onSuccess: (updated) {
        state = state.copyWith(isSubmittingAction: false, complaint: updated);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSubmittingAction: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> addRemark(String id, String content, bool isOfficial) async {
    state = state.copyWith(isSubmittingAction: true, clearError: true);
    final result = await _addRemarkUseCase(complaintId: id, content: content, isOfficial: isOfficial);

    return result.when(
      onSuccess: (remark) {
        if (state.complaint != null) {
          final updatedRemarks = List<RemarkEntity>.from(state.complaint!.remarks)..add(remark);
          final updatedComplaint = ComplaintEntity(
            id: state.complaint!.id,
            trackingNumber: state.complaint!.trackingNumber,
            title: state.complaint!.title,
            description: state.complaint!.description,
            category: state.complaint!.category,
            status: state.complaint!.status,
            priority: state.complaint!.priority,
            studentId: state.complaint!.studentId,
            studentName: state.complaint!.studentName,
            studentEmail: state.complaint!.studentEmail,
            batch: state.complaint!.batch,
            section: state.complaint!.section,
            currentHandlerRole: state.complaint!.currentHandlerRole,
            currentHandlerName: state.complaint!.currentHandlerName,
            attachmentUrls: state.complaint!.attachmentUrls,
            timeline: state.complaint!.timeline,
            remarks: updatedRemarks,
            createdAt: state.complaint!.createdAt,
            updatedAt: DateTime.now(),
            resolvedAt: state.complaint!.resolvedAt,
          );
          state = state.copyWith(isSubmittingAction: false, complaint: updatedComplaint);
        } else {
          state = state.copyWith(isSubmittingAction: false);
        }
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSubmittingAction: false, errorMessage: failure.message);
        return false;
      },
    );
  }
}

final complaintDetailProvider = StateNotifierProvider.family<ComplaintDetailNotifier, ComplaintDetailState, String>((ref, id) {
  final notifier = ComplaintDetailNotifier(
    ref.watch(getComplaintDetailUseCaseProvider),
    ref.watch(forwardComplaintUseCaseProvider),
    ref.watch(resolveComplaintUseCaseProvider),
    ref.watch(rejectComplaintUseCaseProvider),
    ref.watch(returnComplaintUseCaseProvider),
    ref.watch(addRemarkUseCaseProvider),
  );
  notifier.loadComplaint(id);
  return notifier;
});
