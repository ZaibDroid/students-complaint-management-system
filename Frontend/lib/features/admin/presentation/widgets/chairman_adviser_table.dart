import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';
import '../../../../features/batch/domain/entities/batch_model.dart';
import '../../../../features/admin/presentation/providers/adviser_assignment_provider.dart';
import '../../../../features/admin/presentation/providers/coordinator_provider.dart';

class ChairmanAdviserTable extends ConsumerWidget {
  const ChairmanAdviserTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesStreamProvider);
    final coordinatorsAsync = ref.watch(coordinatorsStreamProvider);
    final assignments = ref.watch(adviserAssignmentsProvider);
    final advisersAsync = ref.watch(batchAdvisersStreamProvider);

    final coordinators = coordinatorsAsync.value ?? [];
    final allAdvisers = advisersAsync.value ?? [];

    return batchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading assignments: $err', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(batchesStreamProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (batches) {
        if (batches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No Batches Available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No academic batches have been configured yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate statistics
        int totalSections = 0;
        int assignedCount = 0;
        for (final b in batches) {
          totalSections += b.sections.length;
          for (final s in b.sections) {
            final isAssigned = assignments.any((a) {
              final matchBatch = a.semester == b.name ||
                  a.semester.contains(b.name) ||
                  b.name.contains(a.semester);
              final matchSec = a.section.toUpperCase() == s.toUpperCase() ||
                  a.section.toUpperCase() == 'SECTION $s'.toUpperCase();
              return matchBatch && matchSec && a.adviserId != null;
            });
            if (isAssigned) assignedCount++;
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(batchesStreamProvider);
            ref.invalidate(coordinatorsStreamProvider);
            ref.invalidate(adviserAssignmentsProvider);
            ref.invalidate(batchAdvisersStreamProvider);
            await ref.read(batchesStreamProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Operational Overview Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MASTER ADVISER OVERVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildOverviewStat('Batches', '${batches.length}', Icons.layers_rounded),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 14)),
                        _buildOverviewStat('Sections', '$totalSections', Icons.grid_view_rounded),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 14)),
                        _buildOverviewStat('Assigned', '$assignedCount', Icons.check_circle_outline),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 14)),
                        _buildOverviewStat('Pending', '${totalSections - assignedCount}', Icons.warning_amber_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Batch Tables List
              for (int bIndex = 0; bIndex < batches.length; bIndex++) ...[
                _buildBatchTableCard(
                  context,
                  ref,
                  batches[bIndex],
                  coordinators,
                  assignments,
                  allAdvisers,
                ),
                const SizedBox(height: 18),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.white60),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchTableCard(
    BuildContext context,
    WidgetRef ref,
    BatchModel batch,
    List<dynamic> coordinators,
    List<dynamic> assignments,
    List<dynamic> allAdvisers,
  ) {
    final cleanBatchYear = batch.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();

    // Match coordinator for this batch
    final coordinator = coordinators.where((c) {
      if (c.batchId != null && c.batchId.toString().isNotEmpty && c.batchId.toString() == batch.id) return true;
      if (c.batch != null && c.batch.toString().isNotEmpty) {
        final cBatchClean = c.batch.toString().replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim().toLowerCase();
        final bClean = cleanBatchYear.toLowerCase();
        if (cBatchClean == bClean || bClean.contains(cBatchClean) || cBatchClean.contains(bClean)) return true;
      }
      return false;
    }).firstOrNull;

    final coordinatorName = coordinator?.name ?? 'Not Assigned';
    final isCoordinatorAssigned = coordinator != null;

    // Sort sections in alphabetical order
    final sortedSections = List<String>.from(batch.sections)
      ..sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar: Batch Year & Coordinator Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF172548), Color(0xFF223563)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch $cleanBatchYear',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isCoordinatorAssigned ? Icons.person : Icons.person_outline,
                            color: isCoordinatorAssigned ? Colors.lightGreenAccent : Colors.orangeAccent,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Coordinator: $coordinatorName',
                              style: TextStyle(
                                color: isCoordinatorAssigned ? Colors.lightGreenAccent : Colors.orangeAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subheader: Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('SECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text('ASSIGNED BATCH ADVISER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ),
                Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ],
            ),
          ),

          // Section Rows
          if (sortedSections.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open_rounded, size: 36, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text(
                      'No sections created for this batch yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedSections.length,
              separatorBuilder: (context, sIdx) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, sIdx) {
                final section = sortedSections[sIdx];

                // Match assignment
                final assignment = assignments.where((a) {
                  final matchBatch = a.semester == batch.name ||
                      a.semester.contains(batch.name) ||
                      batch.name.contains(a.semester);
                  final matchSec = a.section.toUpperCase() == section.toUpperCase() ||
                      a.section.toUpperCase() == 'SECTION $section'.toUpperCase();
                  return matchBatch && matchSec;
                }).firstOrNull;

                final secDetail = batch.sectionItems
                    .where((si) => si.name.toUpperCase() == section.toUpperCase() || si.name.toUpperCase() == 'SECTION $section'.toUpperCase())
                    .firstOrNull;

                final currentAdviserId = assignment?.adviserId ?? secDetail?.adviserId;
                final isAssigned = currentAdviserId != null && currentAdviserId.toString().isNotEmpty;

                // Match adviser details
                String adviserName = 'Not Assigned';
                String? adviserEmail;
                if (isAssigned) {
                  final adviserUser = allAdvisers.where((adv) => adv.id.toString() == currentAdviserId.toString()).firstOrNull;
                  adviserName = assignment?.adviserName ?? secDetail?.adviserName ?? adviserUser?.name ?? 'Assigned';
                  adviserEmail = adviserUser?.email;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: sIdx.isEven ? Colors.white : const Color(0xFFFBFBFD),
                  child: Row(
                    children: [
                      // Section Badge
                      Container(
                        width: 44,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF172548).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF172548).withValues(alpha: 0.15)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          section,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172548),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Adviser Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isAssigned ? Icons.check_circle : Icons.warning_amber_rounded,
                                  size: 15,
                                  color: isAssigned ? Colors.green.shade600 : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    adviserName,
                                    style: TextStyle(
                                      fontWeight: isAssigned ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 14,
                                      color: isAssigned ? const Color(0xFF0F172A) : Colors.orange.shade800,
                                      fontStyle: isAssigned ? FontStyle.normal : FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (isAssigned && adviserEmail != null && adviserEmail.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 21, top: 2),
                                child: Text(
                                  adviserEmail,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Status Badge (View-only)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAssigned ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAssigned ? Colors.green.shade200 : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAssigned ? Colors.green.shade600 : Colors.orange.shade600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isAssigned ? 'Assigned' : 'Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAssigned ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
