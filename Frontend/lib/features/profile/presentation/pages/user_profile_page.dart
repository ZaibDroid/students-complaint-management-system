import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_academic_card.dart';
import '../widgets/profile_adviser_linking_banner.dart';
import '../widgets/profile_support_card.dart';

class UserProfilePage extends ConsumerWidget {
  final bool isSubPage;

  const UserProfilePage({super.key, this.isSubPage = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final bool isStudent = user.role == 'Student';

    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ProfileAdviserLinkingBanner(user: user),
          ProfileHeaderCard(user: user),
          const SizedBox(height: 24),
          ProfileAcademicCard(user: user),
          const SizedBox(height: 24),
          ProfileSupportCard(user: user),
        ],
      ),
    );

    if (!isSubPage) {
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
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Icon(Icons.person, color: theme.primaryColor, size: 18)
                  : null,
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
}
