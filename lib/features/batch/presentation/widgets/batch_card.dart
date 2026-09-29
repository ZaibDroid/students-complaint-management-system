import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../domain/entities/batch_entity.dart';

/// Reusable batch details card with session, adviser details, and class sections
class BatchCard extends StatelessWidget {
  final BatchEntity batch;
  final bool isUserBatch;

  const BatchCard({
    super.key,
    required this.batch,
    this.isUserBatch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadii.r16,
        border: Border.all(
          color: isUserBatch ? AppColors.primary : AppColors.border,
          width: isUserBatch ? 1.8 : 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppBorderRadii.r8,
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
                  decoration: const BoxDecoration(
                    color: AppColors.statusResolvedLight,
                    borderRadius: AppBorderRadii.r6,
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
          AppSpacing.v12,
          Text(
            batch.degreeProgram,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v12,
          const Divider(color: AppColors.divider),
          AppSpacing.v10,

          // Batch Adviser Details
          Row(
            children: [
              Container(
                padding: AppPaddings.all10,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              AppSpacing.h12,
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
          AppSpacing.v12,

          // Sections wrap
          Wrap(
            spacing: 8,
            children: batch.sections.map((sec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppBorderRadii.r6,
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
  }
}
