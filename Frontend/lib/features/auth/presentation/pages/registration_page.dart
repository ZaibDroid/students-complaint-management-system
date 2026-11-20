import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';
import '../../../../features/batch/domain/entities/batch_model.dart';

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
  
  String? _selectedBatchId;
  BatchModel? _selectedBatch;
  String? _selectedSectionId;
  String? _selectedSectionName;
  final bool _isCR = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your batch')),
        );
        return;
      }
      if (_selectedSectionName == null && _selectedSectionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your section')),
        );
        return;
      }
      
      final formattedEmail = AppValidators.formatEmail(_emailController.text);
      await ref.read(authStateProvider.notifier).register(
        name: _nameController.text.trim(),
        email: formattedEmail,
        password: _passwordController.text,
        year: null,
        batch: _selectedBatch!.name,
        batchId: _selectedBatch!.id,
        section: _selectedSectionName,
        sectionId: _selectedSectionId,
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

  Widget _buildBatchDropdown(AsyncValue<List<BatchModel>> batchesAsync) {
    return batchesAsync.when(
      loading: () => Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Loading batches...',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      error: (err, stack) => Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Failed to load',
                style: TextStyle(color: Colors.red, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () => ref.invalidate(batchesStreamProvider),
              tooltip: 'Retry',
            ),
          ],
        ),
      ),
      data: (batches) {
        if (batches.isEmpty) {
          return DropdownButtonFormField<String>(
            isExpanded: true,
            items: const [],
            onChanged: null,
            decoration: const InputDecoration(
              labelText: 'Batch',
              hintText: 'No batches',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            validator: (val) => 'No batches available',
          );
        }

        return DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _selectedBatchId,
          decoration: const InputDecoration(
            labelText: 'Batch',
            hintText: 'Select Batch',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: batches.map((batch) {
            return DropdownMenuItem<String>(
              value: batch.id,
              child: Text(
                batch.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != _selectedBatchId) {
              setState(() {
                _selectedBatchId = val;
                _selectedBatch = batches.firstWhere((b) => b.id == val);
                // Reset section when batch changes
                _selectedSectionId = null;
                _selectedSectionName = null;
              });
            }
          },
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        );
      },
    );
  }

  Widget _buildSectionDropdown() {
    if (_selectedBatch == null) {
      return DropdownButtonFormField<String>(
        isExpanded: true,
        items: const [],
        onChanged: null,
        decoration: const InputDecoration(
          labelText: 'Section',
          hintText: 'Select batch',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        validator: (val) => _selectedBatch == null ? 'Select batch first' : null,
      );
    }

    final sectionItems = _selectedBatch!.sectionItems;
    final sectionNames = _selectedBatch!.sections;

    if (sectionItems.isEmpty && sectionNames.isEmpty) {
      return DropdownButtonFormField<String>(
        isExpanded: true,
        items: const [],
        onChanged: null,
        decoration: const InputDecoration(
          labelText: 'Section',
          hintText: 'No sections',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        validator: (val) => 'No sections available',
      );
    }

    if (sectionItems.isNotEmpty) {
      final sortedItems = List<BatchSectionItem>.from(sectionItems)
        ..sort((a, b) => a.name.compareTo(b.name));

      return DropdownButtonFormField<String>(
        key: ValueKey('sec_items_${_selectedBatch!.id}_$_selectedSectionId'),
        isExpanded: true,
        initialValue: _selectedSectionId,
        decoration: const InputDecoration(
          labelText: 'Section',
          hintText: 'Select Section',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: sortedItems.map((item) {
          return DropdownMenuItem<String>(
            value: item.id,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          final chosen = sortedItems.firstWhere((s) => s.id == val);
          setState(() {
            _selectedSectionId = val;
            _selectedSectionName = chosen.name;
          });
        },
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      );
    } else {
      final sortedNames = List<String>.from(sectionNames)..sort();
      return DropdownButtonFormField<String>(
        key: ValueKey('sec_names_${_selectedBatch!.id}_$_selectedSectionName'),
        isExpanded: true,
        initialValue: _selectedSectionName,
        decoration: const InputDecoration(
          labelText: 'Section',
          hintText: 'Select Section',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: sortedNames.map((name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedSectionId = null;
            _selectedSectionName = val;
          });
        },
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final batchesAsync = ref.watch(batchesStreamProvider);
    
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
                  hintText: "00MDBCS000@uetmardan.edu.pk",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  inputFormatters: const [StudentEmailInputFormatter(isStudentOnly: true)],
                  validator: AppValidators.universityEmail,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  labelText: "Phone Number",
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 280) {
                      return Column(
                        children: [
                          _buildBatchDropdown(batchesAsync),
                          const SizedBox(height: 16),
                          _buildSectionDropdown(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildBatchDropdown(batchesAsync),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSectionDropdown(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
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
