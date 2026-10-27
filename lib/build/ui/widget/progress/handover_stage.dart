part of '../project_progress_view.dart';

class _HandoverStage extends StatelessWidget {
  const _HandoverStage({required this.fontScale});

  final double fontScale;

  static const List<String> _steps = ['마무리', '점검', '준공확인', '정산'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(text: '최종 확인중', fontScale: fontScale),
        const SizedBox(height: 6),
        Text(
          '준공 확인은 열렸을 때만 할 수 있어요',
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 78,
          child: Stack(
            children: [
              const Positioned(
                top: 13,
                left: 20,
                right: 20,
                child: ColoredBox(
                  color: AppColors.border,
                  child: SizedBox(height: 2),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  i == 1
                                      ? AppColors.accent
                                      : i < 1
                                      ? AppColors.primary
                                      : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    i <= 1
                                        ? Colors.transparent
                                        : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12 * fontScale,
                                fontWeight: FontWeight.w700,
                                color:
                                    i <= 1
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _steps[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12 * fontScale,
                              fontWeight:
                                  i == 1 ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  i == 1
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
