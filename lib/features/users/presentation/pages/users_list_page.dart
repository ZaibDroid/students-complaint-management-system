import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/search_bar_widget.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/users_provider.dart';

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
    UserRole selected = currentRole;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Assign Role: $userName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              return RadioListTile<UserRole>(
                title: Text(role.displayName),
                value: role,
                groupValue: selected,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  if (val != null) setDialogState(() => selected = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(usersProvider.notifier).updateRole(userId, selected);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Role updated to ${selected.displayName}!')),
                    );
                  }
                }
              },
              child: const Text('Save Role'),
            ),
          ],
        ),
      ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Roles'),
                    selected: state.selectedRole == null,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: state.selectedRole == null ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => ref.read(usersProvider.notifier).filterByRole(null),
                  ),
                  const SizedBox(width: 8),
                  ...UserRole.values.map((role) {
                    final isSelected = state.selectedRole == role;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(role.displayName),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          ref.read(usersProvider.notifier).filterByRole(selected ? role : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 6),

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
                      padding: const EdgeInsets.all(16),
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final u = state.users[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              UserAvatar(name: u.fullName, size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.fullName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      u.email,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (u.regNo != null || u.batch != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${u.regNo ?? ''} • ${u.batch ?? ''} • ${u.section ?? ''}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _showRoleChangeDialog(context, u.id, u.fullName, u.role),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        u.role.displayName,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}
