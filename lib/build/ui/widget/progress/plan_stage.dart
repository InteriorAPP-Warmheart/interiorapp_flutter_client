part of '../project_progress_view.dart';

class _PlanStage extends StatelessWidget {
  const _PlanStage({
    required this.record,
    required this.plan,
    required this.fontScale,
  });

  final PrepRecord? record;
  final ConstructionPlan? plan;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final PrepRecord? current = record;
    final ConstructionPlan? decisions = plan;
    final String industry =
        current == null ? '확인 중' : _shown(current.industryLine);
    final String workScope =
        current == null || current.workScope.trim().isEmpty
            ? '확인 중'
            : current.workScope.trim();
    final List<_PlanTopic> topics = [
      _PlanTopic(
        index: '01',
        title: '범위',
        empty: '살릴 곳과 바꿀 곳이 정리되면 여기에 나와요.',
        items: decisions?.scope ?? const <PlanDecision>[],
      ),
      _PlanTopic(
        index: '02',
        title: '제외',
        empty: '이번에 하지 않는 공사가 정리되면 여기에 나와요.',
        items: decisions?.excluded ?? const <PlanDecision>[],
      ),
      _PlanTopic(
        index: '03',
        title: '제약',
        empty: '현장에서 확인한 조건이 정리되면 여기에 나와요.',
        items: decisions?.constraints ?? const <PlanDecision>[],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(text: '시공안을 확인해요', fontScale: fontScale),
        const SizedBox(height: 16),
        _PlanFacts(
          industry: industry,
          workScope: workScope,
          fontScale: fontScale,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < topics.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _PlanTopicCard(topic: topics[i], fontScale: fontScale),
        ],
        const SizedBox(height: 12),
        _SignalBar(
          icon: Icons.payments_outlined,
          title: '이 범위가 견적 기준이에요',
          note: '범위가 맞으면 금액으로 넘어가요',
          fontScale: fontScale,
          tone: _SignalTone.quiet,
        ),
      ],
    );
  }
}

class _PlanTopic {
  const _PlanTopic({
    required this.index,
    required this.title,
    required this.empty,
    required this.items,
  });

  final String index;
  final String title;
  final String empty;
  final List<PlanDecision> items;
}

class _PlanFacts extends StatelessWidget {
  const _PlanFacts({
    required this.industry,
    required this.workScope,
    required this.fontScale,
  });

  final String industry;
  final String workScope;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          children: [
            _PlanFact(label: '업종', value: industry, fontScale: fontScale),
            const Divider(height: 1, color: AppColors.border),
            _PlanFact(label: '공사 범위', value: workScope, fontScale: fontScale),
          ],
        ),
      ),
    );
  }
}

class _PlanFact extends StatelessWidget {
  const _PlanFact({
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: _kicker(fontScale).copyWith(height: 1.15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTopicCard extends StatelessWidget {
  const _PlanTopicCard({required this.topic, required this.fontScale});

  final _PlanTopic topic;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool ready = topic.items.isNotEmpty;
    return DecoratedBox(
      decoration: _card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: ready ? () => _openPlanTopic(context, topic, fontScale) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.index,
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!ready)
                        Text(
                          topic.empty,
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        for (final PlanDecision item in topic.items)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.conclusion,
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                if (ready)
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openPlanTopic(BuildContext context, _PlanTopic topic, double fontScale) {
  showAppBottomSheet<void>(
    context: context,
    title: topic.title,
    size: AppBottomSheetSize.expanded,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        for (var i = 0; i < topic.items.length; i++) ...[
          if (i > 0) const SizedBox(height: 28),
          _PlanTalk(decision: topic.items[i], fontScale: fontScale),
        ],
      ],
    ),
  );
}

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
