import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/search_bar_widget.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/users_provider.dart';
import '../widgets/role_assignment_dialog.dart';
import '../widgets/user_role_filter_row.dart';
import '../widgets/user_tile_card.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRoleChangeDialog(BuildContext context, String userId, String userName, UserRole currentRole) {
    RoleAssignmentDialog.show(
      context,
      userName: userName,
      currentRole: currentRole,
      onRoleSaved: (newRole) async {
        final success = await ref.read(usersProvider.notifier).updateRole(userId, newRole);
        if (mounted && success) {
          context.showSuccessSnackBar('Role updated to ${newRole.displayName}!');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.usersList),
      appBar: CustomAppBar(
        title: 'Department Directory',
        subtitle: 'Student and staff profiles & role administration',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(usersProvider.notifier).fetchUsers(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Search by name, reg no, or email...',
                onChanged: (val) => ref.read(usersProvider.notifier).search(val),
                onClear: () => ref.read(usersProvider.notifier).search(''),
              ),
            ),
            // Role Filter Chips
            UserRoleFilterRow(
              selectedRole: state.selectedRole,
              onRoleChanged: (role) => ref.read(usersProvider.notifier).filterByRole(role),
            ),
            AppSpacing.v6,

            // Users List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(usersProvider.notifier).fetchUsers(),
                child: Builder(
                  builder: (context) {
                    if (state.isLoading && state.users.isEmpty) {
                      return const LoadingWidget(message: 'Loading department members...');
                    }

                    if (state.errorMessage != null && state.users.isEmpty) {
                      return AppErrorWidget(
                        message: state.errorMessage!,
                        onRetry: () => ref.read(usersProvider.notifier).fetchUsers(),
                      );
                    }

                    if (state.users.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Members Found',
                        message: 'No user records matching the current filter.',
                      );
                    }

                    return ListView.separated(
                      padding: AppPaddings.all16,
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => AppSpacing.v10,
                      itemBuilder: (context, index) {
                        final u = state.users[index];
                        return UserTileCard(
                          user: u,
                          onRoleTap: () => _showRoleChangeDialog(context, u.id, u.fullName, u.role),
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
