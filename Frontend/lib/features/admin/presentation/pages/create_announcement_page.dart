import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../complaints/presentation/widgets/file_upload_box.dart';
import '../../../notice_board/presentation/providers/notice_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notice_board/data/models/notice_model.dart';
import '../../../batch/presentation/providers/batch_provider.dart';

class CreateAnnouncementPage extends ConsumerStatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  ConsumerState<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends ConsumerState<CreateAnnouncementPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'General Announcement';

  // Filters
  bool _broadcastToAll = false;
  final Set<String> _selectedRoles = {'Student'};
  bool _onlyToCRs = false;
  final Set<String> _selectedBatches = {};
  final Set<String> _selectedSections = {};

  final List<PlatformFile> _selectedFiles = [];

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitAnnouncement() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a title and description')));
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    List<String>? targetRoles;
    if (!_broadcastToAll && _selectedRoles.isNotEmpty) {
      targetRoles = _selectedRoles.toList();
    }

    final notice = NoticeModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      tag: _category,
      createdAt: DateTime.now(),
      senderId: user.id,
      senderName: user.name,
      targetRoles: targetRoles,
      targetCRsOnly: (!_broadcastToAll && _selectedRoles.contains('Student')) ? _onlyToCRs : false,
      targetBatches: (!_broadcastToAll && _selectedRoles.contains('Student') && _selectedBatches.isNotEmpty) ? _selectedBatches.toList() : null,
      targetSections: (!_broadcastToAll && _selectedRoles.contains('Student') && _selectedSections.isNotEmpty) ? _selectedSections.toList() : null,
    );

    try {
      final images = _selectedFiles.map((f) => File(f.path!)).toList();
      await ref.read(noticeRepositoryProvider).publishNotice(notice, images: images);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement Broadcasted!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172548))),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ANNOUNCEMENT TITLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Mandatory Meeting for Final Year Students',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                    initialValue: _category,
                    items: ['General Announcement', 'Academic', 'Urgent', 'Events', 'Administrative', 'Internship', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('MESSAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter the announcement details...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('ATTACHMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  FileUploadBox(onTap: _pickImages),
                  if (_selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedFiles.asMap().entries.map((entry) {
                        int idx = entry.key;
                        PlatformFile file = entry.value;
                        return Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              width: 150,
                              child: Row(
                                children: [
                                  const Icon(Icons.insert_drive_file, color: Colors.blue, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => _removeFile(idx),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Filters Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.radar, color: Color(0xFF4F46E5)),
                      SizedBox(width: 8),
                      Text('Target Audience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Broadcast to All
                  Container(
                    decoration: BoxDecoration(
                      color: _broadcastToAll ? const Color(0xFFEEF2FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _broadcastToAll ? const Color(0xFF4F46E5) : Colors.grey.shade300),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        value: _broadcastToAll,
                        onChanged: (val) {
                          setState(() {
                            _broadcastToAll = val ?? true;
                            if (_broadcastToAll) {
                              _selectedRoles.clear();
                              _onlyToCRs = false;
                              _selectedBatches.clear();
                              _selectedSections.clear();
                            }
                          });
                        },
                        title: const Text('Broadcast to Everyone', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Sends to all students and staff members in the department.'),
                        activeColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  if (!_broadcastToAll) ...[
                    const SizedBox(height: 24),
                    const Text('SPECIFIC ROLES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Student', 'Batch Adviser', 'Coordinator', 'Office', 'Dean'].map((role) {
                        final isSelected = _selectedRoles.contains(role);
                        return FilterChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedRoles.add(role);
                              } else {
                                _selectedRoles.remove(role);
                                if (role == 'Student') {
                                  _onlyToCRs = false;
                                  _selectedBatches.clear();
                                  _selectedSections.clear();
                                }
                              }
                            });
                          },
                          selectedColor: const Color(0xFFEEF2FF),
                          checkmarkColor: const Color(0xFF4F46E5),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF4F46E5) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300),
                          ),
                        );
                      }).toList(),
                    ),

                    if (_selectedRoles.contains('Student')) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STUDENT FILTERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                            const SizedBox(height: 12),
                            Material(
                              color: Colors.transparent,
                              child: CheckboxListTile(
                                value: _onlyToCRs,
                                onChanged: (val) => setState(() => _onlyToCRs = val ?? false),
                                title: const Text('Send only to Class Representatives (CRs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                activeColor: const Color(0xFF4F46E5),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Batches', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 8),
                            batchesAsync.when(
                              data: (batches) {
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: batches.map((b) {
                                    final isSelected = _selectedBatches.contains(b.name);
                                    return FilterChip(
                                      label: Text(b.name),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedBatches.add(b.name);
                                          } else {
                                            _selectedBatches.remove(b.name);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (e, st) => const Text('Error loading batches'),
                            ),
                            const SizedBox(height: 16),
                            const Text('Sections', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 8),
                            batchesAsync.when(
                              data: (batches) {
                                // Extract all unique sections from all batches just to show them,
                                // or if specific batches are selected, only show their sections.
                                Set<String> availableSections = {};
                                if (_selectedBatches.isEmpty) {
                                  for (var b in batches) {
                                    availableSections.addAll(b.sections);
                                  }
                                } else {
                                  for (var b in batches.where((b) => _selectedBatches.contains(b.name))) {
                                    availableSections.addAll(b.sections);
                                  }
                                }

                                if (availableSections.isEmpty) {
                                  return const Text('No sections found.', style: TextStyle(color: Colors.grey));
                                }

                                final sortedSections = availableSections.toList()..sort();
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: sortedSections.map((s) {
                                    final isSelected = _selectedSections.contains(s);
                                    return FilterChip(
                                      label: Text(s),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedSections.add(s);
                                          } else {
                                            _selectedSections.remove(s);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (e, st) => const Text('Error loading sections'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submitAnnouncement,
                icon: const Icon(Icons.send),
                label: const Text('Send Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF010F32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
