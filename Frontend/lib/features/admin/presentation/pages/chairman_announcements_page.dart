import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../notice_board/presentation/providers/notice_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChairmanAnnouncementsPage extends ConsumerWidget {
  const ChairmanAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesStreamProvider);
    final user = ref.read(authStateProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Broadcast Announcements', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172548))),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: noticesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading announcements: $err')),
        data: (notices) {
          // Filter to only show announcements sent by the chairman
          final myNotices = notices.where((n) => n.senderId == user?.id).toList();

          if (myNotices.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: myNotices.length,
            itemBuilder: (context, index) {
              final notice = myNotices[index];
              final date = notice.createdAt;
              final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              
              // Build target audience string
              String targetStr = 'All Users';
              if (notice.targetRoles != null && notice.targetRoles!.isNotEmpty) {
                String rolesStr = notice.targetRoles!.join(', ');
                String extraInfo = '';
                if (notice.targetRoles!.contains('Student')) {
                  List<String> details = [];
                  if (notice.targetCRsOnly == true) details.add('CRs Only');
                  if (notice.targetBatches != null && notice.targetBatches!.isNotEmpty) {
                    details.add('Batches: ${notice.targetBatches!.join(", ")}');
                  }
                  if (notice.targetSections != null && notice.targetSections!.isNotEmpty) {
                    details.add('Sec: ${notice.targetSections!.join(", ")}');
                  }
                  if (details.isNotEmpty) {
                    extraInfo = ' (${details.join(' | ')})';
                  }
                }
                targetStr = rolesStr + extraInfo;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notice.tag,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                        ),
                        Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notice.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notice.description,
                      style: const TextStyle(color: Color(0xFF64748B)),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    if (notice.attachments != null && notice.attachments!.isNotEmpty) ...[
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: notice.attachments!.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, attachIdx) {
                            final b64 = notice.attachments![attachIdx].split(',').last;
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(base64Decode(b64), width: 100, height: 100, fit: BoxFit.cover),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Target: $targetStr',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Announcement?'),
                                  content: const Text('This will permanently delete this announcement.'),
                                  actions: [
                                    TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => ctx.pop(true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                ref.read(noticeRepositoryProvider).deleteNotice(notice.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/chairman/create_announcement'),
        backgroundColor: const Color(0xFF010F32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign),
        label: const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No Announcements Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Broadcast your first announcement to the department.', style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}
