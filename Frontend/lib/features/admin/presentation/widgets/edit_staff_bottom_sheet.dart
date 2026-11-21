import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/departments.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/staff_accounts_provider.dart';
import '../utils/admin_role_constants.dart';

void showEditStaffBottomSheet(BuildContext context, Map<String, dynamic> account) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalCtx) => EditStaffBottomSheet(account: account),
  );
}

class EditStaffBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> account;

  const EditStaffBottomSheet({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<EditStaffBottomSheet> createState() => _EditStaffBottomSheetState();
}

class _EditStaffBottomSheetState extends ConsumerState<EditStaffBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  String? _selectedRole;
  String? _selectedDepartmentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account['name'] ?? '');
    _emailController = TextEditingController(text: widget.account['email'] ?? '');
    _phoneController = TextEditingController(text: widget.account['phone'] ?? '');
    _passwordController = TextEditingController();

    _selectedRole = widget.account['role'];
    if (!kStaffRoles.contains(_selectedRole)) {
      _selectedRole = kStaffRoles.first;
    }

    final rawDeptId = widget.account['department_id'] ?? widget.account['departmentId'];
    if (rawDeptId != null) {
      _selectedDepartmentId = rawDeptId.toString();
    } else if (widget.account['department'] != null) {
      final deptName = widget.account['department'].toString();
      final match = kOfficialDepartments.where((d) => d.name == deptName || deptName.contains(d.code)).firstOrNull;
      if (match != null) {
        _selectedDepartmentId = match.id;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final userId = (widget.account['id'] ?? '').toString();
      final deptObj = kOfficialDepartments.where((d) => d.id == _selectedDepartmentId).firstOrNull;
      await ref.read(apiAuthRepositoryProvider).updateStaffAccount(
        userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole!,
        phone: _selectedRole == 'Chairman' ? null : (_phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null),
        departmentId: _selectedRole == 'Chairman' ? _selectedDepartmentId : null,
        department: _selectedRole == 'Chairman' ? deptObj?.name : null,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      ref.invalidate(staffAccountsProvider);

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Staff account updated successfully!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Staff Account",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Update details or reassign role for ${widget.account['name'] ?? 'staff'}.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: kStaffRoles.map((role) => DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(getRoleIcon(role), size: 20, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Text(role),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                validator: (val) => val == null ? 'Role is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person_outline),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                labelText: "Staff Email",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (!val.trim().endsWith('@uetmardan.edu.pk')) {
                    return 'Must be a @uetmardan.edu.pk email';
                  }
                  return null;
                },
              ),
              if (_selectedRole == 'Chairman') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedDepartmentId,
                  items: kOfficialDepartments.map((dept) => DropdownMenuItem(
                    value: dept.id,
                    child: Text(dept.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedDepartmentId = val),
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (val) => _selectedRole == 'Chairman' && val == null ? 'Department is required for Chairman' : null,
                ),
              ],
              if (_selectedRole != 'Chairman') ...[
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  labelText: "Phone Number (Optional)",
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: "New Password (Leave blank to keep existing)",
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return 'Min 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "Save Changes",
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

