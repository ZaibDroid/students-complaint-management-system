import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      
      if (mounted) {
        final authState = ref.read(authStateProvider);
        if (authState.hasValue && authState.value != null) {
          final user = authState.value!;
          if (user.status == 'unlinked' || user.status == 'pending') {
            context.go('/profile');
            return;
          }
          final role = user.role;
          if (role == 'Admin') {
            context.go('/dashboard/admin');
          } else if (role == 'Chairman') {
            context.go('/dashboard/chairman');
          } else if (role == 'Batch Adviser') {
            context.go('/dashboard/adviser');
          } else if (role == 'Dean') {
            context.go('/dashboard/dean');
          } else if (role == 'Vice Chancellor') {
            context.go('/dashboard/vc');
          } else if (role == 'Coordinator') {
            context.go('/dashboard/coordinator');
          } else if (role == 'Office') {
            context.go('/dashboard/office');
          } else {
            context.go('/dashboard/student');
          }
        } else if (authState.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${authState.error}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome Back",
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Log in to track your complaints",
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  AppTextField(
                    controller: _emailController,
                    labelText: "University Email",
                    hintText: "e.g. 23mdbcs495@uetmardan.edu.pk",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: AppValidators.loginEmail,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: "Password",
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: AppValidators.password,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: "Log In",
                    isLoading: isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text("Register"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
