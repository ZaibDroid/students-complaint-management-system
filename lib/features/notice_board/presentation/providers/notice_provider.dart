import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/notice_board/data/datasources/notice_remote_data_source.dart';
import 'package:student_complaint_managment_system/features/notice_board/data/repositories/notice_repository_impl.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/entities/notice_entity.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/repositories/notice_repository.dart';
import 'package:student_complaint_managment_system/features/notice_board/domain/usecases/notice_usecases.dart';
import 'package:student_complaint_managment_system/shared/enums/notice_target.dart';

final noticeRemoteDataSourceProvider = Provider<NoticeRemoteDataSource>((ref) {
  final api = ref.watch(apiServiceProvider);
  return NoticeRemoteDataSourceImpl(api);
});

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  final remote = ref.watch(noticeRemoteDataSourceProvider);
  return NoticeRepositoryImpl(remote);
});

final getNoticesUseCaseProvider = Provider<GetNoticesUseCase>((ref) {
  return GetNoticesUseCase(ref.watch(noticeRepositoryProvider));
});

final createNoticeUseCaseProvider = Provider<CreateNoticeUseCase>((ref) {
  return CreateNoticeUseCase(ref.watch(noticeRepositoryProvider));
});

final deleteNoticeUseCaseProvider = Provider<DeleteNoticeUseCase>((ref) {
  return DeleteNoticeUseCase(ref.watch(noticeRepositoryProvider));
});

class NoticeState {
  final bool isLoading;
  final List<NoticeEntity> notices;
  final String? errorMessage;
  final String searchQuery;
  final NoticeTarget? filterTarget;

  const NoticeState({
    this.isLoading = false,
    this.notices = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.filterTarget,
  });

  NoticeState copyWith({
    bool? isLoading,
    List<NoticeEntity>? notices,
    String? errorMessage,
    String? searchQuery,
    NoticeTarget? filterTarget,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return NoticeState(
      isLoading: isLoading ?? this.isLoading,
      notices: notices ?? this.notices,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      filterTarget: clearFilter ? null : (filterTarget ?? this.filterTarget),
    );
  }

  List<NoticeEntity> get filteredNotices {
    var list = notices;
    if (filterTarget != null) {
      list = list.where((n) => n.target == filterTarget).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((n) => n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q)).toList();
    }
    return list;
  }
}

class NoticeNotifier extends StateNotifier<NoticeState> {
  final GetNoticesUseCase _getNoticesUseCase;
  final CreateNoticeUseCase _createNoticeUseCase;
  final DeleteNoticeUseCase _deleteNoticeUseCase;

  NoticeNotifier(
    this._getNoticesUseCase,
    this._createNoticeUseCase,
    this._deleteNoticeUseCase,
  ) : super(const NoticeState()) {
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getNoticesUseCase();

    result.when(
      onSuccess: (notices) {
        state = state.copyWith(isLoading: false, notices: notices, clearError: true);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void filterByTarget(NoticeTarget? target) {
    state = state.copyWith(filterTarget: target, clearFilter: target == null);
  }

  Future<bool> createNotice({
    required String title,
    required String content,
    required NoticeTarget target,
    String? targetValue,
    bool isPinned = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _createNoticeUseCase(
      title: title,
      content: content,
      target: target,
      targetValue: targetValue,
      isPinned: isPinned,
    );

    return result.when(
      onSuccess: (notice) {
        final updated = List<NoticeEntity>.from(state.notices)..insert(0, notice);
        state = state.copyWith(isLoading: false, notices: updated);
        return true;
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> deleteNotice(String id) async {
    final result = await _deleteNoticeUseCase(id);
    return result.when(
      onSuccess: (_) {
        final updated = state.notices.where((n) => n.id != id).toList();
        state = state.copyWith(notices: updated);
        return true;
      },
      onError: (failure) => false,
    );
  }
}

final noticeProvider = StateNotifierProvider<NoticeNotifier, NoticeState>((ref) {
  return NoticeNotifier(
    ref.watch(getNoticesUseCaseProvider),
    ref.watch(createNoticeUseCaseProvider),
    ref.watch(deleteNoticeUseCaseProvider),
  );
});
