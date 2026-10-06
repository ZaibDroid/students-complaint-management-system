import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../core/services/api_client.dart';

final availableStaffProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users/staff');
    if (data is List) {
      final staffList = data.map((item) {
        final map = item as Map<String, dynamic>;
        return {
          'id': (map['id'] ?? '').toString(),
          'name': map['name'] ?? 'Unknown',
          'role': map['role']?.toString() ?? 'Staff',
        };
      }).toList();

      final rolesStr = staffList.map((s) => (s['role'] as String).toLowerCase()).toList();
      
      if (!rolesStr.any((r) => r.contains('chairman'))) {
        staffList.add({'id': 'mock_chairman_id', 'name': 'Chairman (Pending Setup)', 'role': 'Chairman'});
      }
      if (!rolesStr.any((r) => r.contains('dean'))) {
        staffList.add({'id': 'mock_dean_id', 'name': 'Dean (Pending Setup)', 'role': 'Dean'});
      }
      if (!rolesStr.any((r) => r.contains('department office'))) {
        staffList.add({'id': 'mock_dept_office_id', 'name': 'Department Office (Pending Setup)', 'role': 'Department Office'});
      }
      if (!rolesStr.any((r) => r.contains('vice chancellor'))) {
        staffList.add({'id': 'mock_vc_id', 'name': 'Vice Chancellor (Pending Setup)', 'role': 'Vice Chancellor'});
      }

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

  void _confirmTransfer() async {
    if (_selectedStaffId == null || _selectedStaffName == null) return;
    
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add remarks or feedback before forwarding.'),
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
      assignedTo: _selectedStaffName, // Save raw name for involvedStaff logic
      newInvolvedStaff: [_selectedStaffName!], // Add new recipient to tracking array
    );

    if (mounted) {
      Navigator.pop(context); // close loading
      if (success) {
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
    final currentUserRole = ref.watch(authStateProvider).value?.role ?? '';
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
                    Text('Transferring Complaint #${widget.complaint.id.substring(0, 6).toUpperCase()}', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 32),

                const Text('AVAILABLE STAFF MEMBERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                
                staffAsync.when(
                  data: (staffList) {
                    if (staffList.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No staff members available for forwarding.'),
                      );
                    }
                    
                    return Column(
                      children: staffList.where((staff) {
                        final roleStr = (staff['role'] as String).toLowerCase();
                        final currentUserRoleLower = currentUserRole.toLowerCase();
                        
                        // Prevent users from forwarding to their own role
                        if (currentUserRoleLower == roleStr) {
                          return false;
                        }
                        
                        // Dean: Show Chairman and Vice Chancellor
                        if (currentUserRoleLower.contains('dean')) {
                          if (roleStr.contains('chairman') || roleStr.contains('vice chancellor')) {
                            return true;
                          }
                          return false;
                        }
                        // Chairman: Only show Dean and Department Office
                        else if (currentUserRoleLower.contains('chairman')) {
                          if (roleStr.contains('dean') || roleStr.contains('department office')) {
                            return true;
                          }
                          return false;
                        } 
                        // Others (Coordinator, Adviser): Only show Coordinator and Chairman
                        else {
                          if (roleStr.contains('coordinator') || roleStr.contains('chairman')) {
                            return true;
                          }
                          return false;
                        }
                      }).map((staff) {


                        final isSelected = _selectedStaffId == staff['id'];
                        
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
                                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                    child: Icon(Icons.person, color: theme.primaryColor, size: 28),
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
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${staff['role']}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
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
                    Text('ADDITIONAL COMMENTS ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                    Text('*', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add instructions, reasons for forwarding, or any contextual notes...',
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
