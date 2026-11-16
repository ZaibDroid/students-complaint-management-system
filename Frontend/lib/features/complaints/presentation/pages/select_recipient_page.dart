import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/presentation/pages/adviser_dashboard_page.dart';

import '../../../../core/services/api_client.dart';

final availableStaffProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users/staff', queryParams: {'per_page': '100'});
    if (data is List) {
      final staffList = data.map((item) {
        final map = item as Map<String, dynamic>;
        return {
          'id': (map['id'] ?? '').toString(),
          'name': map['name'] ?? 'Unknown',
          'role': map['role']?.toString() ?? 'Staff',
        };
      }).where((staff) => staff['id']!.isNotEmpty && !staff['id']!.startsWith('mock_')).toList();

      yield staffList;
    } else {
      yield [];
    }
  } catch (_) {
    yield [];
  }
});

class SelectRecipientPage extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const SelectRecipientPage({super.key, required this.complaint});

  @override
  ConsumerState<SelectRecipientPage> createState() => _SelectRecipientPageState();
}

class _SelectRecipientPageState extends ConsumerState<SelectRecipientPage> {
  String? _selectedStaffId;
  String? _selectedStaffName;
  final TextEditingController _commentController = TextEditingController();
  String? _commentError;

  void _confirmTransfer() async {
    if (_selectedStaffId == null || _selectedStaffName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recipient faculty member first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      setState(() => _commentError = 'Remarks are compulsory before forwarding.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remarks / comments are compulsory before forwarding this complaint.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    final remarks = commentText;

    final success = await ref.read(submitComplaintProvider.notifier).updateStatus(
      widget.complaint.id,
      'forwarded',
      remarks,
      assignedToId: _selectedStaffId,
      assignedTo: _selectedStaffName, // Save raw name for involvedStaff logic
      newInvolvedStaff: [_selectedStaffName!], // Add new recipient to tracking array
    );

    if (mounted) {
      Navigator.pop(context); // close loading
      if (success) {
        ref.invalidate(adviserComplaintsProvider);
        ref.invalidate(departmentComplaintsProvider);
        ref.invalidate(allComplaintsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case transferred successfully!')),
        );
        context.pop(); // go back to previous dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to transfer case')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffAsync = ref.watch(availableStaffProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Forward Complaint', style: TextStyle(color: Color(0xFF010F32), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF010F32)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(label: Text('STEP 3 OF 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFEFEDF1)),
                    Text('BATCH ACTION', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Select Recipient', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF010F32))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.swap_horiz, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      'Transferring Complaint #${widget.complaint.ticketNumber ?? (widget.complaint.id.length > 6 ? widget.complaint.id.substring(0, 6).toUpperCase() : widget.complaint.id)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text('AVAILABLE STAFF MEMBERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                
                staffAsync.when(
                  data: (staffList) {
                    final currentUserId = ref.watch(authStateProvider).value?.id.toString() ?? '';
                    final currentUserRole = ref.watch(authStateProvider).value?.role.toLowerCase() ?? '';
                    final isBatchAdviser = currentUserRole.contains('adviser') || currentUserRole.contains('advisor');
                    final isCoordinator = currentUserRole.contains('coordinator');
                    final isChairman = currentUserRole.contains('chairman') || currentUserRole.contains('chair');

                    final filteredStaff = staffList.where((staff) {
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
                      // Allowed: Coordinator, Chairman
                      // Excluded: Other Batch Advisers, Dean, VC, Office staff, Admin
                      if (isBatchAdviser) {
                        final isCoord = roleStr.contains('coordinator');
                        final isChair = roleStr.contains('chairman') || roleStr.contains('chair');
                        if (!isCoord && !isChair) {
                          return false;
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

                        // If it's an adviser role, match the one who sent/handled this complaint
                        if (isAdviserRole) {
                          final involved = widget.complaint.involvedStaffNames;
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

                    filteredStaff.sort((a, b) {
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

                    if (filteredStaff.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No staff members available for forwarding.'),
                      );
                    }
                    
                    return Column(
                      children: filteredStaff.map((staff) {
                        final isSelected = _selectedStaffId == staff['id'];
                        final isAdviserSendBack = isCoordinator && 
                            ((staff['role'] as String).toLowerCase().contains('adviser') || (staff['role'] as String).toLowerCase().contains('advisor'));
                        final isOffice = (staff['role'] as String).toLowerCase().contains('office');
                        
                        String roleLabel = staff['role'];
                        if (isAdviserSendBack) {
                          roleLabel = 'Batch Adviser (Send Back)';
                        } else if (isOffice) {
                          roleLabel = 'Department Office (${staff['role']})';
                        }
                        
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedStaffId = staff['id'];
                            _selectedStaffName = staff['name'];
                          }),
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : Colors.white,
                                border: Border.all(
                                  color: isSelected ? theme.primaryColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: theme.primaryColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: isAdviserSendBack 
                                        ? Colors.amber.shade50 
                                        : theme.primaryColor.withValues(alpha: 0.1),
                                    child: Icon(
                                      isAdviserSendBack 
                                          ? Icons.undo_rounded 
                                          : (isOffice ? Icons.desk : Icons.person), 
                                      color: isAdviserSendBack ? Colors.amber.shade800 : theme.primaryColor, 
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                            if (isAdviserSendBack)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade100,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  'Send Back',
                                                  style: TextStyle(
                                                    color: Colors.amber.shade900,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(roleLabel, style: TextStyle(color: isAdviserSendBack ? Colors.amber.shade800 : theme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // ignore: deprecated_member_use
                                  Radio<String>(
                                    value: staff['id'],
                                    // ignore: deprecated_member_use
                                    groupValue: _selectedStaffId,
                                    activeColor: theme.primaryColor,
                                    // ignore: deprecated_member_use
                                    onChanged: (val) => setState(() {
                                      _selectedStaffId = val!;
                                      _selectedStaffName = staff['name'];
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                
                
                // Restriction note removed based on user request
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Text('REMARKS / REASON FOR FORWARDING ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                    Text('*', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  onChanged: (val) {
                    if (_commentError != null && val.trim().isNotEmpty) {
                      setState(() => _commentError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter compulsory remarks explaining why this complaint is being forwarded...',
                    errorText: _commentError,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 12)
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TARGET RECIPIENT:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.1)),
                    Text(_selectedStaffName ?? 'None Selected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _selectedStaffName != null ? theme.primaryColor : Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedStaffId == null ? null : _confirmTransfer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Confirm Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
