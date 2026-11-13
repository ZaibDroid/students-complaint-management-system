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
        final hasAssignedSections = adviser.assignedSections != null && adviser.assignedSections!.isNotEmpty;
        final isAssigned = hasAssignedSections || (adviser.batch != null && adviser.batch!.isNotEmpty);

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
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
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
                    constraints: const BoxConstraints(maxWidth: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          isAssigned ? Icons.check_circle_outline : Icons.error_outline,
                          size: 14,
                          color: isAssigned ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isAssigned 
                                ? (hasAssignedSections 
                                    ? adviser.assignedSections!.map((s) {
                                        final b = (s['batch'] != null && s['batch'].toString().isNotEmpty && s['batch'] != 'N/A') ? 'Batch ${s['batch']}' : 'Batch';
                                        final sec = (s['section'] != null && s['section'].toString().isNotEmpty && s['section'] != 'N/A') ? ' (${s['section']})' : '';
                                        return '$b$sec';
                                      }).join(', ')
                                    : '${adviser.semester ?? adviser.batch ?? 'Assigned'} (${adviser.section ?? ''})')
                                : 'Not Assigned',
                            style: TextStyle(
                              color: isAssigned ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
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
                    icon: const Icon(Icons.transfer_within_a_station, size: 18),
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
                    icon: const Icon(Icons.edit, size: 18),
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
                    icon: const Icon(Icons.delete, size: 18),
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
