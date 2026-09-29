import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';

/// Reusable attachment and evidence preview gallery for complaint details
class ComplaintEvidenceGrid extends StatelessWidget {
  final List<String> attachmentUrls;

  const ComplaintEvidenceGrid({
    super.key,
    required this.attachmentUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (attachmentUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: AppPaddings.all16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadii.r16,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attached Proof & Evidence',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v12,
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachmentUrls.length,
              separatorBuilder: (_, __) => AppSpacing.h10,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: AppBorderRadii.r8,
                  child: Image.network(
                    attachmentUrls[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: AppColors.primarySurface,
                      child: const Icon(Icons.image, color: AppColors.primary),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
