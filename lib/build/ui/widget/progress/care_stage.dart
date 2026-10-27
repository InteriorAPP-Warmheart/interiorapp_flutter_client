part of '../project_progress_view.dart';

class _CareStage extends StatelessWidget {
  const _CareStage({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A/S',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xB3FFFFFF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '준공 이후',
                  style: TextStyle(
                    fontSize: 28 * fontScale,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '증상과 사진을 남기면 담당자가 확인해요',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.4,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final String label in const ['증상', '위치', '사진']) ...[
              if (label != '증상') const SizedBox(width: 8),
              Expanded(
                child: _LookTile(
                  icon: _careIcon(label),
                  label: label,
                  fontScale: fontScale,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
