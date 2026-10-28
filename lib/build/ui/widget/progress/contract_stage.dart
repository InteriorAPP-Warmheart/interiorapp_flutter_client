part of '../project_progress_view.dart';

class _ContractStage extends StatelessWidget {
  const _ContractStage({
    required this.fontScale,
    required this.reviewed,
    required this.signed,
    required this.onOpen,
  });

  final double fontScale;
  final bool reviewed;
  final bool signed;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (!reviewed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Headline(text: '계약은 확인 다음이에요', fontScale: fontScale),
          const SizedBox(height: 16),
          _SignalBar(
            icon: Icons.swipe_right_alt_outlined,
            title: '시공·견적을 먼저 확인해요',
            note: '내용을 밀어서 확인하면 계약으로 넘어가요',
            fontScale: fontScale,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(
          text: signed ? '계약요청을 보냈어요' : '계약을 확인해요',
          fontScale: fontScale,
        ),
        const SizedBox(height: 16),
        _SignalBar(
          icon: Icons.person_pin_circle_outlined,
          title: '담당자가 방문해서 계약해요',
          note: '온라인만으로는 계약이 되지 않아요',
          fontScale: fontScale,
        ),
        const SizedBox(height: 16),
        _ContractEntry(
          title: '계약서',
          note: '금액과 공사 범위',
          fontScale: fontScale,
          onTap: onOpen,
        ),
        const SizedBox(height: 8),
        _ContractEntry(
          title: '결제 요율',
          note: '선납금 · 중도금 · 잔금',
          fontScale: fontScale,
          onTap: onOpen,
        ),
        const SizedBox(height: 8),
        _ContractEntry(
          title: '결제 방식',
          note: '제3자 은행이 맡았다가 결제일에 빠져나가요',
          fontScale: fontScale,
          onTap: onOpen,
        ),
        const SizedBox(height: 16),
        AppButton(label: signed ? '계약요청했어요' : '계약 내용 보기', onPressed: onOpen),
      ],
    );
  }
}

class _ContractEntry extends StatelessWidget {
  const _ContractEntry({
    required this.title,
    required this.note,
    required this.fontScale,
    required this.onTap,
  });

  final String title;
  final String note;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
