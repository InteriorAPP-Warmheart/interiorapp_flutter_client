import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 재료비, 노무비, 전체를 한 줄에 맞춰 보여 준다.
class QuoteMoneySummary extends StatelessWidget {
  const QuoteMoneySummary({
    super.key,
    required this.material,
    required this.labor,
    required this.fontScale,
    this.onDark = false,
    this.compact = false,
    this.vatPercent,
    this.vatIncluded,
  });

  /// 비어 있는 칸은 null이다. 0은 금액이 0원인 칸이다.
  final int? material;
  final int? labor;
  final double fontScale;
  final bool onDark;
  final bool compact;

  /// 부가세 퍼센트. [vatIncluded]와 함께 있을 때만 보여 준다.
  final int? vatPercent;

  /// 부가세를 더한 금액.
  final int? vatIncluded;

  int? get total {
    if (material == null && labor == null) return null;
    return (material ?? 0) + (labor ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final int? whole = total;
    final int? included = vatIncluded;
    final int? percent = vatPercent;
    final Color line = onDark ? const Color(0x33FFFFFF) : AppColors.border;
    final Color labelColor =
        onDark ? const Color(0xD9FFFFFF) : AppColors.textSecondary;
    final Color valueColor = onDark ? AppColors.white : AppColors.textPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MoneyCell(
                label: '재료비',
                icon: Icons.layers_outlined,
                value: material,
                fontScale: fontScale,
                onDark: onDark,
                compact: compact,
              ),
            ),
            _MoneyRule(onDark: onDark),
            Expanded(
              child: _MoneyCell(
                label: '노무비',
                icon: Icons.engineering_outlined,
                value: labor,
                fontScale: fontScale,
                onDark: onDark,
                compact: compact,
              ),
            ),
            _MoneyRule(onDark: onDark),
            Expanded(
              child: _MoneyCell(
                label: '전체',
                value: whole,
                fontScale: fontScale,
                onDark: onDark,
                compact: compact,
                strong: true,
              ),
            ),
          ],
        ),
        if (included != null && percent != null) ...[
          const SizedBox(height: 12),
          Container(height: 1, color: line),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '부가세 $percent% 포함',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
              const Spacer(),
              Text(
                '${formatWon(included)}원',
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MoneyRule extends StatelessWidget {
  const _MoneyRule({required this.onDark});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: onDark ? const Color(0x33FFFFFF) : AppColors.border,
    );
  }
}

class _MoneyCell extends StatelessWidget {
  const _MoneyCell({
    required this.label,
    required this.value,
    required this.fontScale,
    required this.onDark,
    required this.compact,
    this.icon,
    this.strong = false,
  });

  final String label;
  final IconData? icon;
  final int? value;
  final double fontScale;
  final bool onDark;
  final bool compact;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final Color labelColor =
        onDark ? const Color(0xB3FFFFFF) : AppColors.textSecondary;
    final Color valueColor =
        onDark
            ? (strong ? AppColors.white : const Color(0xD9FFFFFF))
            : AppColors.textPrimary;
    final double valueSize =
        (compact ? (strong ? 14 : 13) : (strong ? 18 : 14)) * fontScale;
    final double iconSize = (compact ? 14 : 16) * fontScale;
    final IconData? mark = icon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (mark != null) ...[
              Icon(mark, size: iconSize, color: labelColor),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: (compact ? 11 : 12) * fontScale,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value == null ? '—' : '${formatWon(value!)}원',
            softWrap: false,
            style: TextStyle(
              fontSize: valueSize,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
