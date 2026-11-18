import 'package:flutter/material.dart';
import '../../../../features/auth/domain/entities/user.dart';
import 'edit_faculty_dialog.dart';
import 'delete_adviser_dialog.dart';

class CoordinatorsList extends StatelessWidget {
  final List<User> coordinators;
  final String? emptyMessage;

  const CoordinatorsList({
    super.key,
    required this.coordinators,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (coordinators.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            emptyMessage ?? 'No department coordinators registered yet.',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: coordinators.length,
      itemBuilder: (context, index) {
        final coordinator = coordinators[index];

        String batchDisplay = (coordinator.batch ?? '').trim();
        batchDisplay = batchDisplay.replaceAll('Batch Batch', 'Batch').trim();
        if (batchDisplay.isNotEmpty && !batchDisplay.toLowerCase().startsWith('batch')) {
          batchDisplay = 'Batch $batchDisplay';
        }
        if (batchDisplay.isEmpty) {
          batchDisplay = 'Batch Not Assigned';
        }

        final isAssigned = coordinator.batch != null && coordinator.batch!.trim().isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar Header: Shows Batch No / Year
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF010F32),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          batchDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Coordinator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body: Details & Actions
              Padding(
                padding: const EdgeInsets.all(16),
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
                                coordinator.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF010F32),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coordinator.email,
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
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 12),

                    // Bottom Action Buttons: Edit on Left, Delete on Right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditFacultyDialog(adviser: coordinator),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Coordinator', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF172548),
                            backgroundColor: const Color(0xFF172548).withValues(alpha: 0.07),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => DeleteAdviserDialog(
                                adviserToDelete: coordinator,
                                allAdvisers: coordinators,
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
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
}

