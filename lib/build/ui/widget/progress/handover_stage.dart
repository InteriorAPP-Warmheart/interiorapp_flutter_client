part of '../project_progress_view.dart';

enum _HandoverStep { inspect, confirm, settle }

class _HandoverStage extends StatefulWidget {
  const _HandoverStage({
    required this.fontScale,
    required this.photos,
    required this.quote,
    required this.step,
    required this.onSelectStep,
    required this.projectId,
    required this.done,
  });

  final double fontScale;
  final List<PublicSitePhoto> photos;
  final WorkQuote? quote;
  final _HandoverStep step;
  final ValueChanged<_HandoverStep> onSelectStep;
  final String projectId;
  final bool done;

  @override
  State<_HandoverStage> createState() => _HandoverStageState();
}

class _HandoverStageState extends State<_HandoverStage> {
  final Map<String, _ZoneAnswer> _answers = <String, _ZoneAnswer>{};
  final Map<String, TextEditingController> _notes =
      <String, TextEditingController>{};
  final Set<String> _open = <String>{};
  bool _submitted = false;
  bool _companyConfirmed = false;
  bool _settled = false;

  @override
  void dispose() {
    for (final TextEditingController note in _notes.values) {
      note.dispose();
    }
    super.dispose();
  }

  List<_InspectZone> get _zones {
    final List<SitePhotoZone> zones = sitePhotoZones(
      sitePhotoRecords(widget.photos),
    );
    return <_InspectZone>[
      for (final SitePhotoZone zone in zones)
        if (zone.area.isNotEmpty)
          _InspectZone(
            area: zone.area,
            imageUrl: zone.coverRecord?.cover.imageUrl ?? '',
          ),
    ];
  }

  _ZoneAnswer _answer(String area) {
    return _answers.putIfAbsent(area, _ZoneAnswer.new);
  }

  TextEditingController _noteOf(String key, _IssueNote issue) {
    return _notes.putIfAbsent(key, () {
      return TextEditingController(text: issue.text);
    });
  }

  Future<void> _addPhotos(_IssueNote issue) async {
    final List<String> urls = await pickWriteImages(
      context,
      photos: widget.photos,
      used:
          (String url) => issue.photos.any(
            (ShowroomReferenceRegion region) => region.imageUrl == url,
          ),
    );
    if (!mounted || urls.isEmpty) return;
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      var added = 0;
      for (final String url in urls) {
        final bool exists = issue.photos.any(
          (ShowroomReferenceRegion region) => region.imageUrl == url,
        );
        if (exists) continue;
        issue.photos.add(
          ShowroomReferenceRegion(
            id: 'inspect-$stamp-$added',
            label: '점검',
            imageUrl: url,
          ),
        );
        added++;
      }
    });
  }

  Future<void> _markPhoto(
    _IssueNote issue,
    ShowroomReferenceRegion region,
  ) async {
    final ShowroomReferenceRegion? saved = await showShowroomReferenceEditor(
      context,
      region,
      title: '사진 표시',
      saveLabel: '이 표시를 남기기',
      noteHint: '자세한 설명을 적어 주세요',
    );
    if (!mounted || saved == null || _submitted) return;
    setState(() {
      final int index = issue.photos.indexWhere(
        (ShowroomReferenceRegion item) => item.id == region.id,
      );
      if (index >= 0) issue.photos[index] = saved;
    });
  }

  void _clearIssue(String key, _IssueNote issue) {
    issue.text = '';
    issue.photos.clear();
    _notes[key]?.text = '';
  }

  bool get _ready {
    final List<_InspectZone> zones = _zones;
    if (zones.isEmpty) return false;
    for (final _InspectZone zone in zones) {
      if (!_answer(zone.area).complete) return false;
    }
    return true;
  }

  bool get _allClear {
    if (!_submitted) return false;
    for (final _InspectZone zone in _zones) {
      if (!_answer(zone.area).clear) return false;
    }
    return _zones.isNotEmpty;
  }

  bool get _bothConfirmed => _allClear && _companyConfirmed;

  int get _checkedCount {
    var count = 0;
    for (final _InspectZone zone in _zones) {
      if (_answer(zone.area).complete) count++;
    }
    return count;
  }

  void _submit() {
    if (!_ready) return;
    setState(() => _submitted = true);
  }

  void _reopen() {
    setState(() {
      _submitted = false;
      _companyConfirmed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = widget.fontScale;
    if (widget.done || _settled) {
      return _HandoverArchive(
        fontScale: fontScale,
        photos: widget.photos,
        projectId: widget.projectId,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HandoverRail(
          step: widget.step,
          fontScale: fontScale,
          onSelect: widget.onSelectStep,
        ),
        const SizedBox(height: 20),
        switch (widget.step) {
          _HandoverStep.inspect => _inspect(fontScale),
          _HandoverStep.confirm => _confirm(fontScale),
          _HandoverStep.settle => _settle(fontScale),
        },
      ],
    );
  }

  Widget _inspect(double fontScale) {
    final List<_InspectZone> zones = _zones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _submitted ? '점검 결과를 받았어요' : '구역마다 마감과 하자를 확인해요',
          style: TextStyle(
            fontSize: 22 * fontScale,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          zones.isEmpty
              ? '완성된 구역 사진이 오면 점검 목록이 생겨요'
              : '${zones.length}곳 중 $_checkedCount곳 확인',
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        if (_submitted) ...[
          const SizedBox(height: 16),
          _InspectResult(
            zones: zones,
            answerOf: _answer,
            allClear: _allClear,
            companyConfirmed: _companyConfirmed,
            fontScale: fontScale,
            onReopen: _reopen,
            onCompanyConfirm: () => setState(() => _companyConfirmed = true),
          ),
        ],
        const SizedBox(height: 16),
        for (var i = 0; i < zones.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ZoneCard(
            zone: zones[i],
            answer: _answer(zones[i].area),
            finishNote: _noteOf(
              '${zones[i].area}|finish',
              _answer(zones[i].area).finishIssue,
            ),
            defectNote: _noteOf(
              '${zones[i].area}|defect',
              _answer(zones[i].area).defect,
            ),
            requirementNote: _noteOf(
              '${zones[i].area}|need',
              _answer(zones[i].area).requirementIssue,
            ),
            open: _open.contains(zones[i].area),
            locked: _submitted,
            fontScale: fontScale,
            onToggle: () {
              setState(() {
                if (!_open.add(zones[i].area)) _open.remove(zones[i].area);
              });
            },
            onChanged: () => setState(() {}),
            onAddPhotos: _addPhotos,
            onOpenPhoto: _markPhoto,
            onRemovePhoto: (_IssueNote issue, ShowroomReferenceRegion region) {
              setState(
                () => issue.photos.removeWhere(
                  (ShowroomReferenceRegion item) => item.id == region.id,
                ),
              );
            },
            onClearIssue: _clearIssue,
          ),
        ],
        if (!_submitted && zones.isNotEmpty) ...[
          const SizedBox(height: 16),
          AppButton(label: '점검 제출', onPressed: _ready ? _submit : null),
        ],
      ],
    );
  }

  Widget _confirm(double fontScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _bothConfirmed ? '준공이 확인되었어요' : '양쪽이 확인하면 준공이 확정돼요',
          style: TextStyle(
            fontSize: 22 * fontScale,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '고객 확인과 업체 확인이 모이면 준공이 확정돼요.',
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        _PartyRow(
          title: '고객 확인',
          note: _submitted ? '점검을 마치고 확인했어요' : '점검 제출이 고객 확인이에요',
          done: _submitted && _allClear,
          fontScale: fontScale,
        ),
        const SizedBox(height: 8),
        _PartyRow(
          title: '업체 확인',
          note: _companyConfirmed ? '업체 확인을 마쳤어요' : '업체가 확인하면 준공이 확정돼요',
          done: _companyConfirmed,
          fontScale: fontScale,
        ),
      ],
    );
  }

  Widget _settle(double fontScale) {
    final int? total = widget.quote?.sheet.grandTotal;
    const List<(String, String, int, bool)> rounds =
        <(String, String, int, bool)>[
          ('선납금', '계약할 때', 40, true),
          ('중도금', '공사 중간에', 30, true),
          ('잔금', '준공 확인할 때', 30, false),
        ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _settled ? '잔금 정산을 마쳤어요' : '잔금을 정산해요',
          style: TextStyle(
            fontSize: 22 * fontScale,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _bothConfirmed
              ? '준공 확인이 끝났으니 은행이 맡아 둔 잔금이 빠져나가요.'
              : '준공 확인이 끝나면 은행이 맡아 둔 잔금이 빠져나가요.',
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: _card,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Column(
              children: [
                for (var i = 0; i < rounds.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                  _SettleRound(
                    name: rounds[i].$1,
                    when: rounds[i].$2,
                    percent: rounds[i].$3,
                    amount:
                        total == null
                            ? null
                            : (total * rounds[i].$3 / 100).round(),
                    done: rounds[i].$4 || (!rounds[i].$4 && _settled),
                    current: !rounds[i].$4 && !_settled,
                    fontScale: fontScale,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (total != null) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  '공사비 전체',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${formatWon(total)}원',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_settled)
          _SignalBar(
            icon: Icons.account_balance_outlined,
            title: '잔금이 빠져나갔어요',
            note: '에스크로에 맡아 둔 금액에서 잔금만 결제됐어요',
            fontScale: fontScale,
            tone: _SignalTone.quiet,
          )
        else
          AppButton(
            label: '잔금 정산',
            onPressed: () => setState(() => _settled = true),
          ),
      ],
    );
  }
}

class _HandoverArchive extends StatelessWidget {
  const _HandoverArchive({
    required this.fontScale,
    required this.photos,
    required this.projectId,
  });

  final double fontScale;
  final List<PublicSitePhoto> photos;
  final String projectId;

  List<SitePhotoZone> get _covers {
    return <SitePhotoZone>[
      for (final SitePhotoZone zone in sitePhotoZones(sitePhotoRecords(photos)))
        if (zone.coverRecord != null &&
            zone.coverRecord!.status == SitePhotoStatus.done &&
            zone.coverRecord!.cover.imageUrl.isNotEmpty)
          zone,
    ];
  }

  void _openShowroom(BuildContext context) {
    if (projectId.isEmpty) {
      context.push('/showroom-write');
      return;
    }
    context.push('/showroom-write/first-write?buildId=$projectId');
  }

  @override
  Widget build(BuildContext context) {
    final List<SitePhotoZone> covers = _covers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '준공된 공간',
          style: TextStyle(
            fontSize: 22 * fontScale,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '완공 사진과 시공 기록을 모아 두었어요.',
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (covers.isEmpty)
          Text(
            '완성된 구역 사진이 아직 없어요.',
            style: TextStyle(
              fontSize: 14 * fontScale,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: covers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (BuildContext context, int index) {
              final SitePhotoZone zone = covers[index];
              final SitePhotoRecord cover = zone.coverRecord!;
              return _ArchivePhoto(
                zone: zone,
                cover: cover,
                fontScale: fontScale,
                onTap:
                    () => openSitePhotoViewer(
                      context,
                      cover,
                      timeline: zone.records,
                    ),
              );
            },
          ),
        const SizedBox(height: 20),
        _ArchiveLink(
          title: '시공 기록',
          note: '공사 중 사진과 작업 기록을 봐요',
          fontScale: fontScale,
          onTap:
              photos.isEmpty
                  ? null
                  : () => openSitePhotoLibrary(context, photos),
        ),
        const SizedBox(height: 8),
        _ArchiveLink(
          title: '쇼룸에 올리기',
          note: '이 공간의 사진으로 쇼룸 글을 시작해요',
          fontScale: fontScale,
          onTap: () => _openShowroom(context),
        ),
        const SizedBox(height: 8),
        _ArchiveLink(
          title: 'A/S',
          note: '보증 기간과 남긴 접수를 봐요',
          fontScale: fontScale,
          onTap: () => openCareScreen(context, photos: photos),
        ),
      ],
    );
  }
}

class _ArchivePhoto extends StatelessWidget {
  const _ArchivePhoto({
    required this.zone,
    required this.cover,
    required this.fontScale,
    required this.onTap,
  });

  final SitePhotoZone zone;
  final SitePhotoRecord cover;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String area = zone.area.isEmpty ? cover.placeLabel : zone.area;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: AppNetworkImage(url: cover.cover.imageUrl)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${zone.donePhotoCount}장',
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveLink extends StatelessWidget {
  const _ArchiveLink({
    required this.title,
    required this.note,
    required this.fontScale,
    required this.onTap,
  });

  final String title;
  final String note;
  final double fontScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
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
                          color:
                              onTap == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
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
          ),
        ),
      ),
    );
  }
}

class _InspectZone {
  const _InspectZone({required this.area, required this.imageUrl});

  final String area;
  final String imageUrl;
}

class _IssueNote {
  String text = '';
  final List<ShowroomReferenceRegion> photos = <ShowroomReferenceRegion>[];

  bool get explained => text.trim().isNotEmpty;

  void clear() {
    text = '';
    photos.clear();
  }
}

class _ZoneAnswer {
  bool? finishOk;
  final _IssueNote finishIssue = _IssueNote();
  bool? hasDefect;
  final _IssueNote defect = _IssueNote();
  bool? requirementMet;
  final _IssueNote requirementIssue = _IssueNote();

  bool _issueReady(_IssueNote issue) => issue.explained;

  bool get complete {
    if (finishOk == null || hasDefect == null || requirementMet == null) {
      return false;
    }
    if (finishOk == false && !_issueReady(finishIssue)) return false;
    if (hasDefect == true && !_issueReady(defect)) return false;
    if (requirementMet == false && !_issueReady(requirementIssue)) return false;
    return true;
  }

  bool get clear =>
      finishOk == true && hasDefect == false && requirementMet == true;

  List<(String, String)> issues() {
    final List<(String, String)> lines = <(String, String)>[];
    if (finishOk == false) lines.add(('마감', finishIssue.text.trim()));
    if (hasDefect == true) lines.add(('하자', defect.text.trim()));
    if (requirementMet == false) {
      lines.add(('요구사항', requirementIssue.text.trim()));
    }
    return lines;
  }
}

class _HandoverRail extends StatelessWidget {
  const _HandoverRail({
    required this.step,
    required this.fontScale,
    required this.onSelect,
  });

  final _HandoverStep step;
  final double fontScale;
  final ValueChanged<_HandoverStep> onSelect;

  static const List<String> _labels = <String>['점검', '준공확인', '정산'];

  @override
  Widget build(BuildContext context) {
    final int index = step.index;
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _labels.length; i++)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(_HandoverStep.values[i]),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 22,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color:
                                        i == 0
                                            ? Colors.transparent
                                            : i <= index
                                            ? AppColors.primary
                                            : AppColors.border,
                                  ),
                                ),
                                _ProcessDot(
                                  done: i < index,
                                  current: i == index,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color:
                                        i == _labels.length - 1
                                            ? Colors.transparent
                                            : i < index
                                            ? AppColors.primary
                                            : AppColors.border,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _labels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (i == index ? 13 : 12) * fontScale,
                              height: 1.25,
                              fontWeight:
                                  i == index
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                              color:
                                  i <= index
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.zone,
    required this.answer,
    required this.finishNote,
    required this.defectNote,
    required this.requirementNote,
    required this.open,
    required this.locked,
    required this.fontScale,
    required this.onToggle,
    required this.onChanged,
    required this.onAddPhotos,
    required this.onOpenPhoto,
    required this.onRemovePhoto,
    required this.onClearIssue,
  });

  final _InspectZone zone;
  final _ZoneAnswer answer;
  final TextEditingController finishNote;
  final TextEditingController defectNote;
  final TextEditingController requirementNote;
  final bool open;
  final bool locked;
  final double fontScale;
  final VoidCallback onToggle;
  final VoidCallback onChanged;
  final Future<void> Function(_IssueNote issue) onAddPhotos;
  final Future<void> Function(_IssueNote issue, ShowroomReferenceRegion region)
  onOpenPhoto;
  final void Function(_IssueNote issue, ShowroomReferenceRegion region)
  onRemovePhoto;
  final void Function(String key, _IssueNote issue) onClearIssue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child:
                            zone.imageUrl.isEmpty
                                ? const ColoredBox(
                                  color: AppColors.imagePlaceholder,
                                )
                                : AppNetworkImage(url: zone.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.area,
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            answer.complete ? '확인함' : '확인 전',
                            style: TextStyle(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w600,
                              color:
                                  answer.complete
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChoiceRow(
                    label: '마감',
                    positive: '맞아요',
                    negative: '다시 봐요',
                    value: answer.finishOk,
                    fontScale: fontScale,
                    enabled: !locked,
                    onChanged: (bool value) {
                      answer.finishOk = value;
                      if (value) {
                        onClearIssue('${zone.area}|finish', answer.finishIssue);
                      }
                      onChanged();
                    },
                  ),
                  if (answer.finishOk == false)
                    _IssueFields(
                      issue: answer.finishIssue,
                      note: finishNote,
                      hint: '마감에서 어떤 점이 다른지 적어 주세요',
                      fontScale: fontScale,
                      enabled: !locked,
                      onChanged: (String value) {
                        answer.finishIssue.text = value;
                        onChanged();
                      },
                      onAddPhotos: () => onAddPhotos(answer.finishIssue),
                      onOpenPhoto:
                          (ShowroomReferenceRegion region) =>
                              onOpenPhoto(answer.finishIssue, region),
                      onRemovePhoto:
                          (ShowroomReferenceRegion region) =>
                              onRemovePhoto(answer.finishIssue, region),
                    ),
                  const SizedBox(height: 14),
                  _ChoiceRow(
                    label: '하자',
                    positive: '없어요',
                    negative: '있어요',
                    value: answer.hasDefect == null ? null : !answer.hasDefect!,
                    fontScale: fontScale,
                    enabled: !locked,
                    onChanged: (bool noDefect) {
                      answer.hasDefect = !noDefect;
                      if (noDefect) {
                        onClearIssue('${zone.area}|defect', answer.defect);
                      }
                      onChanged();
                    },
                  ),
                  if (answer.hasDefect == true)
                    _IssueFields(
                      issue: answer.defect,
                      note: defectNote,
                      hint: '어떤 하자인지 적어 주세요',
                      fontScale: fontScale,
                      enabled: !locked,
                      onChanged: (String value) {
                        answer.defect.text = value;
                        onChanged();
                      },
                      onAddPhotos: () => onAddPhotos(answer.defect),
                      onOpenPhoto:
                          (ShowroomReferenceRegion region) =>
                              onOpenPhoto(answer.defect, region),
                      onRemovePhoto:
                          (ShowroomReferenceRegion region) =>
                              onRemovePhoto(answer.defect, region),
                    ),
                  const SizedBox(height: 14),
                  _ChoiceRow(
                    label: '요구사항',
                    positive: '충족해요',
                    negative: '부족해요',
                    value: answer.requirementMet,
                    fontScale: fontScale,
                    enabled: !locked,
                    onChanged: (bool value) {
                      answer.requirementMet = value;
                      if (value) {
                        onClearIssue(
                          '${zone.area}|need',
                          answer.requirementIssue,
                        );
                      }
                      onChanged();
                    },
                  ),
                  if (answer.requirementMet == false)
                    _IssueFields(
                      issue: answer.requirementIssue,
                      note: requirementNote,
                      hint: '어떤 요구가 부족한지 적어 주세요',
                      fontScale: fontScale,
                      enabled: !locked,
                      onChanged: (String value) {
                        answer.requirementIssue.text = value;
                        onChanged();
                      },
                      onAddPhotos: () => onAddPhotos(answer.requirementIssue),
                      onOpenPhoto:
                          (ShowroomReferenceRegion region) =>
                              onOpenPhoto(answer.requirementIssue, region),
                      onRemovePhoto:
                          (ShowroomReferenceRegion region) =>
                              onRemovePhoto(answer.requirementIssue, region),
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

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.positive,
    required this.negative,
    required this.value,
    required this.fontScale,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String positive;
  final String negative;
  final bool? value;
  final double fontScale;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ChoiceChip(
              label: positive,
              selected: value == true,
              fontScale: fontScale,
              onTap: enabled ? () => onChanged(true) : null,
            ),
            const SizedBox(width: 8),
            _ChoiceChip(
              label: negative,
              selected: value == false,
              fontScale: fontScale,
              onTap: enabled ? () => onChanged(false) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InspectResult extends StatelessWidget {
  const _InspectResult({
    required this.zones,
    required this.answerOf,
    required this.allClear,
    required this.companyConfirmed,
    required this.fontScale,
    required this.onReopen,
    required this.onCompanyConfirm,
  });

  final List<_InspectZone> zones;
  final _ZoneAnswer Function(String area) answerOf;
  final bool allClear;
  final bool companyConfirmed;
  final double fontScale;
  final VoidCallback onReopen;
  final VoidCallback onCompanyConfirm;

  @override
  Widget build(BuildContext context) {
    if (!allClear) {
      return DecoratedBox(
        decoration: _card,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '확인할 곳이 있어요',
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '시공에서 보고 다시 점검해요.',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              for (final _InspectZone zone in zones)
                for (final (String kind, String text)
                    in answerOf(zone.area).issues())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${zone.area} $kind',
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 8),
              AppButton(label: '다시 점검', onPressed: onReopen),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyConfirmed ? '양쪽 확인이 끝났어요' : '점검을 마쳤어요',
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              companyConfirmed
                  ? '준공 확인으로 넘어갈 수 있어요.'
                  : '고객 확인은 제출로 끝났어요. 시공 확인을 받으면 준공 확인으로 넘어가요.',
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (!companyConfirmed) ...[
              const SizedBox(height: 12),
              AppButton(label: '시공 확인 받기', onPressed: onCompanyConfirm),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    required this.title,
    required this.note,
    required this.done,
    required this.fontScale,
  });

  final String title;
  final String note;
  final bool done;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? AppColors.accent : AppColors.surface,
                shape: BoxShape.circle,
                border: done ? null : Border.all(color: AppColors.border),
              ),
              child:
                  done
                      ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.white,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15 * fontScale,
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
          ],
        ),
      ),
    );
  }
}

class _IssueFields extends StatelessWidget {
  const _IssueFields({
    required this.issue,
    required this.note,
    required this.hint,
    required this.fontScale,
    required this.enabled,
    required this.onChanged,
    required this.onAddPhotos,
    required this.onOpenPhoto,
    required this.onRemovePhoto,
  });

  final _IssueNote issue;
  final TextEditingController note;
  final String hint;
  final double fontScale;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddPhotos;
  final ValueChanged<ShowroomReferenceRegion> onOpenPhoto;
  final ValueChanged<ShowroomReferenceRegion> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: note,
            enabled: enabled,
            minLines: 2,
            maxLines: 4,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('사진 고르기'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w700,
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
          if (issue.photos.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '사진을 누르면 키워서 표시와 메모를 남길 수 있어요',
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            PrepPhotoStrip(
              regions: issue.photos,
              fontScale: fontScale,
              onTap: onOpenPhoto,
              onDelete: enabled ? onRemovePhoto : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _SettleRound extends StatelessWidget {
  const _SettleRound({
    required this.name,
    required this.when,
    required this.percent,
    required this.amount,
    required this.done,
    required this.current,
    required this.fontScale,
  });

  final String name;
  final String when;
  final int percent;
  final int? amount;
  final bool done;
  final bool current;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final Color nameColor =
        current ? AppColors.textPrimary : AppColors.textSecondary;
    final Color amountColor =
        current ? AppColors.accent : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border:
                  done || current
                      ? current
                          ? Border.all(color: AppColors.accent, width: 1.5)
                          : null
                      : Border.all(color: AppColors.border),
            ),
            child:
                done
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : current
                    ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: (current ? 16 : 15) * fontScale,
                    fontWeight: FontWeight.w700,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  when,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount == null ? '금액 확인 중' : '${formatWon(amount!)}원',
                style: TextStyle(
                  fontSize: (current ? 16 : 14) * fontScale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: current ? -0.3 : 0,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
