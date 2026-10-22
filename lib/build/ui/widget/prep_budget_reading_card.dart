import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_budget_guide.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

/// 마지막 단계에서 보여주는 예산 가늠. 저장을 막지 않는다.
class PrepBudgetReadingCard extends StatelessWidget {
  const PrepBudgetReadingCard({
    super.key,
    required this.reading,
    required this.fontScale,
    this.onEditBudget,
  });

  final PrepBudgetReading reading;
  final double fontScale;
  final VoidCallback? onEditBudget;

  @override
  Widget build(BuildContext context) {
    final Color tone = switch (reading.fit) {
      PrepBudgetFit.adequate => AppColors.accent,
      PrepBudgetFit.tight => AppColors.primary,
      PrepBudgetFit.over => AppColors.error,
      PrepBudgetFit.unknown => AppColors.textSecondary,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '예산 가늠',
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reading.headline,
              style: TextStyle(
                fontSize: 20 * fontScale,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: tone,
              ),
            ),
            if (reading.basisCaption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reading.basisCaption,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              reading.body,
              style: TextStyle(
                fontSize: 14 * fontScale,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
            if (reading.hasNumbers) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _WonFigure(
                      label: '내 예산 평당',
                      perPyeong: reading.customerPerPyeong!,
                      total: reading.customerTotal!,
                      fontScale: fontScale,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WonFigure(
                      label: '이 마감 예상 평당',
                      perPyeong: reading.expectedPerPyeong!,
                      total: reading.expectedTotal!,
                      fontScale: fontScale,
                    ),
                  ),
                ],
              ),
            ],
            if (reading.expensiveLabels.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                '평당을 올린 항목  ${reading.expensiveLabels.join(', ')}',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (reading.hasNumbers) ...[
              const SizedBox(height: 14),
              Text(
                '이 평당 기준은 업종, 환경, 상황에 맞춰 서버에서 온 금액이에요. 비싼 마감을 고르면 그 기준에서 올라갑니다.',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (onEditBudget != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onEditBudget,
                child: Text(
                  '예산·평수 수정',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WonFigure extends StatelessWidget {
  const _WonFigure({
    required this.label,
    required this.perPyeong,
    required this.total,
    required this.fontScale,
  });

  final String label;
  final int perPyeong;
  final int total;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12 * fontScale, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              PrepBudgetGuide.formatWon(perPyeong),
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '약 ${PrepBudgetGuide.formatWon(total)}',
              style: TextStyle(fontSize: 12 * fontScale, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 마감에서 저장하기 전에 보여주는 예산 가늠.
class PrepBudgetSaveDialog extends StatelessWidget {
  const PrepBudgetSaveDialog({super.key, required this.reading});

  final PrepBudgetReading reading;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrepBudgetReadingCard(reading: reading, fontScale: fontScale),
              const SizedBox(height: 12),
              AppButton(
                label: '상담준비 저장',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: '수정하기',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
