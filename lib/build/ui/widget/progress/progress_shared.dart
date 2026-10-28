part of '../project_progress_view.dart';

class _Headline extends StatelessWidget {
  const _Headline({required this.text, required this.fontScale});

  final String text;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 26 * fontScale,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: _kicker(fontScale).copyWith(height: 1.1)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LookTile extends StatelessWidget {
  const _LookTile({
    required this.icon,
    required this.label,
    required this.fontScale,
  });

  final IconData icon;
  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SignalTone { strong, quiet }

class _SignalBar extends StatelessWidget {
  const _SignalBar({
    required this.icon,
    required this.title,
    required this.note,
    required this.fontScale,
    this.tone = _SignalTone.strong,
  });

  final IconData icon;
  final String title;
  final String note;
  final double fontScale;
  final _SignalTone tone;

  @override
  Widget build(BuildContext context) {
    final bool strong = tone == _SignalTone.strong;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: strong ? AppColors.primary : const Color(0xFFE7EBE4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: strong ? AppColors.white : AppColors.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: strong ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        height: 1.35,
                        color:
                            strong
                                ? const Color(0xD9FFFFFF)
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrepTile extends StatelessWidget {
  const _PrepTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        emphasized ? AppColors.white : AppColors.textPrimary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: emphasized ? null : Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: emphasized ? AppColors.white : AppColors.accent,
            ),
            const SizedBox(height: 18),
            Text(
              label,
              style: TextStyle(
                fontSize: 12 * fontScale,
                fontWeight: FontWeight.w600,
                color:
                    emphasized
                        ? const Color(0xB3FFFFFF)
                        : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const BoxDecoration _card = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
);

/// 내용이 화면에 다 들어가면 당겨도 움직이지 않는다. 넘칠 때만 스크롤한다.
class _ScrollOnlyWhenNeeded extends ScrollPhysics {
  const _ScrollOnlyWhenNeeded({super.parent});

  @override
  _ScrollOnlyWhenNeeded applyTo(ScrollPhysics? ancestor) {
    return _ScrollOnlyWhenNeeded(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (position.maxScrollExtent <= 0) return value - position.pixels;
    return super.applyBoundaryConditions(position, value);
  }
}

String _shown(String value) {
  final String text = value.trim();
  return text.isEmpty ? '확인 중' : text;
}

String _consultText(String? value) {
  if (value == null) return '확인 중';
  final String text = value.trim();
  if (text.isEmpty) return '아직 정하지 못했어요';
  return text;
}

String _briefBudget(PrepRecord record) {
  final String amount = record.budget.trim();
  if (amount.isNotEmpty) return amount;
  return _shown(record.budgetRange);
}

IconData _careIcon(String label) {
  switch (label) {
    case '위치':
      return Icons.place_outlined;
    case '사진':
      return Icons.photo_outlined;
    default:
      return Icons.notes_outlined;
  }
}
