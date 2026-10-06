import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../core/services/api_client.dart';

final staffAccountsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final apiClient = ApiClient();
    final data = await apiClient.get('/users/staff');
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  } catch (_) {
    return [];
  }
});

class AdminAccessPage extends ConsumerStatefulWidget {
  const AdminAccessPage({super.key});

  @override
  ConsumerState<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends ConsumerState<AdminAccessPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRole;
  final List<String> _roles = ['Vice Chancellor', 'Dean', 'Chairman', 'Department Office'];

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Vice Chancellor': return Icons.account_balance;
      case 'Dean': return Icons.school;
      case 'Chairman': return Icons.person;
      case 'Department Office': return Icons.desk;
      default: return Icons.person_outline;
    }
  }
  
  bool _isLoading = false;

  void _createAccount() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(apiAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole!,
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _selectedRole = null;
          });
          Navigator.pop(context); // close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff account created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    } else if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
    }
  }

  void _showCreateStaffForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(
                      "Create Staff Account",
                      style: Theme.of(context).textTheme.displayMedium,
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
                            items: _roles.map((e) => DropdownMenuItem(
                              value: e, 
                              child: Row(
                                children: [
                                  Icon(_getRoleIcon(e), size: 20, color: Colors.grey.shade700),
                                  const SizedBox(width: 12),
                                  Text(e),
                                ],
                              )
                            )).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                _selectedRole = val;
                              });
                              setState(() {
                                _selectedRole = val;
                              });
                            },
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
                            validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _emailController,
                            labelText: "Staff Email",
                            hintText: "e.g. chairman@uetmardan.edu.pk",
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              if (!value.trim().endsWith('@uetmardan.edu.pk')) {
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
                            validator: (value) => value == null || value.length < 6 ? 'Min 6 characters' : null,
                          ),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            text: "Create Account",
                            isLoading: _isLoading,
                            onPressed: () {
                              setModalState(() {});
                              _createAccount();
                            },
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
        );
      }
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffAccountsAsync = ref.watch(staffAccountsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Control'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateStaffForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Provisioned Staff Accounts",
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Manage the top-level accounts in the department.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            staffAccountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No staff accounts provisioned yet.'),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(_getRoleIcon(account['role']), color: theme.primaryColor),
                        ),
                        title: Text(account['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${account['role']} • ${account['email']}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading accounts: $err', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
