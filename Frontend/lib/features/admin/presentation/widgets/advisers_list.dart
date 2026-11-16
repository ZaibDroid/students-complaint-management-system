import 'package:flutter/material.dart';
import '../../../../features/auth/domain/entities/user.dart';
import 'edit_faculty_dialog.dart';
import 'handover_dialog.dart';
import 'delete_adviser_dialog.dart';

class AdvisersList extends StatelessWidget {
  final List<User> advisers;
  final String? emptyMessage;

  const AdvisersList({
    super.key,
    required this.advisers,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (advisers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            emptyMessage ?? 'No batch advisers registered yet.',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: advisers.length,
      itemBuilder: (context, index) {
        final adviser = advisers[index];
        String batchDisplay = '';
        String sectionDisplay = '';

        if (adviser.assignedSections != null && adviser.assignedSections!.isNotEmpty) {
          final batches = adviser.assignedSections!
              .map((s) => s['batch']?.toString())
              .where((b) => b != null && b.isNotEmpty && b != 'N/A')
              .toSet()
              .join(', ');
          final sections = adviser.assignedSections!
              .map((s) => s['section']?.toString())
              .where((sec) => sec != null && sec.isNotEmpty && sec != 'N/A')
              .toSet()
              .join(', ');

          batchDisplay = batches.isNotEmpty ? batches : (adviser.batch ?? '');
          sectionDisplay = sections.isNotEmpty ? sections : (adviser.section ?? '');
        } else {
          batchDisplay = adviser.batch ?? '';
          sectionDisplay = adviser.section ?? '';
        }

        batchDisplay = batchDisplay.replaceAll('Batch Batch', 'Batch').trim();
        if (batchDisplay.isNotEmpty && !batchDisplay.toLowerCase().startsWith('batch')) {
          batchDisplay = 'Batch $batchDisplay';
        }

        final isAssigned = batchDisplay.isNotEmpty || sectionDisplay.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name, Email, and Assigned Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: theme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adviser.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF010F32),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          adviser.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAssigned ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAssigned ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAssigned ? Icons.check_circle : Icons.error_outline,
                          size: 13,
                          color: isAssigned ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAssigned ? 'Assigned' : 'Not Assigned',
                          style: TextStyle(
                            color: isAssigned ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Batch row
              Row(
                children: [
                  Icon(Icons.school_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Batch: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  Text(
                    batchDisplay.isNotEmpty ? batchDisplay : 'Not Assigned',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: batchDisplay.isNotEmpty ? const Color(0xFF010F32) : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Section row
              Row(
                children: [
                  Icon(Icons.view_module_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Section: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  if (sectionDisplay.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        sectionDisplay.toLowerCase().startsWith('section')
                            ? sectionDisplay
                            : 'Section $sectionDisplay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Not Assigned',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => HandoverDialog(
                          oldAdviser: adviser,
                          allAdvisers: advisers,
                        ),
                      );
                    },
                    icon: const Icon(Icons.transfer_within_a_station, size: 16),
                    label: const Text('Transfer'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditFacultyDialog(adviser: adviser),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteAdviserDialog(
                          adviserToDelete: adviser,
                          allAdvisers: advisers,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
