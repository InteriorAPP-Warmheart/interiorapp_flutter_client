part of '../project_progress_view.dart';

class _PlanTalk extends StatelessWidget {
  const _PlanTalk({required this.decision, required this.fontScale});

  final PlanDecision decision;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PlanBubble(
                  name: '고객',
                  mark: '고',
                  body: decision.customerNote,
                  fontScale: fontScale,
                  mine: true,
                ),
                const SizedBox(height: 12),
                _PlanBubble(
                  name: '담당자',
                  mark: '담',
                  body: decision.staffNote,
                  fontScale: fontScale,
                  mine: false,
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '결론',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xB3FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    decision.conclusion,
                    style: TextStyle(
                      fontSize: 17 * fontScale,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBubble extends StatelessWidget {
  const _PlanBubble({
    required this.name,
    required this.mark,
    required this.body,
    required this.fontScale,
    required this.mine,
  });

  final String name;
  final String mark;
  final String body;
  final double fontScale;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final Color avatar = mine ? AppColors.accent : AppColors.primary;
    final Widget face = DecoratedBox(
      decoration: BoxDecoration(color: avatar, shape: BoxShape.circle),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            mark,
            style: TextStyle(
              fontSize: 13 * fontScale,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
    final Widget message = Column(
      crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 12 * fontScale,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: avatar,
          ),
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: mine ? const Color(0xFFE7EBE4) : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(mine ? 18 : 6),
              topRight: Radius.circular(mine ? 6 : 18),
              bottomLeft: const Radius.circular(18),
              bottomRight: const Radius.circular(18),
            ),
            border: mine ? null : Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              body,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!mine) ...[face, const SizedBox(width: 8)],
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: message,
                ),
              );
            },
          ),
        ),
        if (mine) ...[const SizedBox(width: 8), face],
      ],
    );
  }
}
