part of '../project_progress_view.dart';

class _PrepStage extends StatelessWidget {
  const _PrepStage({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(text: '들어가기 전 준비예요', fontScale: fontScale),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PrepTile(
                  icon: Icons.inventory_2_outlined,
                  label: '자재',
                  value: '맞추는 중',
                  fontScale: fontScale,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrepTile(
                  icon: Icons.account_tree_outlined,
                  label: '순서',
                  value: '정하는 중',
                  fontScale: fontScale,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrepTile(
                  icon: Icons.event_outlined,
                  label: '착공일',
                  value: '미정',
                  fontScale: fontScale,
                  emphasized: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SignalBar(
          icon: Icons.construction_outlined,
          title: '착공하면 오늘·내일 공정이 열려요',
          note: '공사진행으로 넘어간 뒤에 나와요',
          fontScale: fontScale,
          tone: _SignalTone.quiet,
        ),
      ],
    );
  }
}
