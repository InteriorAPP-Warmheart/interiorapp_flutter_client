part of '../project_progress_view.dart';

class _ContractStage extends StatelessWidget {
  const _ContractStage({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(text: '서명은 따로 해요', fontScale: fontScale),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: _card,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              children: [
                _SignStep(
                  index: '1',
                  title: '계약서 열람',
                  note: '금액 · 범위 · 일정',
                  active: true,
                  fontScale: fontScale,
                  showLine: true,
                ),
                _SignStep(
                  index: '2',
                  title: '서명',
                  note: '열어 본 것과 별개로 남아요',
                  active: false,
                  fontScale: fontScale,
                  showLine: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SignalBar(
          icon: Icons.flag_outlined,
          title: '서명과 착수금 후 착공준비',
          note: '그 전에 현장 일정은 확정하지 않아요',
          fontScale: fontScale,
        ),
      ],
    );
  }
}
