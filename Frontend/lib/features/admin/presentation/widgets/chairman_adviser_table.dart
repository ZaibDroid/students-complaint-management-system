import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';
import '../../../../features/admin/presentation/providers/adviser_assignment_provider.dart';

class ChairmanAdviserTable extends ConsumerWidget {
  const ChairmanAdviserTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesStreamProvider);
    final assignments = ref.watch(adviserAssignmentsProvider);

    return batchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading assignments: $err')),
      data: (batches) {
        if (batches.isEmpty) {
          return const Center(child: Text('No batches data available.', style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: batches.length,
          separatorBuilder: (context, index) => const Divider(thickness: 3, color: Colors.black87, height: 40),
          itemBuilder: (context, index) {
            final batch = batches[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF172548),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_ind, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Batch ${batch.name} - Assignments',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                      columns: const [
                        DataColumn(label: Text('Section', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Assigned Adviser', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        for (var section in batch.sections)
                          DataRow(
                            cells: [
                              DataCell(Text(section, style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Builder(
                                builder: (context) {
                                  final assignment = assignments.firstWhere(
                                    (a) => a.semester == batch.name && a.section == section,
                                    orElse: () => throw Exception('Assignment not found'),
                                  );
                                  final isAssigned = assignment.adviserId != null;
                                  return isAssigned
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                            const SizedBox(width: 4),
                                            Text(assignment.adviserName ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          ],
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                                            SizedBox(width: 4),
                                            Text('Not Assigned', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
                                          ],
                                        );
                                },
                              )),
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
      },
    );
  }
}
