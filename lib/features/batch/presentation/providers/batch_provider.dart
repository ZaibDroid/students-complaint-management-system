import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/batch/data/datasources/batch_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/batch/data/repositories/batch_repository_impl.dart';
import 'package:student_complaint_managment_system/features/batch/domain/entities/batch_entity.dart';
import 'package:student_complaint_managment_system/features/batch/domain/repositories/batch_repository.dart';
import 'package:student_complaint_managment_system/features/batch/domain/usecases/batch_usecases.dart';

final batchRemoteDataSourceProvider = Provider<BatchRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return BatchRemoteDataSourceImpl(api);
});

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  final remote = ref.watch(batchRemoteDataSourceProvider);
  return BatchRepositoryImpl(remote);
});

final getBatchesUseCaseProvider = Provider<GetBatchesUseCase>((ref) {
  return GetBatchesUseCase(ref.watch(batchRepositoryProvider));
});

final requestAdviserUseCaseProvider = Provider<RequestAdviserUseCase>((ref) {
  return RequestAdviserUseCase(ref.watch(batchRepositoryProvider));
});

class BatchState {
  final bool isLoading;
  final List<BatchEntity> batches;
  final String? errorMessage;
  final bool isSubmittingRequest;

  const BatchState({
    this.isLoading = false,
    this.batches = const [],
    this.errorMessage,
    this.isSubmittingRequest = false,
  });

  BatchState copyWith({
    bool? isLoading,
    List<BatchEntity>? batches,
    String? errorMessage,
    bool? isSubmittingRequest,
    bool clearError = false,
  }) {
    return BatchState(
      isLoading: isLoading ?? this.isLoading,
      batches: batches ?? this.batches,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmittingRequest: isSubmittingRequest ?? this.isSubmittingRequest,
    );
  }
}

class BatchNotifier extends StateNotifier<BatchState> {
  final GetBatchesUseCase _getBatchesUseCase;
  final RequestAdviserUseCase _requestAdviserUseCase;

  BatchNotifier(
    this._getBatchesUseCase,
    this._requestAdviserUseCase,
  ) : super(const BatchState()) {
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getBatchesUseCase();

    result.when(
      onSuccess: (batches) {
        state = state.copyWith(isLoading: false, batches: batches, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  Future<bool> requestMeeting(String reason) async {
    state = state.copyWith(isSubmittingRequest: true, clearError: true);
    final result = await _requestAdviserUseCase(reason: reason);

    return result.when(
      onSuccess: (_) {
        state = state.copyWith(isSubmittingRequest: false);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isSubmittingRequest: false, errorMessage: failure.message);
        return false;
      },
    );
  }
}

final batchProvider = StateNotifierProvider<BatchNotifier, BatchState>((ref) {
  return BatchNotifier(
    ref.watch(getBatchesUseCaseProvider),
    ref.watch(requestAdviserUseCaseProvider),
  );
});
