import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 여러 단계 작성의 진행 막대. 지금 단계와 남은 단계를 함께 보여 준다.
class FormStepHeader extends StatelessWidget {
  const FormStepHeader({
    super.key,
    required this.steps,
    required this.index,
    required this.fontScale,
  });

  final List<String> steps;
  final int index;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: i == index ? FontWeight.w700 : FontWeight.w500,
                    color:
                        i == index
                            ? AppColors.primary
                            : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
