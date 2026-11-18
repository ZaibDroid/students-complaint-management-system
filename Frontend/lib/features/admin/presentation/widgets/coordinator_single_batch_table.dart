import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';
import '../../../../features/batch/data/repositories/batch_repository.dart';
import '../../../../features/batch/domain/entities/batch_model.dart';
import '../providers/adviser_assignment_provider.dart';
import 'assign_section_adviser_dialog.dart';

class CoordinatorSingleBatchTable extends ConsumerWidget {
  const CoordinatorSingleBatchTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final batchesAsync = ref.watch(batchesStreamProvider);
    final assignments = ref.watch(adviserAssignmentsProvider);
    final advisersAsync = ref.watch(batchAdvisersStreamProvider);
    final allAdvisers = advisersAsync.value ?? [];

    return batchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading batch data: $err', style: const TextStyle(color: Colors.red)),
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
        // Find the coordinator's assigned batch
        BatchModel? myBatch;
        if (user != null) {
          myBatch = batches.where((b) {
            if (user.batchId != null && user.batchId!.isNotEmpty && b.id == user.batchId) {
              return true;
            }
            if (user.batch != null && user.batch!.isNotEmpty) {
              final userBatchClean = user.batch!.trim().toLowerCase();
              final batchNameClean = b.name.trim().toLowerCase();
              if (userBatchClean == batchNameClean) return true;
              if (batchNameClean.contains(userBatchClean) || userBatchClean.contains(batchNameClean)) return true;
            }
            return false;
          }).firstOrNull;
        }

        // Fallback: If coordinator has only one batch in system or user has no batch assigned
        if (myBatch == null && user?.batch != null && user!.batch!.isNotEmpty) {
          // Coordinator has an assigned batch name, but no matching BatchModel yet in DB
          return _buildUninitializedBatchView(context, ref, user.batch!);
        }

        if (myBatch == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment_late_outlined, size: 48, color: Colors.amber.shade800),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Batch Assigned',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are not currently assigned to a specific batch.\nPlease contact the Department Chairman to assign your batch.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(batchesStreamProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                  ),
                ],
              ),
            ),
          );
        }

        final batch = myBatch;
        final cleanBatchYear = batch.name.replaceAll(RegExp(r'^Batch\s+', caseSensitive: false), '').trim();
        final sortedSections = List<String>.from(batch.sections)
          ..sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));
        final totalSections = sortedSections.length;
        int assignedCount = 0;
        for (final sec in batch.sections) {
          final isAssigned = assignments.any((a) {
            final matchBatch = a.semester == batch.name ||
                a.semester.contains(batch.name) ||
                batch.name.contains(a.semester);
            final matchSec = a.section.toUpperCase() == sec.toUpperCase() ||
                a.section.toUpperCase() == 'SECTION $sec'.toUpperCase();
            return matchBatch && matchSec && a.adviserId != null;
          });
          if (isAssigned) assignedCount++;
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(batchesStreamProvider);
            ref.invalidate(adviserAssignmentsProvider);
            await ref.read(batchesStreamProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header Summary Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF172548), Color(0xFF253B73)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.school, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ASSIGNED BATCH',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Batch $cleanBatchYear',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Locked Batch Year indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 13, color: Colors.amberAccent),
                              SizedBox(width: 5),
                              Text(
                                'Year Fixed',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSummaryItem('Total Sections', '$totalSections', Icons.grid_view_rounded),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                        _buildSummaryItem('Advisers Assigned', '$assignedCount', Icons.check_circle_outline),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                        _buildSummaryItem('Unassigned', '${totalSections - assignedCount}', Icons.warning_amber_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Single Batch Table Container
              Container(
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
                    // Table Top Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.table_chart_outlined, color: Color(0xFF172548), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Sections & Batch Advisers',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blueGrey.shade900,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddSectionDialog(context, ref, batch),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF172548),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Body
                    if (batch.sections.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.folder_open_rounded, size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text(
                                'No sections in this batch yet.',
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _showAddSectionDialog(context, ref, batch),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Section'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
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
                                Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sortedSections.length,
                            separatorBuilder: (context, sIdx) => Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, sIdx) {
                              final section = sortedSections[sIdx];
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
                                    const SizedBox(width: 8),

                                    // Action Button: Assign / Change
                                    isAssigned
                                        ? OutlinedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AssignSectionAdviserDialog(
                                                  batchName: cleanBatchYear,
                                                  sectionName: section,
                                                  currentAdviserId: currentAdviserId.toString(),
                                                  sectionId: secDetail?.id,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.edit_outlined, size: 14),
                                            label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF172548),
                                              side: BorderSide(color: Colors.grey.shade300),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AssignSectionAdviserDialog(
                                                  batchName: cleanBatchYear,
                                                  sectionName: section,
                                                  currentAdviserId: null,
                                                  sectionId: secDetail?.id,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.person_add_alt_1, size: 14),
                                            label: const Text('Assign', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF172548),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          ),

                                    // Remove Section Button
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                                      tooltip: 'Remove Section $section',
                                      onPressed: () => _confirmRemoveSection(context, ref, batch, section),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUninitializedBatchView(BuildContext context, WidgetRef ref, String batchYear) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF172548).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.class_outlined, size: 48, color: Color(0xFF172548)),
            ),
            const SizedBox(height: 16),
            Text(
              'Batch $batchYear',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
            ),
            const SizedBox(height: 8),
            Text(
              'Your assigned batch has not been initialized with sections yet.\nClick below to initialize Batch $batchYear.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ref.read(batchRepositoryProvider).addBatch(name: batchYear, sections: ['A', 'B']);
                  ref.invalidate(batchesStreamProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Batch $batchYear initialized with sections A and B!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to initialize batch: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              icon: const Icon(Icons.playlist_add),
              label: const Text('Initialize Batch Sections', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF172548),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context, WidgetRef ref, BatchModel batch) async {
    final controller = TextEditingController();
    final newSection = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Section to Batch ${batch.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Section Letter',
            hintText: 'e.g. C',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim().toUpperCase()),
            child: const Text('Add Section'),
          ),
        ],
      ),
    );

    if (newSection != null && newSection.isNotEmpty) {
      final cleanSec = newSection.replaceAll(RegExp(r'^SECTION\s+', caseSensitive: false), '').trim();
      if (batch.sections.any((s) => s.toUpperCase() == cleanSec)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Section already exists in this batch.')),
          );
        }
      } else {
        try {
          final updatedBatch = BatchModel(
            id: batch.id,
            name: batch.name,
            sections: [...batch.sections, cleanSec],
          );
          await ref.read(batchRepositoryProvider).updateBatch(updatedBatch);
          ref.invalidate(batchesStreamProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Section $cleanSec added to Batch ${batch.name}!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add section: $e'), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  void _confirmRemoveSection(BuildContext context, WidgetRef ref, BatchModel batch, String section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Section?'),
        content: Text('Are you sure you want to remove section "$section" from Batch ${batch.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final newSections = batch.sections.where((s) => s != section).toList();
        final updatedBatch = BatchModel(id: batch.id, name: batch.name, sections: newSections);
        await ref.read(batchRepositoryProvider).updateBatch(updatedBatch);
        ref.invalidate(batchesStreamProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Section $section removed successfully.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove section: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

