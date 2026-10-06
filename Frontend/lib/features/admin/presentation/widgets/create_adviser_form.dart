import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class CreateAdviserForm extends ConsumerStatefulWidget {
  const CreateAdviserForm({super.key});

  @override
  ConsumerState<CreateAdviserForm> createState() => _CreateAdviserFormState();
}

class _CreateAdviserFormState extends ConsumerState<CreateAdviserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  void _createAdviser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(apiAuthRepositoryProvider).createStaffAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: 'Batch Adviser',
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batch Adviser account created successfully!')),
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
    }
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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Batch Adviser",
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Create a new Batch Adviser account. You can assign them to sections from the Master Table.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _nameController,
                  labelText: "Adviser Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  labelText: "Adviser Email",
                  hintText: "e.g. batchadviser@uetmardan.edu.pk",
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
                  text: "Create Adviser Account",
                  isLoading: _isLoading,
                  onPressed: _createAdviser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
