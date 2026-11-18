import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UpdatePersonalInfoDialog extends ConsumerStatefulWidget {
  final User user;

  const UpdatePersonalInfoDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, User user) {
    return showDialog(
      context: context,
      builder: (_) => UpdatePersonalInfoDialog(user: user),
    );
  }

  @override
  ConsumerState<UpdatePersonalInfoDialog> createState() => _UpdatePersonalInfoDialogState();
}

class _UpdatePersonalInfoDialogState extends ConsumerState<UpdatePersonalInfoDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _batchController;
  late final TextEditingController _departmentController;

  static const List<String> _semesters = [
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8',
  ];
  static const List<String> _sections = ['A', 'B', 'C', 'D', 'E', 'F'];

  String? _selectedYear;
  String? _selectedSection;
  bool _isUpdating = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _batchController = TextEditingController(text: user.batch ?? '');
    _departmentController = TextEditingController(text: user.department ?? '');

    final currentSemStr = (user.year ?? user.semester ?? '').trim();
    for (final y in _semesters) {
      if (currentSemStr.toLowerCase() == y.toLowerCase() ||
          (currentSemStr.isNotEmpty &&
              currentSemStr.replaceAll(RegExp(r'[^0-9]'), '') == y.replaceAll(RegExp(r'[^0-9]'), ''))) {
        _selectedYear = y;
        break;
      }
    }

    _selectedSection = _sections.contains(user.section)
        ? user.section
        : (user.section != null && user.section!.isNotEmpty ? _sections.first : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _batchController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _isUpdating = true);
        await ref.read(apiAuthRepositoryProvider).uploadProfileImage(widget.user.id, File(pickedFile.path));
        await ref.read(authStateProvider.notifier).refreshUser();
        if (mounted) {
          Navigator.pop(context); // Close dialog so user sees updated image on profile
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _handleSave() async {
    final user = widget.user;
    if (_nameController.text.trim().isEmpty) return;

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newBatch = _batchController.text.trim();
    final newDepartment = _departmentController.text.trim();

    final userSemNumber = (user.year ?? user.semester ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final selectedSemNumber = (_selectedYear ?? '').replaceAll(RegExp(r'[^0-9]'), '');

    // Check if any data actually changed
    bool hasChanges = newName != user.name ||
        newPhone != (user.phone ?? '') ||
        userSemNumber != selectedSemNumber ||
        newBatch != (user.batch ?? '') ||
        (_selectedSection ?? '') != (user.section ?? '');

    if (user.role != 'Student') {
      hasChanges = hasChanges || newDepartment != (user.department ?? '');
    }

    if (!hasChanges) {
      Navigator.pop(context);
      return; // Exit early to save resources and latency
    }

    setState(() => _isUpdating = true);
    try {
      final finalBatch = user.role == 'Batch Adviser' ? (user.batch ?? '') : newBatch;
      final finalSection = user.role == 'Batch Adviser' ? (user.section ?? '') : (_selectedSection ?? '');
      await ref.read(apiAuthRepositoryProvider).updatePersonalInfo(
            user.id,
            name: newName,
            year: _selectedYear ?? '',
            batch: finalBatch,
            section: finalSection,
            phone: newPhone,
            department: user.role != 'Student' ? newDepartment : null,
          );
      await ref.read(authStateProvider.notifier).refreshUser();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Info updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Update Personal Info'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                    child: user.profileImageUrl == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            if (user.role == 'Student') ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedYear,
                items: _semesters.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedYear = val),
                decoration: const InputDecoration(labelText: 'Semester'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _batchController,
                decoration: const InputDecoration(labelText: 'Batch No.'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSection,
                items: _sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedSection = val),
                decoration: const InputDecoration(labelText: 'Section'),
              ),
            ] else ...[
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department Name',
                  hintText: 'e.g. Computer Science or CS',
                ),
              ),
              const SizedBox(height: 12),
              if (user.role == 'Batch Adviser' || user.role == 'Coordinator') ...[
                TextField(
                  controller: _batchController,
                  enabled: user.role != 'Batch Adviser',
                  decoration: InputDecoration(
                    labelText: user.role == 'Coordinator' ? 'Coordinating Batch No.' : 'Advising Batch No.',
                    helperText: user.role == 'Batch Adviser' ? 'Assigned by Coordinator (Read-only)' : null,
                    suffixIcon: user.role == 'Batch Adviser' ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey) : null,
                    filled: user.role == 'Batch Adviser',
                    fillColor: user.role == 'Batch Adviser' ? const Color(0xFFF1F5F9) : null,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                if (user.role == 'Batch Adviser')
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSection,
                    items: _sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: null,
                    decoration: const InputDecoration(
                      labelText: 'Advising Section',
                      helperText: 'Assigned by Coordinator (Read-only)',
                      suffixIcon: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFFF1F5F9),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _handleSave,
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

