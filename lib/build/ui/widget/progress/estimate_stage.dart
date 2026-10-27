part of '../project_progress_view.dart';

class _EstimateStage extends StatelessWidget {
  const _EstimateStage({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(text: '금액을 확인해요', fontScale: fontScale),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.surface),
            child: Column(
              children: [
                ColoredBox(
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Row(
                      children: [
                        Text(
                          '견적서',
                          style: TextStyle(
                            fontSize: 20 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              '확인 전',
                              style: TextStyle(
                                fontSize: 12 * fontScale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _QuoteRow(
                  label: '금액',
                  value: '시공안 범위 기준',
                  fontScale: fontScale,
                ),
                const Divider(height: 1, color: AppColors.border),
                _QuoteRow(
                  label: '포함',
                  value: '이번에 하는 공사',
                  fontScale: fontScale,
                ),
                const Divider(height: 1, color: AppColors.border),
                _QuoteRow(
                  label: '일정',
                  value: '금액과 함께 표기',
                  fontScale: fontScale,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SignalBar(
          icon: Icons.draw_outlined,
          title: '확인은 계약이 아니에요',
          note: '동의하면 계약서를 따로 봐요',
          fontScale: fontScale,
          tone: _SignalTone.quiet,
        ),
      ],
    );
  }
}
