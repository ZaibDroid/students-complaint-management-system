import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../shared/enums/notice_target.dart';
import '../../domain/entities/notice_entity.dart';
import '../providers/notice_provider.dart';

class NoticeDetailPage extends ConsumerWidget {
  final String noticeId;

  const NoticeDetailPage({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noticeProvider);
    final notice = state.notices.firstWhere(
      (n) => n.id == noticeId,
      orElse: () => NoticeEntity(
        id: '',
        title: 'Notice Not Found',
        content: '',
        authorName: '',
        authorRole: '',
        target: NoticeTarget.all,
        createdAt: DateTime.now(),
      ),
    );

    if (notice.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notice')),
        body: const EmptyState(
          icon: Icons.campaign_outlined,
          title: 'Notice Not Found',
          message: 'The requested department notice does not exist or has been removed.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Department Notice'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target Badge & Pinned Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notice.targetValue != null && notice.targetValue!.isNotEmpty
                            ? 'Target: ${notice.target.displayName} (${notice.targetValue})'
                            : 'Target: ${notice.target.displayName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (notice.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.push_pin, size: 14, color: AppColors.accent),
                            SizedBox(width: 4),
                            Text(
                              'Pinned',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Author & Date
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${notice.authorName} (${notice.authorRole})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatDateTime(notice.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // Notice Content Body
                Text(
                  notice.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
