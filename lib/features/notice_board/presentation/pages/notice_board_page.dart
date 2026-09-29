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
import '../../../../core/widgets/notice_card.dart';
import '../../../../core/widgets/search_bar_widget.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_target_filter_row.dart';

class NoticeBoardPage extends ConsumerStatefulWidget {
  const NoticeBoardPage({super.key});

  @override
  ConsumerState<NoticeBoardPage> createState() => _NoticeBoardPageState();
}

class _NoticeBoardPageState extends ConsumerState<NoticeBoardPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticeProvider);
    final user = ref.watch(authProvider).user;
    final canCreate = user?.role.canCreateNotice ?? false;
    final filteredNotices = state.filteredNotices;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.noticeBoard),
      appBar: CustomAppBar(
        title: 'Department Notice Board',
        subtitle: 'Official announcements and circulars',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(noticeProvider.notifier).fetchNotices(),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.createNotice),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.campaign, color: Colors.white),
              label: const Text('Publish Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Search department circulars & notices...',
                onChanged: (val) => ref.read(noticeProvider.notifier).search(val),
                onClear: () => ref.read(noticeProvider.notifier).search(''),
              ),
            ),

            // Target Audience Filter Chips Row
            NoticeTargetFilterRow(
              selectedTarget: state.filterTarget,
              onTargetChanged: (target) => ref.read(noticeProvider.notifier).filterByTarget(target),
            ),
            AppSpacing.v6,

            // Notices List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(noticeProvider.notifier).fetchNotices(),
                child: Builder(
                  builder: (context) {
                    if (state.isLoading && state.notices.isEmpty) {
                      return const LoadingWidget(message: 'Loading notices...');
                    }

                    if (state.errorMessage != null && state.notices.isEmpty) {
                      return AppErrorWidget(
                        message: state.errorMessage!,
                        onRetry: () => ref.read(noticeProvider.notifier).fetchNotices(),
                      );
                    }

                    if (filteredNotices.isEmpty) {
                      return EmptyState(
                        icon: Icons.campaign_outlined,
                        title: 'No Notices Available',
                        message: 'There are no active notices matching your selected criteria.',
                        actionText: canCreate ? 'Publish Notice' : null,
                        onActionPressed: canCreate ? () => context.push(RouteNames.createNotice) : null,
                      );
                    }

                    return ListView.builder(
                      padding: AppPaddings.page,
                      itemCount: filteredNotices.length,
                      itemBuilder: (context, index) {
                        final notice = filteredNotices[index];
                        return NoticeCard(
                          title: notice.title,
                          content: notice.content,
                          authorName: notice.authorName,
                          authorRole: notice.authorRole,
                          target: notice.target,
                          targetValue: notice.targetValue,
                          createdAt: notice.createdAt,
                          isPinned: notice.isPinned,
                          onTap: () => context.push(RouteNames.noticeDetailPath(notice.id)),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
