import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(currentRoute: '/admin/archives'),
      appBar: CustomAppBar(
        title: 'Archived Records',
        subtitle: 'Historical department grievance logs',
      ),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.archive_outlined,
          title: 'Department Archives',
          message: 'All resolved and concluded complaint histories are permanently stored and retrievable here for auditing.',
        ),
      ),
    );
  }
}
