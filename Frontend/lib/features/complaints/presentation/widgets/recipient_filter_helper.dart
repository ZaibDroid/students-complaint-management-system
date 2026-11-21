import '../../data/models/complaint_model.dart';

/// Helper to handle recipient resolution, filtering, and priority sorting for complaint forwarding.
class RecipientFilterHelper {
  /// Resolves the authoritative assigned Coordinator ID for the complaint.
  static String? resolveTargetCoordinatorId({
    required List<Map<String, dynamic>> staffList,
    required String? assignedCoordinatorId,
    required String? studentBatchId,
  }) {
    if (assignedCoordinatorId != null && assignedCoordinatorId.isNotEmpty) {
      return assignedCoordinatorId;
    }
    if (studentBatchId != null) {
      for (final s in staffList) {
        final sRole = (s['role'] as String).toLowerCase();
        if (sRole.contains('coordinator')) {
          final bIds = s['coordinated_batch_ids'] as List<String>? ?? [];
          if (bIds.contains(studentBatchId)) {
            return s['id'];
          }
        }
      }
    }
    return null;
  }

  /// Filters and sorts staff members according to departmental forwarding hierarchy rules.
  static List<Map<String, dynamic>> filterAndSortRecipients({
    required List<Map<String, dynamic>> staffList,
    required String currentUserId,
    required String currentUserRole,
    required ComplaintModel complaint,
    required String? targetCoordId,
  }) {
    final isBatchAdviser = currentUserRole.contains('adviser') || currentUserRole.contains('advisor');
    final isCoordinator = currentUserRole.contains('coordinator');
    final isChairman = currentUserRole.contains('chairman') || currentUserRole.contains('chair');
    final hasAssignedCoordinator = targetCoordId != null && targetCoordId.isNotEmpty;

    final filtered = staffList.where((staff) {
      final staffId = staff['id'];
      final roleStr = (staff['role'] as String).toLowerCase();

      // Prevent users from forwarding to their own user account
      if (staffId == currentUserId) {
        return false;
      }

      // Students / CRs cannot be recipients of forwarded complaints
      if (roleStr.contains('student') || roleStr == 'cr' || roleStr.contains('representative')) {
        return false;
      }

      // If current user is a Batch Adviser:
      // Allowed: ONLY the Coordinator assigned to this complaint's batch, plus Chairman
      // Excluded: Coordinators of other batches, other Batch Advisers, Dean, VC, Office staff, Admin
      if (isBatchAdviser) {
        final isCoord = roleStr.contains('coordinator');
        final isChair = roleStr.contains('chairman') || roleStr.contains('chair');
        if (!isCoord && !isChair) {
          return false;
        }

        if (isCoord) {
          if (!hasAssignedCoordinator || staffId != targetCoordId) {
            return false;
          }
        }
      }

      // If current user is a Coordinator:
      // Allowed:
      // 1. Batch Adviser who sent it (or batch advisers)
      // 2. Chairman
      // 3. Office of the Department (created by admin)
      // Excluded: Dean, VC, other Coordinators, Admin
      if (isCoordinator) {
        final isAdviserRole = roleStr.contains('adviser') || roleStr.contains('advisor');
        final isChairmanRole = roleStr.contains('chairman') || roleStr.contains('chair');
        final isOfficeRole = roleStr.contains('office');

        if (!isAdviserRole && !isChairmanRole && !isOfficeRole) {
          return false;
        }

        if (isAdviserRole) {
          final involved = complaint.involvedStaffNames;
          if (involved.isNotEmpty) {
            final staffNameClean = (staff['name'] as String).toLowerCase().replaceAll('dr.', '').trim();
            final hasInvolvedAdviser = staffList.any((s) {
              final sRole = (s['role'] as String).toLowerCase();
              final sName = (s['name'] as String).toLowerCase().replaceAll('dr.', '').trim();
              return (sRole.contains('adviser') || sRole.contains('advisor')) &&
                  involved.any((inv) => inv.toLowerCase().replaceAll('dr.', '').trim() == sName);
            });

            if (hasInvolvedAdviser) {
              final isSender = involved.any((inv) => inv.toLowerCase().replaceAll('dr.', '').trim() == staffNameClean);
              if (!isSender) return false;
            }
          }
        }
      }

      // If current user is Chairman:
      // Allowed: Dean, Office of the Department, Coordinator
      if (isChairman) {
        final isDeanRole = roleStr.contains('dean');
        final isOfficeRole = roleStr.contains('office');
        final isCoord = roleStr.contains('coordinator');
        if (!isDeanRole && !isOfficeRole && !isCoord) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      int priority(String r) {
        final lower = r.toLowerCase();
        if (isCoordinator) {
          if (lower.contains('adviser') || lower.contains('advisor')) return 1;
          if (lower.contains('chair')) return 2;
          if (lower.contains('office')) return 3;
          return 4;
        } else if (isBatchAdviser) {
          if (lower.contains('coordinator')) return 1;
          if (lower.contains('chair')) return 2;
          return 3;
        } else if (isChairman) {
          if (lower.contains('office')) return 1;
          if (lower.contains('dean')) return 2;
          if (lower.contains('coordinator')) return 3;
          return 4;
        }
        return 5;
      }

      final pA = priority(a['role'] as String);
      final pB = priority(b['role'] as String);
      if (pA != pB) return pA.compareTo(pB);
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return filtered;
  }
}

