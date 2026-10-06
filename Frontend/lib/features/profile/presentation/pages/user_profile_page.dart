import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/presentation/providers/adviser_assignment_provider.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final bool isSubPage;

  const UserProfilePage({super.key, this.isSubPage = true});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  String? _selectedAdviser;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendAdviserRequest(String uid) async {
    if (_selectedAdviser == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(apiAuthRepositoryProvider).updateUserAdviser(uid, _selectedAdviser!);
      await ref.read(authStateProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickAndUploadImage(String uid) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _isSubmitting = true);
        await ref.read(apiAuthRepositoryProvider).uploadProfileImage(uid, File(pickedFile.path));
        await ref.read(authStateProvider.notifier).refreshUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated!')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showUpdatePersonalInfoDialog(User user) async {
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController phoneController = TextEditingController(text: user.phone ?? '');
    final TextEditingController batchController = TextEditingController(text: user.batch ?? '');
    final TextEditingController departmentController = TextEditingController(text: user.department ?? '');
    
    final List<String> years = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'];
    final List<String> sections = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    String? selectedYear = years.contains(user.year) ? user.year : (user.year != null && user.year!.isNotEmpty ? years.first : null);
    String? selectedSection = sections.contains(user.section) ? user.section : (user.section != null && user.section!.isNotEmpty ? sections.first : null);
    
    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Personal Info'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _pickAndUploadImage(user.id);
                        if (context.mounted) Navigator.pop(context); // Close dialog so they see the updated image on profile
                      },
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
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    if (user.role == 'Student') ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedYear,
                        items: years.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => selectedYear = val),
                        decoration: const InputDecoration(labelText: 'Semester'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: batchController,
                        decoration: const InputDecoration(labelText: 'Batch No.'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSection,
                        items: sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => selectedSection = val),
                        decoration: const InputDecoration(labelText: 'Section'),
                      ),
                    ] else ...[
                      TextField(
                        controller: departmentController,
                        decoration: const InputDecoration(labelText: 'Department Name'),
                      ),
                      const SizedBox(height: 12),
                      if (user.role == 'Batch Adviser' || user.role == 'Coordinator') ...[
                        TextField(
                          controller: batchController,
                          decoration: InputDecoration(labelText: user.role == 'Coordinator' ? 'Coordinating Batch No.' : 'Advising Batch No.'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        if (user.role == 'Batch Adviser')
                          DropdownButtonFormField<String>(
                            initialValue: selectedSection,
                            items: sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) => setState(() => selectedSection = val),
                            decoration: const InputDecoration(labelText: 'Advising Section'),
                          ),
                      ]
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUpdating ? null : () async {
                    if (nameController.text.trim().isEmpty) return;
                    
                    final newName = nameController.text.trim();
                    final newPhone = phoneController.text.trim();
                    final newBatch = batchController.text.trim();
                    final newDepartment = departmentController.text.trim();
                    
                    // Check if any data actually changed
                    bool hasChanges = newName != user.name ||
                        newPhone != (user.phone ?? '') ||
                        (selectedYear ?? '') != (user.year ?? '') ||
                        newBatch != (user.batch ?? '') ||
                        (selectedSection ?? '') != (user.section ?? '');

                    if (user.role != 'Student') {
                      hasChanges = hasChanges || newDepartment != (user.department ?? '');
                    }

                    if (!hasChanges) {
                      Navigator.pop(context);
                      return; // Exit early to save resources and latency
                    }
                    
                    setState(() => isUpdating = true);
                    try {
                      await ref.read(apiAuthRepositoryProvider).updatePersonalInfo(
                        user.id, 
                        name: newName,
                        year: selectedYear ?? '',
                        batch: newBatch,
                        section: selectedSection ?? '',
                        phone: newPhone,
                        department: user.role != 'Student' ? newDepartment : null,
                      );
                      await ref.read(authStateProvider.notifier).refreshUser();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Info updated successfully!')));
                      }
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      setState(() => isUpdating = false);
                    }
                  },
                  child: isUpdating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _showUpdatePasswordDialog() async {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Old Password'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password', hintText: 'Min 6 characters'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUpdating ? null : () async {
                    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password must be at least 6 characters')));
                      return;
                    }
                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match')));
                      return;
                    }
                    
                    setState(() => isUpdating = true);
                    try {
                      await ref.read(apiAuthRepositoryProvider).updatePassword(
                        oldPassword: oldPasswordController.text, 
                        newPassword: newPasswordController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                      }
                      setState(() => isUpdating = false);
                    }
                  },
                  child: isUpdating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final bool isStudent = user.role == 'Student';
    final bool isUnlinked = isStudent && user.status == 'unlinked';
    final bool isPending = isStudent && user.status == 'pending';

    final advisersAsyncValue = ref.watch(batchAdvisersStreamProvider);
    final List<String> advisers = (advisersAsyncValue.value ?? [])
        .map((u) => u.name)
        .toSet()
        .toList();

    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Request Adviser Section for Unlinked Students
          if (isUnlinked) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Action Required: Link Batch Adviser', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('You must link your account to a Batch Adviser to submit complaints. Please select your adviser below.'),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: advisers.contains(_selectedAdviser) ? _selectedAdviser : null,
                        decoration: const InputDecoration(labelText: 'Select Batch Adviser', filled: true, fillColor: Colors.white),
                        items: advisers.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setState(() => _selectedAdviser = val),
                        hint: advisers.isEmpty ? const Text('No advisers found') : null,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting || _selectedAdviser == null ? null : () => _sendAdviserRequest(user.id),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send Request'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Pending Approval Section
          if (isPending) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty_rounded, color: Colors.blue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text('Your request is awaiting approval from ${user.adviser}. You will be notified once approved.', style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Basic Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _pickAndUploadImage(user.id),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2), width: 2),
                          image: user.profileImageUrl != null
                              ? DecorationImage(image: NetworkImage(user.profileImageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: user.profileImageUrl == null ? Icon(Icons.person, size: 48, color: theme.primaryColor) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                      if (user.isCR == true)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.star, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor), textAlign: TextAlign.center),
                Text(user.email, style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Academic/Contact Details Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(isStudent ? Icons.school : Icons.badge, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        isStudent ? 'Academic Information' : 'Staff Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (isStudent) ...[
                  _buildTableRow('Batch', user.batch ?? 'N/A'),
                  const Divider(height: 1),
                  _buildTableRow('Semester', user.year?.replaceAll('Semester ', '') ?? 'N/A'),
                  const Divider(height: 1),
                  _buildTableRow('Section', user.section ?? 'N/A'),
                  const Divider(height: 1),
                  _buildTableRow('Batch Adviser', user.adviser ?? 'Not Linked'),
                  const Divider(height: 1),
                  _buildTableRow('Contact Number', user.phone ?? 'N/A'),
                ] else ...[
                  _buildTableRow('Department', (user.department != null && user.department!.trim().isNotEmpty) ? user.department! : 'N/A'),
                  const Divider(height: 1),
                  if (user.role == 'Batch Adviser' || user.role == 'Coordinator') ...[
                    _buildTableRow(user.role == 'Coordinator' ? 'Coordinating Batch' : 'Advising Batch', user.batch ?? 'N/A'),
                    const Divider(height: 1),
                    if (user.role == 'Batch Adviser') ...[
                      _buildTableRow('Advising Section', user.section ?? 'N/A'),
                      const Divider(height: 1),
                    ],
                  ],
                  _buildTableRow('Contact Number', user.phone ?? 'N/A'),
                ],
              ],
            ),
          ),
            const SizedBox(height: 24),
          
          // Settings and Support Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              final settingsContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.person, color: theme.primaryColor),
                          ),
                          title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Update your details and contact information'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showUpdatePersonalInfoDialog(user),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.lock, color: Colors.grey),
                          ),
                          title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Two-factor authentication and recovery'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showUpdatePasswordDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final supportContent = Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF172548), // primary-container
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Need Technical Help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text("If you're having trouble with the application, our IT support is here 24/7.", style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            foregroundColor: theme.primaryColor,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Contact IT Support', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: settingsContent),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: supportContent),
                  ],
                );
              } else {
                return Column(
                  children: [
                    settingsContent,
                    const SizedBox(height: 24),
                    supportContent,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );

    if (!widget.isSubPage) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
              child: user.profileImageUrl == null ? Icon(Icons.person, color: theme.primaryColor, size: 18) : null,
            ),
            const SizedBox(width: 12),
            Text(
              isStudent ? 'Student Profile' : '${user.role} Profile',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
          ],
        ),
      ),
      body: bodyContent,
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
