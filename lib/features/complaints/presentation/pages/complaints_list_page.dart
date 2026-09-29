import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/complaint_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_bottom_sheet.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pagination_widget.dart';
import '../../../../core/widgets/search_bar_widget.dart';
import '../../../../shared/enums/user_role.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../widgets/active_filters_bar.dart';

class ComplaintsListPage extends ConsumerStatefulWidget {
  const ComplaintsListPage({super.key});

  @override
  ConsumerState<ComplaintsListPage> createState() => _ComplaintsListPageState();
}

class _ComplaintsListPageState extends ConsumerState<ComplaintsListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final state = ref.read(complaintsListProvider);
    FilterBottomSheet.show(
      context: context,
      initialStatus: state.selectedStatus,
      initialPriority: state.selectedPriority,
      initialCategory: state.selectedCategory,
      onApply: (criteria) {
        ref.read(complaintsListProvider.notifier).applyFilters(
              status: criteria.status,
              priority: criteria.priority,
              category: criteria.category,
            );
      },
      onReset: () {
        ref.read(complaintsListProvider.notifier).resetFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintsListProvider);
    final user = ref.watch(authProvider).user;
    final isStudent = user?.role == UserRole.student || user?.role == UserRole.cr;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.complaintsList),
      appBar: CustomAppBar(
        title: isStudent ? 'My Complaints' : 'Complaint Queue',
        subtitle: isStudent
            ? 'Track submitted grievances and updates'
            : 'Review, forward, remark, and resolve complaints',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1),
          ),
        ],
      ),
      floatingActionButton: isStudent
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.submitComplaint),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Complaint',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: isStudent ? 'Search my complaints...' : 'Search queue by ID, student, subject...',
                showFilterButton: true,
                onChanged: (val) => ref.read(complaintsListProvider.notifier).search(val),
                onClear: () => ref.read(complaintsListProvider.notifier).search(''),
                onFilterTap: _openFilterSheet,
              ),
            ),

            // Active Filters Bar
            ActiveFiltersBar(
              selectedStatus: state.selectedStatus,
              selectedPriority: state.selectedPriority,
              onClearStatus: () => ref.read(complaintsListProvider.notifier).applyFilters(status: null),
              onClearPriority: () => ref.read(complaintsListProvider.notifier).applyFilters(priority: null),
            ),

            // Content Area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1),
                child: Builder(
                  builder: (context) {
                    if (state.isLoading && state.complaints.isEmpty) {
                      return const LoadingWidget(message: 'Loading complaints...');
                    }

                    if (state.errorMessage != null && state.complaints.isEmpty) {
                      return AppErrorWidget(
                        message: state.errorMessage!,
                        onRetry: () => ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1),
                      );
                    }

                    if (state.complaints.isEmpty) {
                      return EmptyState(
                        icon: Icons.assignment_outlined,
                        title: isStudent ? 'No Complaints Submitted' : 'Complaint Queue is Empty',
                        message: isStudent
                            ? 'You have not submitted any complaints yet. Tap below to lodge a complaint with your Batch Adviser.'
                            : 'No pending complaints requiring your attention at this moment.',
                        actionText: isStudent ? 'Submit Complaint' : null,
                        onActionPressed: isStudent ? () => context.push(RouteNames.submitComplaint) : null,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = state.complaints[index];
                        return ComplaintCard(
                          id: complaint.id,
                          trackingNumber: complaint.trackingNumber,
                          title: complaint.title,
                          description: complaint.description,
                          category: complaint.category,
                          status: complaint.status,
                          priority: complaint.priority,
                          createdAt: complaint.createdAt,
                          studentName: complaint.studentName,
                          batch: complaint.batch,
                          currentHandlerRole: complaint.currentHandlerRole.displayName,
                          onTap: () => context.push(RouteNames.complaintDetailPath(complaint.id)),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Pagination Controls
            PaginationWidget(
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onPageChanged: (page) => ref.read(complaintsListProvider.notifier).fetchComplaints(page: page),
            ),
          ],
        ),
      ),
    );
  }
}
