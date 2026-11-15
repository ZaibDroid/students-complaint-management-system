import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/adviser_assignment.dart';
import '../../data/repositories/adviser_assignment_repository.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';

final batchAdvisersStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  return ref.watch(adviserAssignmentRepositoryProvider).getBatchAdvisers();
});

/// Checks whether a given [adviser] is specifically assigned to the [student]'s batch and section.
bool doesAdviserMatchStudent(User adviser, User student) {
  final studentBatch = student.batch?.trim() ?? '';
  final studentSection = student.section?.trim() ?? '';
  if (studentBatch.isEmpty) return false;

  final studentYear = extractBatchYear(studentBatch);
  final studentSecNorm = normalizeSectionName(studentSection);

  // 1. Check assignedSections list
  if (adviser.assignedSections != null && adviser.assignedSections!.isNotEmpty) {
    for (final sec in adviser.assignedSections!) {
      final aBatch = sec['batch']?.toString().trim() ?? '';
      final aSec = (sec['section'] ?? sec['name'])?.toString().trim() ?? '';

      final aYear = extractBatchYear(aBatch);
      final aSecNorm = normalizeSectionName(aSec);

      final batchMatches = (studentYear != null && aYear != null && studentYear == aYear) ||
          (aBatch.isNotEmpty && aBatch.toLowerCase() == studentBatch.toLowerCase());

      final secMatches = studentSecNorm.isEmpty || aSecNorm.isEmpty || (studentSecNorm == aSecNorm);

      if (batchMatches && secMatches) {
        return true;
      }
    }
  }

  // 2. Check adviser's direct batch & section fields
  if (adviser.batch != null && adviser.batch!.trim().isNotEmpty) {
    final aYear = extractBatchYear(adviser.batch!);
    final aSecNorm = normalizeSectionName(adviser.section);

    final batchMatches = (studentYear != null && aYear != null && studentYear == aYear) ||
        (adviser.batch!.trim().toLowerCase() == studentBatch.toLowerCase());

    final secMatches = studentSecNorm.isEmpty || aSecNorm.isEmpty || (studentSecNorm == aSecNorm);

    if (batchMatches && secMatches) {
      return true;
    }
  }

  return false;
}

String? extractBatchYear(String? input) {
  if (input == null || input.isEmpty) return null;
  final match = RegExp(r'\b(20\d{2})\b').firstMatch(input);
  if (match != null) return match.group(1);
  return null;
}

String normalizeSectionName(String? sec) {
  if (sec == null) return '';
  return sec
      .replaceAll(RegExp(r'(section|sec|\s|-)', caseSensitive: false), '')
      .toUpperCase();
}

final studentMatchingAdvisersProvider = Provider.autoDispose.family<List<User>, User>((ref, student) {
  final advisers = ref.watch(batchAdvisersStreamProvider).value ?? [];
  return advisers.where((a) => doesAdviserMatchStudent(a, student)).toList();
});

final adviserAssignmentsProvider = Provider.autoDispose<List<AdviserAssignment>>((ref) {
  final advisersAsync = ref.watch(batchAdvisersStreamProvider);
  final batchesAsync = ref.watch(batchesStreamProvider);
  
  final advisers = advisersAsync.value ?? [];
  final batches = batchesAsync.value ?? [];

  final List<AdviserAssignment> list = [];

  for (var batch in batches) {
    for (var sec in batch.sections) {
      // Find if an adviser has this batch and section in their assignedSections
      final matchedAdviser = advisers.firstWhere(
        (a) {
          final batchYear = int.tryParse(batch.name);
          final batchNo = (batchYear != null && batchYear >= 2018) ? (batchYear - 2017).toString() : '';

          if (a.assignedSections != null && a.assignedSections!.isNotEmpty) {
            final matchesAssigned = a.assignedSections!.any((assignment) {
              final aBatch = assignment['batch']?.toString();
              final aSec = assignment['section']?.toString();
              final sameSec = (aSec != null && aSec.toUpperCase() == sec.toUpperCase());
              final sameBatch = aBatch == batch.name || (batchNo.isNotEmpty && aBatch == batchNo);
              return sameBatch && sameSec;
            });
            if (matchesAssigned) return true;
          }

          final sameSec = a.section != null && a.section!.toUpperCase() == sec.toUpperCase();
          final sameBatch = a.batch == batch.name || (batchNo.isNotEmpty && a.batch == batchNo);
          return sameBatch && sameSec;
        },
        orElse: () => User(id: '', name: '', email: '', role: 'Batch Adviser'),
      );

      list.add(AdviserAssignment(
        semester: batch.name,
        section: sec,
        adviserId: matchedAdviser.id.isEmpty ? null : matchedAdviser.id,
        adviserName: matchedAdviser.id.isEmpty ? null : matchedAdviser.name,
      ));
    }
  }
  return list;
});

class AdviserAssignmentNotifier extends AsyncNotifier<void> {
  late final AdviserAssignmentRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(adviserAssignmentRepositoryProvider);
  }

  Future<bool> assign({
    String? adviserId,
    required String semester,
    required String section,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.assignAdviser(
        adviserId: adviserId,
        semester: semester,
        section: section,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final assignAdviserActionProvider = AsyncNotifierProvider<AdviserAssignmentNotifier, void>(() {
  return AdviserAssignmentNotifier();
});

class SelectedAssignmentState {
  final String semester;
  final String section;
  SelectedAssignmentState({required this.semester, required this.section});
}

class SelectedAssignmentNotifier extends Notifier<SelectedAssignmentState> {
  @override
  SelectedAssignmentState build() {
    return SelectedAssignmentState(semester: '', section: '');
  }

  void select(String semester, String section) {
    state = SelectedAssignmentState(semester: semester, section: section);
  }
}

final selectedAssignmentProvider = NotifierProvider<SelectedAssignmentNotifier, SelectedAssignmentState>(() {
  return SelectedAssignmentNotifier();
});
