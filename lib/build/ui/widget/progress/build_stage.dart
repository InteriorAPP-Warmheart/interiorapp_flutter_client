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
                detail: _dayWorkDetail(
                  progress: progress,
                  isToday: isToday,
                  fontScale: fontScale,
                ),
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
    final List<SitePhotoRecord> timeline = sitePhotoRecords(
      progress.recentPhotos,
    );
    final String dayLabel = sitePhotoDayLabel(day);
    final List<SitePhotoRecord> records = <SitePhotoRecord>[
      for (final SitePhotoRecord record in timeline)
        if (record.takenOn == dayLabel) record,
    ];
    final List<SitePhotoRecord> shown =
        records.length <= _dayPhotoPreview
            ? records
            : records.sublist(0, _dayPhotoPreview);
    final int totalDone = sitePhotoDoneCount(timeline);
    final List<SiteWorker> crew =
        isToday ? progress.crew : const <SiteWorker>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              Row(
                children: [
                  Text('현장사진', style: _recordLabel(fontScale)),
                  if (totalDone > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '$totalDone장',
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (progress.recentPhotos.isNotEmpty)
                    GestureDetector(
                      onTap:
                          () => openSitePhotoLibrary(
                            context,
                            progress.recentPhotos,
                          ),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          '전체',
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (records.isEmpty)
                Text('이 날의 현장사진이 아직 없어요', style: _recordEmpty(fontScale))
              else ...[
                for (int i = 0; i < shown.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  SitePhotoPreviewCard(
                    record: shown[i],
                    fontScale: fontScale,
                    onTap:
                        () => openSitePhotoViewer(
                          context,
                          shown[i],
                          timeline: timeline,
                        ),
                  ),
                ],
                if (records.length > shown.length) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap:
                        () => openSitePhotoDay(
                          context,
                          dayLabel: dayLabel,
                          records: records,
                          timeline: timeline,
                        ),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      '이 날 사진 모두 보기',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

const int _dayPhotoPreview = 2;

Widget? _dayWorkDetail({
  required ConstructionProgress progress,
  required bool isToday,
  required double fontScale,
}) {
  if (!isToday) {
    return Text('이 날의 작업 내용이 아직 없어요', style: _recordEmpty(fontScale));
  }
  final String headline = progress.currentLabel;
  final String mark = progress.todayMark;
  final String title = progress.todayTitle;
  final String note = progress.todayNote;
  final bool showMark = mark.isNotEmpty && !headline.contains(mark);
  final bool showTitle =
      title.isNotEmpty && title != headline && !headline.contains(title);
  if (!showMark && !showTitle && note.isEmpty) return null;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (showMark) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                mark,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: _markColor(progress.today),
                ),
              ),
            ),
          ),
        ),
        if (showTitle || note.isNotEmpty) const SizedBox(height: 10),
      ],
      if (showTitle)
        Text(
          title,
          style: TextStyle(
            fontSize: 16 * fontScale,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      if (note.isNotEmpty) ...[
        if (showTitle) const SizedBox(height: 6),
        Text(
          note,
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ],
  );
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
    return _SurfaceBand(
      onTap: () => showSiteSupervisorDialog(context, supervisor),
      child: Row(
        children: [
          SitePersonAvatar(
            name: supervisor.name,
            imageUrl: supervisor.imageUrl,
            size: 48,
            fontScale: fontScale,
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
                if (supervisor.phone.isNotEmpty)
                  Text(
                    supervisor.phone,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SurfaceBand extends StatelessWidget {
  const _SurfaceBand({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final Padding content = Padding(
      padding: EdgeInsets.fromLTRB(inset.left, 16, inset.right, 16),
      child: child,
    );
    if (onTap == null) {
      return ColoredBox(color: AppColors.surface, child: content);
    }
    return Material(
      color: AppColors.surface,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({
    required this.worker,
    required this.fontScale,
    this.showPhone = false,
  });

  final SiteWorker worker;
  final double fontScale;
  final bool showPhone;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSiteWorkerDialog(context, worker, showPhone: showPhone),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SitePersonAvatar(
            name: worker.name,
            imageUrl: worker.imageUrl,
            size: 44,
            fontScale: fontScale,
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
                if (showPhone && worker.phone.isNotEmpty)
                  Text(
                    worker.phone,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
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
  supervisor: SiteSupervisor(
    name: '오세진',
    duty: '현장 진행, 일정, 오늘 작업',
    organization: '바론 인테리어',
    bio: '현장 일정과 마감 품질을 함께 보고 있습니다',
    phone: '010-6201-8842',
    imageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&crop=faces&w=800&h=1000&q=80',
  ),
  crew: <SiteWorker>[
    SiteWorker(
      name: '한도윤',
      role: '목수',
      work: '벽과 천장 틀',
      organization: '한결목공',
      career: '14년',
      bio: '평생 노가다로 밥벌어먹고 살아왔읍니다.',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&crop=faces&w=800&h=1000&q=80',
    ),
    SiteWorker(
      name: '서민재',
      role: '목수',
      work: '문틀과 몰딩',
      organization: '한결목공',
      career: '9년',
      bio: '안녕하세요 평생을 일해온 목수의 자부심을 다마서 좋은 결과물로 보답해드리겠읍니다.',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&crop=faces&w=800&h=1000&q=80',
    ),
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
