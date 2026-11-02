part of '../project_progress_view.dart';

class _BuildBody extends StatefulWidget {
  const _BuildBody({required this.progress, required this.fontScale});

  final ConstructionProgress progress;
  final double fontScale;

  @override
  State<_BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<_BuildBody> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = appCalendarDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final ConstructionProgress progress = widget.progress;
    final double fontScale = widget.fontScale;
    final bool isToday = appCalendarSameDay(_selected, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (progress.supervisor != null) ...[
          _SupervisorBand(
            supervisor: progress.supervisor!,
            fontScale: fontScale,
          ),
          const SizedBox(height: 8),
        ],
        if (progress.expectedCompletion.isNotEmpty) ...[
          _SurfaceBand(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '공사 예상 완료',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
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
          const SizedBox(height: 8),
        ],
        _SurfaceBand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProcessWeekStrip(
                selected: _selected,
                onSelected: (DateTime day) => setState(() => _selected = day),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),
              ProcessDayPanel(
                day: _selected,
                fontScale: fontScale,
                isToday: isToday,
                todayLabel: progress.currentLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _DayRecord(
          progress: progress,
          day: _selected,
          isToday: isToday,
          fontScale: fontScale,
        ),
      ],
    );
  }
}

class _DayRecord extends StatelessWidget {
  const _DayRecord({
    required this.progress,
    required this.day,
    required this.isToday,
    required this.fontScale,
  });

  final ConstructionProgress progress;
  final DateTime day;
  final bool isToday;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final List<PublicSitePhoto> photos = _photosOn(progress.recentPhotos, day);
    final List<SiteWorker> crew =
        isToday ? progress.crew : const <SiteWorker>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SurfaceBand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('작업 내용', style: _recordLabel(fontScale)),
              const SizedBox(height: 12),
              if (isToday) ...[
                if (progress.todayMark.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  progress.todayTitle,
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (progress.todayNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    progress.todayNote,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ] else
                Text('이 날의 작업 내용이 아직 없어요', style: _recordEmpty(fontScale)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _SurfaceBand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('인력', style: _recordLabel(fontScale)),
              const SizedBox(height: 12),
              if (crew.isEmpty)
                Text('이 날의 인력 정보가 아직 없어요', style: _recordEmpty(fontScale))
              else
                for (int i = 0; i < crew.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                  _WorkerCard(worker: crew[i], fontScale: fontScale),
                ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        _SurfaceBand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('현장사진', style: _recordLabel(fontScale)),
              const SizedBox(height: 12),
              if (photos.isEmpty)
                Text('이 날의 현장사진이 아직 없어요', style: _recordEmpty(fontScale))
              else
                _PhotoMosaic(photos: photos, fontScale: fontScale),
            ],
          ),
        ),
      ],
    );
  }
}

List<PublicSitePhoto> _photosOn(List<PublicSitePhoto> photos, DateTime day) {
  final String label = '${day.month}월 ${day.day}일';
  final List<PublicSitePhoto> matched =
      photos.where((PublicSitePhoto photo) => photo.takenOn == label).toList();
  if (matched.length <= 3) return matched;
  return matched.sublist(0, 3);
}

TextStyle _recordLabel(double fontScale) {
  return TextStyle(
    fontSize: 13 * fontScale,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );
}

TextStyle _recordEmpty(double fontScale) {
  return TextStyle(
    fontSize: 14 * fontScale,
    height: 1.4,
    color: AppColors.textSecondary,
  );
}

class _SupervisorBand extends StatelessWidget {
  const _SupervisorBand({required this.supervisor, required this.fontScale});

  final SiteSupervisor supervisor;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String initial =
        supervisor.name.isEmpty ? '감' : supervisor.name.substring(0, 1);
    return _SurfaceBand(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x140B1F38),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 18 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supervisor.role,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  supervisor.name,
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (supervisor.duty.isNotEmpty)
                  Text(
                    supervisor.duty,
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceBand extends StatelessWidget {
  const _SurfaceBand({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(inset.left, 16, inset.right, 16),
        child: child,
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.worker, required this.fontScale});

  final SiteWorker worker;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String initial =
        worker.name.isEmpty ? '·' : worker.name.substring(0, 1);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0x140B1F38),
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (worker.role.isNotEmpty)
                Text(
                  worker.role,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              Text(
                worker.name,
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (worker.work.isNotEmpty)
                Text(
                  worker.work,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
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
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _PhotoFill(photo: photos.first, fontScale: fontScale),
      );
    }
    final List<PublicSitePhoto> rest = photos.skip(1).toList();
    return AspectRatio(
      aspectRatio: 2,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _PhotoFill(photo: photos.first, fontScale: fontScale),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                for (var i = 0; i < rest.length; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
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
  supervisor: SiteSupervisor(name: '오세진', duty: '현장 진행, 일정, 오늘 작업'),
  crew: <SiteWorker>[
    SiteWorker(name: '한도윤', role: '목수', work: '벽과 천장 틀'),
    SiteWorker(name: '서민재', role: '목수', work: '문틀과 몰딩'),
  ],
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
