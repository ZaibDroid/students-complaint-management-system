import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import '../providers/batch_provider.dart';

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
                padding: const EdgeInsets.all(16),
                itemCount: state.batches.length,
                itemBuilder: (context, index) {
                  final batch = state.batches[index];
                  final isUserBatch = user?.batch == batch.session;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUserBatch ? AppColors.primary : AppColors.border,
                        width: isUserBatch ? 1.8 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Session ${batch.session}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (isUserBatch)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusResolvedLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Your Batch',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.statusResolved,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          batch.degreeProgram,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 10),

                        // Batch Adviser Details
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    batch.adviserName,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    batch.adviserEmail,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    batch.adviserOffice,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Sections wrap
                        Wrap(
                          spacing: 8,
                          children: batch.sections.map((sec) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                sec,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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
