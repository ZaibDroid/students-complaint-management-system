import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import '../providers/batch_provider.dart';
import '../widgets/batch_card.dart';

class BatchManagementPage extends ConsumerWidget {
  const BatchManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchProvider);
    final user = ref.watch(authProvider).user;
    final isStudent = user?.role.isStaff != true;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.batchManagement),
      appBar: CustomAppBar(
        title: 'Batches & Batch Advisers',
        subtitle: 'Department sections and academic counselors',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(batchProvider.notifier).fetchBatches(),
          ),
        ],
      ),
      floatingActionButton: isStudent
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.adviserRequest),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.handshake_outlined, color: Colors.white),
              label: const Text('Request Adviser Meeting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(batchProvider.notifier).fetchBatches(),
          child: Builder(
            builder: (context) {
              if (state.isLoading && state.batches.isEmpty) {
                return const LoadingWidget(message: 'Loading batches and advisers...');
              }

              if (state.errorMessage != null && state.batches.isEmpty) {
                return AppErrorWidget(
                  message: state.errorMessage!,
                  onRetry: () => ref.read(batchProvider.notifier).fetchBatches(),
                );
              }

              if (state.batches.isEmpty) {
                return const EmptyState(
                  icon: Icons.school_outlined,
                  title: 'No Batches Configured',
                  message: 'Batch records and adviser assignments are being populated by the department.',
                );
              }

              return ListView.builder(
                padding: AppPaddings.page,
                itemCount: state.batches.length,
                itemBuilder: (context, index) {
                  final batch = state.batches[index];
                  final isUserBatch = user?.batch == batch.session;

                  return BatchCard(
                    batch: batch,
                    isUserBatch: isUserBatch,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
