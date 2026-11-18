import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'update_personal_info_dialog.dart';
import 'change_password_dialog.dart';

class ProfileSupportCard extends ConsumerWidget {
  final User user;

  const ProfileSupportCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        final settingsContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
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
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person, color: theme.primaryColor),
                    ),
                    title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Update your details and contact information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => UpdatePersonalInfoDialog.show(context, user),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock, color: Colors.grey),
                    ),
                    title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Two-factor authentication and recovery'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ChangePasswordDialog.show(context),
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
                color: const Color(0xFF172548),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need Technical Help?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "If you're having trouble with the application, our IT support is here 24/7.",
                    style: TextStyle(color: Colors.white70),
                  ),
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
    );
  }
}

