part of '../project_progress_view.dart';

class _BuildBody extends StatelessWidget {
  const _BuildBody({
    required this.progress,
    required this.fontScale,
    required this.sectionGap,
    required this.subGap,
  });

  final ConstructionProgress progress;
  final double fontScale;
  final double sectionGap;
  final double subGap;

  @override
  Widget build(BuildContext context) {
    final List<PublicSitePhoto> photos = progress.previewPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Badge(label: '공사 진행중'),
        SizedBox(height: sectionGap),
        if (progress.trades.isNotEmpty) ...[
          Text('이 현장 공정', style: _kicker(fontScale)),
          const SizedBox(height: 10),
          _TradeTrack(
            trades: progress.trades,
            index: progress.tradeIndex,
            fontScale: fontScale,
          ),
          SizedBox(height: sectionGap),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('현재', style: _kicker(fontScale)),
                  const SizedBox(height: 4),
                  Text(
                    progress.currentLabel,
                    style: TextStyle(
                      fontSize: 24 * fontScale,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (progress.expectedCompletion.isNotEmpty) ...[
              const SizedBox(width: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('예상 완료', style: _kicker(fontScale)),
                      const SizedBox(height: 2),
                      Text(
                        progress.expectedCompletion,
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: sectionGap),
        _ScheduleCard(progress: progress, fontScale: fontScale),
        if (photos.isNotEmpty) ...[
          SizedBox(height: sectionGap),
          Text('최근 현장사진', style: _sectionTitle(fontScale)),
          SizedBox(height: subGap),
          _PhotoMosaic(photos: photos, fontScale: fontScale),
        ],
      ],
    );
  }
}

class _TradeTrack extends StatelessWidget {
  const _TradeTrack({
    required this.trades,
    required this.index,
    required this.fontScale,
  });

  final List<String> trades;
  final int index;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < trades.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trades[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11 * fontScale,
                      fontWeight:
                          i == index ? FontWeight.w700 : FontWeight.w500,
                      color:
                          i == index
                              ? AppColors.primary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatefulWidget {
  const _ScheduleCard({required this.progress, required this.fontScale});

  final ConstructionProgress progress;
  final double fontScale;

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  bool _sidesOpen = false;

  @override
  Widget build(BuildContext context) {
    final ConstructionProgress progress = widget.progress;
    final double fontScale = widget.fontScale;
    final String todayNote = progress.todayNote;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.construction_outlined,
                          size: 18,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '오늘',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xB3FFFFFF),
                          ),
                        ),
                        const Spacer(),
                        if (progress.todayMark.isNotEmpty)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                progress.todayMark,
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  fontWeight: FontWeight.w700,
                                  color: _markColor(progress.today),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      progress.todayTitle,
                      style: TextStyle(
                        fontSize: 22 * fontScale,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: -0.4,
                        color: AppColors.white,
                      ),
                    ),
                    if (todayNote.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        todayNote,
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          height: 1.4,
                          color: const Color(0xD9FFFFFF),
                        ),
                      ),
                    ],
                    if (progress.showsWorkers) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.engineering_outlined,
                            size: 16,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              progress.workers,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (progress.showsSideTrades) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _sidesOpen = !_sidesOpen),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '함께 진행중 ${progress.sideTrades.length}개',
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      Icon(
                        _sidesOpen ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),
              if (_sidesOpen)
                for (final SideTrade trade in progress.sideTrades)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trade.when.isEmpty
                                  ? trade.name
                                  : '${trade.name} · ${trade.when}',
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (trade.summary.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                trade.summary,
                                style: TextStyle(
                                  fontSize: 13 * fontScale,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 10),
                    Text(progress.nextLabel, style: _kicker(fontScale)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        progress.nextTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (progress.nextSummary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  progress.nextSummary,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoMosaic extends StatelessWidget {
  const _PhotoMosaic({required this.photos, required this.fontScale});

  final List<PublicSitePhoto> photos;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    if (photos.length == 1) {
      return SizedBox(
        height: 200,
        child: _PhotoFill(photo: photos.first, fontScale: fontScale),
      );
    }
    final List<PublicSitePhoto> rest = photos.skip(1).toList();
    return SizedBox(
      height: 196,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _PhotoFill(photo: photos.first, fontScale: fontScale),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                for (var i = 0; i < rest.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Expanded(
                    child: _PhotoFill(
                      photo: rest[i],
                      fontScale: fontScale,
                      compact: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFill extends StatelessWidget {
  const _PhotoFill({
    required this.photo,
    required this.fontScale,
    this.compact = false,
  });

  final PublicSitePhoto photo;
  final double fontScale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${photo.takenOn} ${photo.trade}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: photo.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC0B1F38)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.trade,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (compact ? 11 : 13) * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    photo.takenOn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (compact ? 10 : 11) * fontScale,
                      color: const Color(0xD9FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

const ConstructionProgress _sampleBuild = ConstructionProgress(
  currentLabel: '목공 공사 진행중',
  expectedCompletion: '11월 18일',
  today: TodayWorkState.underway,
  todayTrade: '목공 공사',
  todaySummary: '벽과 천장 틀을 맞추고 있어요',
  workers: '목수 2명',
  trades: ['철거', '설비·급배수', '목공', '전기', '도장', '마감'],
  tradeIndex: 2,
  nextWhen: '내일',
  nextTrade: '전기 공사',
  nextSummary: '조명과 콘센트 배선을 시작해요',
);

TextStyle _kicker(double fontScale) {
  return TextStyle(
    fontSize: 12 * fontScale,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}

TextStyle _sectionTitle(double fontScale) {
  return TextStyle(
    fontSize: 16 * fontScale,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );
}

Color _markColor(TodayWorkState today) {
  switch (today) {
    case TodayWorkState.underway:
      return AppColors.accent;
    case TodayWorkState.checking:
    case TodayWorkState.idle:
      return AppColors.textSecondary;
    case TodayWorkState.closing:
      return AppColors.primary;
  }
}
