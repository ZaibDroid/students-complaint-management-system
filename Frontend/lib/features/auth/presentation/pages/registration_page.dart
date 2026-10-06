import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _selectedYear;
  final TextEditingController _batchController = TextEditingController();
  String? _selectedSection;
  final bool _isCR = false;

  final List<String> _years = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E', 'F', 'Artificial Intelligence', 'Cloud Computing', 'Data Science', 'Computer Science'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedYear == null || _selectedSection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all academic details')),
        );
        return;
      }
      
      await ref.read(authStateProvider.notifier).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        year: _selectedYear,
        batch: _batchController.text.trim(),
        section: _selectedSection,
        phone: _phoneController.text.trim(),
        isCR: _isCR,
      );
      
      if (mounted) {
        final authState = ref.read(authStateProvider);
        if (authState.hasValue && authState.value != null) {
          await ref.read(authStateProvider.notifier).logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful. Please log in.')),
            );
            context.go('/login');
          }
        } else if (authState.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${authState.error}')),
          );
        }
      }
    }
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Student Registration",
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Join the DCMS portal using your university credentials.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _nameController,
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => AppValidators.requiredField(value, 'Name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  labelText: "University Email",
                  hintText: "e.g. 23mdbcs495@uetmardan.edu.pk",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: AppValidators.universityEmail,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  labelText: "Phone Number",
                  hintText: "e.g. 03001234567",
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  labelText: "Password",
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: AppValidators.password,
                ),
                const SizedBox(height: 24),
                Text(
                  "Academic Details",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDropdown('Semester', _years, _selectedYear, (val) => setState(() => _selectedYear = val))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _batchController,
                        labelText: 'Batch Year',
                        hintText: 'e.g. 2024',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('Section', _sections, _selectedSection, (val) => setState(() => _selectedSection = val))),
                    const SizedBox(width: 16),
                    Expanded(child: SizedBox()), // Placeholder to keep alignment
                  ],
                ),
                const SizedBox(height: 32),
                
                const SizedBox(height: 48),
                PrimaryButton(
                  text: "Register",
                  isLoading: isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text("Log In"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
