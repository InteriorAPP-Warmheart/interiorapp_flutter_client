part of '../project_progress_view.dart';

class _PrepStage extends StatelessWidget {
  const _PrepStage({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('착공 준비', style: _recordLabel(fontScale)),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: _card,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              children: [
                _PrepLine(label: '자재', value: '맞추는 중', fontScale: fontScale),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _PrepLine(label: '순서', value: '정하는 중', fontScale: fontScale),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _PrepLine(
                  label: '착공일',
                  value: '미정',
                  fontScale: fontScale,
                  emphasized: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SignalBar(
          icon: Icons.construction_outlined,
          title: '착공하면 오늘과 내일 공정이 열려요',
          note: '공사진행에서 볼 수 있어요',
          fontScale: fontScale,
          tone: _SignalTone.quiet,
        ),
      ],
    );
  }
}

class _PrepLine extends StatelessWidget {
  const _PrepLine({
    required this.label,
    required this.value,
    required this.fontScale,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final double fontScale;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: emphasized ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
