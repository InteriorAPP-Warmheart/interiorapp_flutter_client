part of '../project_progress_view.dart';

const List<ProjectDocument> _waitingDocuments = [
  ProjectDocument(
    kind: ProjectDocumentKind.proposal,
    title: '제안서',
    note: '평면과 공간',
  ),
  ProjectDocument(
    kind: ProjectDocumentKind.model,
    title: '3D 도면',
    note: '공간 도면',
  ),
  ProjectDocument(
    kind: ProjectDocumentKind.draft,
    title: '공사시안',
    note: '마감 시안',
  ),
];

class _QuoteStage extends StatelessWidget {
  const _QuoteStage({
    required this.plan,
    required this.quote,
    required this.fontScale,
  });

  final ConstructionPlan? plan;
  final WorkQuote? quote;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final WorkQuote? current = quote;
    final List<_ShownJudgment> judgments = _judgments(current, plan);
    final List<ProjectDocument> source =
        current == null || current.documents.isEmpty
            ? _waitingDocuments
            : current.documents;
    final List<ProjectDocument> documents = [
      for (final ProjectDocument document in source)
        if (document.kind != ProjectDocumentKind.estimate) document,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(text: '시공과 금액을 함께 봐요', fontScale: fontScale),
        const SizedBox(height: 16),
        _QuoteHero(quote: current, fontScale: fontScale),
        const SizedBox(height: 20),
        _SectionLabel(text: '시공 자료', fontScale: fontScale),
        const SizedBox(height: 8),
        _DocumentGrid(
          documents: documents,
          quote: current,
          fontScale: fontScale,
        ),
        const SizedBox(height: 6),
        Text(
          '공정표는 계약 후에 상담을 통해서 만들어져요.',
          style: TextStyle(
            fontSize: 12 * fontScale,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (judgments.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel(text: '상담 내역', fontScale: fontScale),
          const SizedBox(height: 8),
          for (var i = 0; i < judgments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _JudgmentCard(
              item: judgments[i],
              quote: current,
              fontScale: fontScale,
            ),
          ],
        ],

        if (current != null && current.sheet.conditions.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel(text: '견적 조건', fontScale: fontScale),
          const SizedBox(height: 8),
          _ConditionCard(lines: current.sheet.conditions, fontScale: fontScale),
        ],
      ],
    );
  }
}

class _ShownJudgment {
  const _ShownJudgment({
    required this.mark,
    required this.conclusion,
    required this.note,
    required this.decision,
    this.tradeName = '',
  });

  final String mark;
  final String conclusion;
  final String note;
  final PlanDecision decision;
  final String tradeName;
}

List<_ShownJudgment> _judgments(WorkQuote? quote, ConstructionPlan? plan) {
  if (quote != null && quote.judgments.isNotEmpty) {
    return [
      for (final QuoteJudgment item in quote.judgments)
        _ShownJudgment(
          mark: item.effect.mark,
          conclusion: item.conclusion,
          note: item.tradeName,
          tradeName: item.tradeName,
          decision: PlanDecision(
            conclusion: item.conclusion,
            customerNote: item.customerNote,
            staffNote: item.staffNote,
          ),
        ),
    ];
  }
  if (plan == null) return const <_ShownJudgment>[];
  return [
    for (final PlanDecision item in plan.scope)
      _ShownJudgment(
        mark: '포함',
        conclusion: item.conclusion,
        note: '',
        decision: item,
      ),
    for (final PlanDecision item in plan.excluded)
      _ShownJudgment(
        mark: '제외',
        conclusion: item.conclusion,
        note: '',
        decision: item,
      ),
    for (final PlanDecision item in plan.constraints)
      _ShownJudgment(
        mark: '조건',
        conclusion: item.conclusion,
        note: '',
        decision: item,
      ),
  ];
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.fontScale});

  final String text;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13 * fontScale,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _QuoteHero extends StatelessWidget {
  const _QuoteHero({required this.quote, required this.fontScale});

  final WorkQuote? quote;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final WorkQuote? current = quote;
    if (current == null) {
      return DecoratedBox(
        decoration: _card,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: _WaitingAmount(fontScale: fontScale),
        ),
      );
    }
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openEstimate(context, current),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: _ReadyAmount(
            quote: current,
            sheet: current.sheet,
            fontScale: fontScale,
          ),
        ),
      ),
    );
  }
}

class _ReadyAmount extends StatelessWidget {
  const _ReadyAmount({
    required this.quote,
    required this.sheet,
    required this.fontScale,
  });

  final WorkQuote quote;
  final EstimateSheet sheet;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final int percent = (sheet.vatRate * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '공사비',
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w700,
                color: const Color(0xD9FFFFFF),
              ),
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  quote.statusLabel,
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
        const SizedBox(height: 14),
        QuoteMoneySummary(
          material: sheet.material,
          labor: sheet.labor,
          fontScale: fontScale,
          onDark: true,
          vatPercent: percent,
          vatIncluded: sheet.grandTotal,
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0x33FFFFFF)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '견적서 보기',
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18 * fontScale,
              color: AppColors.white,
            ),
          ],
        ),
      ],
    );
  }
}

class _WaitingAmount extends StatelessWidget {
  const _WaitingAmount({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '공사비',
          style: TextStyle(
            fontSize: 13 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '견적서가 오면 여기에 나와요',
          style: TextStyle(
            fontSize: 18 * fontScale,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DocumentGrid extends StatelessWidget {
  const _DocumentGrid({
    required this.documents,
    required this.quote,
    required this.fontScale,
  });

  final List<ProjectDocument> documents;
  final WorkQuote? quote;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool trio = documents.length == 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: documents.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: trio ? 3 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: (trio ? 124 : 108) * fontScale,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ProjectDocument document = documents[index];
        return _DocumentTile(
          document: document,
          fontScale: fontScale,
          noteLines: trio ? 2 : 1,
          onTap:
              document.ready && quote != null
                  ? () => _openDocument(context, quote!, document)
                  : null,
        );
      },
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.fontScale,
    required this.onTap,
    this.noteLines = 1,
  });

  final ProjectDocument document;
  final double fontScale;
  final VoidCallback? onTap;
  final int noteLines;

  @override
  Widget build(BuildContext context) {
    final bool ready = onTap != null;
    return DecoratedBox(
      decoration: _card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _documentIcon(document.kind),
                  size: 20,
                  color: ready ? AppColors.accent : AppColors.textSecondary,
                ),
                const Spacer(),
                Text(
                  document.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w700,
                    color:
                        ready ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ready ? document.note : '아직 없어요',
                  maxLines: noteLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _documentIcon(ProjectDocumentKind kind) {
  switch (kind) {
    case ProjectDocumentKind.estimate:
      return Icons.receipt_long_outlined;
    case ProjectDocumentKind.proposal:
      return Icons.menu_book_outlined;
    case ProjectDocumentKind.model:
      return Icons.view_in_ar_outlined;
    case ProjectDocumentKind.draft:
      return Icons.architecture_outlined;
  }
}

class _JudgmentCard extends StatelessWidget {
  const _JudgmentCard({
    required this.item,
    required this.quote,
    required this.fontScale,
  });

  final _ShownJudgment item;
  final WorkQuote? quote;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool opens =
        item.decision.customerNote.trim().isNotEmpty ||
        item.decision.staffNote.trim().isNotEmpty;
    return DecoratedBox(
      decoration: _card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              opens
                  ? () => _openJudgment(context, item, quote, fontScale)
                  : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    item.mark,
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.conclusion,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.note,
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (opens)
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

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({required this.lines, required this.fontScale});

  final List<String> lines;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                child: Text(
                  '${i + 1}. ${lines[i]}',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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

void _openDocument(
  BuildContext context,
  WorkQuote quote,
  ProjectDocument document,
) {
  switch (document.kind) {
    case ProjectDocumentKind.estimate:
      _openEstimate(context, quote);
    case ProjectDocumentKind.proposal:
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ProposalReaderScreen(quote: quote),
        ),
      );
    case ProjectDocumentKind.model:
    case ProjectDocumentKind.draft:
      return;
  }
}

void _openEstimate(
  BuildContext context,
  WorkQuote quote, {
  String tradeName = '',
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder:
          (BuildContext context) =>
              EstimateReaderScreen(quote: quote, initialTrade: tradeName),
    ),
  );
}

void _openJudgment(
  BuildContext context,
  _ShownJudgment item,
  WorkQuote? quote,
  double fontScale,
) {
  final WorkQuote? current = quote;
  final String tradeName = item.tradeName;
  final bool linked =
      current != null &&
      tradeName.isNotEmpty &&
      current.sheet.tradeNamed(tradeName) != null;
  showAppBottomSheet<void>(
    context: context,
    title: item.conclusion,
    size: AppBottomSheetSize.expanded,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        _PlanTalk(decision: item.decision, fontScale: fontScale),
        if (linked) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              final EstimateTrade? trade = current.sheet.tradeNamed(tradeName);
              Navigator.of(context).pop();
              if (trade == null) return;
              showEstimateTradeSheet(context, trade);
            },
            child: Text(
              '$tradeName 금액 보기',
              style: TextStyle(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
