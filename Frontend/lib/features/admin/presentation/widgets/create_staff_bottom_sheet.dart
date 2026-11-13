import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/staff_accounts_provider.dart';
import '../utils/admin_role_constants.dart';

void showCreateStaffBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalCtx) => const CreateStaffBottomSheet(),
  );
}

class CreateStaffBottomSheet extends ConsumerStatefulWidget {
  const CreateStaffBottomSheet({super.key});

  @override
  ConsumerState<CreateStaffBottomSheet> createState() => _CreateStaffBottomSheetState();
}

class _CreateStaffBottomSheetState extends ConsumerState<CreateStaffBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role')),
        );
      }
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      await ref.read(apiAuthRepositoryProvider).createStaffAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole!,
      );

      ref.invalidate(staffAccountsProvider);

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Staff account created successfully!')),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Create Staff Account",
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
              "Provision accounts for top-level department staff.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                      labelText: 'Select Role',
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
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: "Temporary Password",
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: "Create Account",
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

