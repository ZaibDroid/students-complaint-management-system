import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_board_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StaffNoticeBoardPage extends ConsumerStatefulWidget {
  const StaffNoticeBoardPage({super.key});

  @override
  ConsumerState<StaffNoticeBoardPage> createState() => _StaffNoticeBoardPageState();
}

class _StaffNoticeBoardPageState extends ConsumerState<StaffNoticeBoardPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'General Announcement', 'Academic', 'Urgent', 'Events', 'Administrative', 'Internship', 'Other'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Notice Board', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172548))),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: theme.primaryColor.withValues(alpha: 0.1),
                    checkmarkColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Announcements List
          Expanded(
            child: ref.watch(noticesStreamProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading notices: $e')),
              data: (notices) {
                final myNotices = notices.where((n) {
                  // 1. Check Role constraints
                  if (n.targetRoles != null && n.targetRoles!.isNotEmpty) {
                    if (!n.targetRoles!.contains(user.role)) return false;
                  }

                  // 2. Apply the UI selected category filter
                  if (_selectedFilter != 'All' && n.tag != _selectedFilter) {
                    return false;
                  }

                  return true;
                }).toList();

                if (myNotices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements found',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: myNotices.length,
                  itemBuilder: (context, index) {
                    final notice = myNotices[index];
                    final date = notice.createdAt;
                    final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    
                    return NoticeBoardCard(
                      title: notice.title,
                      description: notice.description,
                      tag: notice.tag,
                      date: dateStr,
                      sender: notice.senderName,
                      senderIcon: Icons.person,
                      isUrgent: notice.tag == 'Urgent',
                      attachments: notice.attachments,
                      onTap: () {
                        context.push('/notice_details', extra: notice);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
