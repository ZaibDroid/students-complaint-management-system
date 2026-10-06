import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/complaint_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/complaint_provider.dart';

class ComplaintDetailsPage extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailsPage({super.key, required this.complaint});

  @override
  ConsumerState<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends ConsumerState<ComplaintDetailsPage> {
  String _getCurrentLocation() {
    if (widget.complaint.status.toLowerCase() == 'pending') {
      return 'Batch Adviser';
    } else if (widget.complaint.status.toLowerCase() == 'forwarded') {
      final assignedTo = widget.complaint.assignedTo ?? '';
      final RegExp roleExp = RegExp(r'\((.*?)\)');
      final match = roleExp.firstMatch(assignedTo);
      if (match != null) {
        return match.group(1)!;
      }
      return assignedTo.isNotEmpty ? assignedTo : 'Coordinator/Chairman';
    } else if (widget.complaint.status.toLowerCase() == 'resolved') {
      return 'Resolved';
    } else if (widget.complaint.status.toLowerCase() == 'rejected') {
      return 'Rejected';
    }
    return 'Unknown';
  }

  void _showActionDialog(BuildContext context, String actionType) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${actionType == 'resolved' ? 'Resolve' : 'Reject'} Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide remarks/comments for this action:'),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Enter comments...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim().isEmpty 
                    ? (actionType == 'resolved' ? 'Issue resolved by administration' : 'Invalid complaint')
                    : commentController.text.trim();
                
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                
                final success = await ref.read(submitComplaintProvider.notifier).updateStatus(widget.complaint.id, actionType, comment);
                
                if (context.mounted) {
                  Navigator.pop(context); // close loading
                  Navigator.pop(context); // close dialog
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complaint $actionType successfully.')));
                    context.pop(); // go back
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed.')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: actionType == 'resolved' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider).value;
    final isStaff = authState != null && authState.role != 'Student';
    final isActionable = widget.complaint.status == 'pending' || widget.complaint.status == 'forwarded';
    final currentUserRole = authState?.role.toLowerCase() ?? '';
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${widget.complaint.id.length > 8 ? widget.complaint.id.substring(0, 8).toUpperCase() : widget.complaint.id}',
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.complaint.status == 'resolved' ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.complaint.status.toUpperCase(),
                    style: TextStyle(
                      color: widget.complaint.status == 'resolved' ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              widget.complaint.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Meta info
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${widget.complaint.createdAt.year}-${widget.complaint.createdAt.month.toString().padLeft(2, '0')}-${widget.complaint.createdAt.day.toString().padLeft(2, '0')} ${widget.complaint.createdAt.hour.toString().padLeft(2, '0')}:${widget.complaint.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.complaint.category,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Current Location
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Location',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _getCurrentLocation(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.complaint.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Admin Remarks (if any)
            if (widget.complaint.adminRemarks != null && widget.complaint.adminRemarks!.isNotEmpty) ...[
              const Text(
                'Admin Remarks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.complaint.adminRemarks!,
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.blue.shade900),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Attachments
            if (widget.complaint.attachments.isNotEmpty) ...[
              const Text(
                'Attachments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.complaint.attachments.length,
                itemBuilder: (context, index) {
                  final attachment = widget.complaint.attachments[index];
                  // If it's a base64 data URL
                  if (attachment.startsWith('data:image')) {
                    final base64Str = attachment.split(',').last;
                    try {
                      final bytes = base64Decode(base64Str);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } catch (e) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Failed to load image.'),
                      );
                    }
                  }
                  return const SizedBox.shrink(); // Not an image URL or unsupported format
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: isStaff && isActionable ? SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/select_recipient', extra: widget.complaint),
                  icon: const Icon(Icons.forward_to_inbox),
                  label: Text(currentUserRole.contains('chairman')
                      ? 'Forward to Dean / Dept Office'
                      : 'Forward to Chairman / Coordinator'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showActionDialog(context, 'rejected'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showActionDialog(context, 'resolved'),
                      icon: const Icon(Icons.check),
                      label: const Text('Resolve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ) : null,
    );
  }
}
