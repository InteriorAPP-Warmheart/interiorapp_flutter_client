part of '../project_progress_view.dart';

/// 판매하는 A/S 상품. 준공일부터 1년.
final DateTime _careStart = DateTime(2026, 10, 24);
final DateTime _careEnd = DateTime(2027, 10, 24);

void openCareScreen(
  BuildContext context, {
  required List<PublicSitePhoto> photos,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => _CareScreen(photos: photos),
    ),
  );
}

class _CareScreen extends StatefulWidget {
  const _CareScreen({required this.photos});

  final List<PublicSitePhoto> photos;

  @override
  State<_CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<_CareScreen> {
  final GlobalKey<_CareStageState> _key = GlobalKey<_CareStageState>();

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('A/S')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'care-request',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        onPressed: () => _key.currentState?.openRequest(),
        label: Text(
          'A/S 문의',
          style: TextStyle(
            fontSize: 15 * fontScale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          12,
          padding.right,
          96 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _CareStage(key: _key, fontScale: fontScale, photos: widget.photos),
        ],
      ),
    );
  }
}

class _CareStage extends StatefulWidget {
  const _CareStage({super.key, required this.fontScale, required this.photos});

  final double fontScale;
  final List<PublicSitePhoto> photos;

  @override
  State<_CareStage> createState() => _CareStageState();
}

class _CareStageState extends State<_CareStage> {
  final List<_CareCase> _cases = _sampleCareCases();

  Future<void> openRequest() async {
    final bool active =
        _careEnd.difference(_careDay(DateTime.now())).inDays > 0;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext sheetContext) => _CareRequestSheet(
            photos: widget.photos,
            fontScale: widget.fontScale,
            enabled: active,
            onSubmit: (_CareDraft draft) {
              setState(() {
                _cases.insert(
                  0,
                  _CareCase(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    text: draft.text,
                    photos: draft.photos,
                    availableStart: draft.availableStart,
                    availableEnd: draft.availableEnd,
                    visitMinute: draft.visitMinute,
                    parking: draft.parking,
                    entry: draft.entry,
                    logs: <_CareLog>[
                      _CareLog(step: _CareStep.received, at: DateTime.now()),
                    ],
                  ),
                );
              });
            },
          ),
    );
  }

  void _advance(_CareCase item) {
    final int next = item.step.index + 1;
    if (next >= _CareStep.values.length) return;
    final _CareStep step = _CareStep.values[next];
    setState(() {
      item.logs.add(_CareLog(step: step, at: DateTime.now()));
      if (step.index >= _CareStep.checked.index) {
        item.visitor ??= _careVisitors.first;
        item.visitDay ??= item.availableStart;
      }
    });
  }

  void _openCase(_CareCase item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext sheetContext) => _CareCaseSheet(
            item: item,
            fontScale: widget.fontScale,
            onAdvance: () => _advance(item),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = widget.fontScale;
    final DateTime today = _careDay(DateTime.now());
    final int totalDays = _careEnd.difference(_careStart).inDays;
    final int usedDays = today
        .difference(_careStart)
        .inDays
        .clamp(0, totalDays);
    final int leftDays = _careEnd.difference(today).inDays;
    final bool active = leftDays > 0;
    final double used = totalDays == 0 ? 1 : usedDays / totalDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          active ? '보증이 남아 있어요' : '보증이 끝났어요',
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
          '구매한 1년 A/S예요. 준공일부터 1년 동안 유지돼요.',
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? '남은 기간' : '종료',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  active ? '$leftDays일' : _careDate(_careEnd),
                  style: TextStyle(
                    fontSize: 32 * fontScale,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: AppColors.background),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: used.clamp(0, 1),
                          child: const ColoredBox(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _careDate(_careStart),
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _careDate(_careEnd),
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _CareLine(label: '상품', value: '1년 A/S', fontScale: fontScale),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _CareLine(
                  label: '시작',
                  value: _careDate(_careStart),
                  fontScale: fontScale,
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _CareLine(
                  label: '종료',
                  value: _careDate(_careEnd),
                  fontScale: fontScale,
                ),
              ],
            ),
          ),
        ),
        if (_cases.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('남긴 기록', style: _recordLabel(fontScale)),
          const SizedBox(height: 4),
          Text(
            '최신 기록부터 보여요. 누르면 그 내용을 볼 수 있어요.',
            style: TextStyle(
              fontSize: 13 * fontScale,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: _card,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < _cases.length; i++)
                    _CareSummaryRow(
                      item: _cases[i],
                      last: i == _cases.length - 1,
                      fontScale: fontScale,
                      onTap: () => _openCase(_cases[i]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

DateTime _careDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _careDate(DateTime value) =>
    '${value.year}년 ${value.month}월 ${value.day}일';

class _CareLine extends StatelessWidget {
  const _CareLine({
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14 * fontScale,
                height: 1.35,
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

class _CareHeading extends StatelessWidget {
  const _CareHeading({required this.title, required this.fontScale});

  final String title;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13 * fontScale,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CareFact extends StatelessWidget {
  const _CareFact({
    required this.label,
    required this.value,
    required this.fontScale,
    this.last = false,
  });

  final String label;
  final String value;
  final double fontScale;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16 * fontScale,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareNote extends StatelessWidget {
  const _CareNote({
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CareStep { received, checked, underway, done }

class _CareLog {
  const _CareLog({required this.step, required this.at});

  final _CareStep step;
  final DateTime at;
}

class _CareDraft {
  const _CareDraft({
    required this.text,
    required this.photos,
    required this.availableStart,
    required this.availableEnd,
    required this.visitMinute,
    required this.parking,
    required this.entry,
  });

  final String text;
  final List<ShowroomReferenceRegion> photos;
  final DateTime availableStart;
  final DateTime availableEnd;
  final int visitMinute;
  final String parking;
  final String entry;
}

class _CareCase {
  _CareCase({
    required this.id,
    required this.text,
    required this.photos,
    required this.logs,
    required this.availableStart,
    required this.availableEnd,
    required this.visitMinute,
    this.parking = '',
    this.entry = '',
    this.visitDay,
    this.visitor,
  });

  final String id;
  final String text;
  final List<ShowroomReferenceRegion> photos;
  final List<_CareLog> logs;
  final DateTime availableStart;
  final DateTime availableEnd;
  final int visitMinute;
  final String parking;
  final String entry;
  DateTime? visitDay;
  SiteWorker? visitor;

  _CareStep get step => logs.last.step;

  bool get finished => step == _CareStep.done;

  _CareLog? logOf(_CareStep step) {
    for (final _CareLog log in logs) {
      if (log.step == step) return log;
    }
    return null;
  }
}

String _careStepLabel(_CareStep step) {
  return switch (step) {
    _CareStep.received => '접수',
    _CareStep.checked => '접수확인',
    _CareStep.underway => 'A/S 진행중',
    _CareStep.done => 'A/S 완료',
  };
}

String _careStepNote(_CareStep step) {
  return switch (step) {
    _CareStep.received => '증상을 접수했어요',
    _CareStep.checked => '담당자가 접수를 확인했어요',
    _CareStep.underway => 'A/S를 진행하고 있어요',
    _CareStep.done => 'A/S를 마쳤어요',
  };
}

String _careClock(DateTime value) {
  final String hour = value.hour.toString().padLeft(2, '0');
  final String minute = value.minute.toString().padLeft(2, '0');
  return '${value.month}월 ${value.day}일 $hour:$minute';
}

String _careDayText(DateTime value) => '${value.month}월 ${value.day}일';

String _careMinuteText(int minute) {
  final int hour = minute ~/ 60;
  final int rest = minute % 60;
  return '${hour.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}';
}

String _carePeriodText(DateTime start, DateTime end) {
  if (appCalendarSameDay(start, end)) return _careDayText(start);
  return '${_careDayText(start)}부터 ${_careDayText(end)}';
}

class _CareSummaryRow extends StatelessWidget {
  const _CareSummaryRow({
    required this.item,
    required this.last,
    required this.fontScale,
    required this.onTap,
  });

  final _CareCase item;
  final bool last;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool done = item.finished;
    final String when =
        item.visitDay == null
            ? '${_carePeriodText(item.availableStart, item.availableEnd)} ${_careMinuteText(item.visitMinute)}'
            : '${_careDayText(item.visitDay!)} ${_careMinuteText(item.visitMinute)} 방문';
    return Stack(
      children: [
        if (!last)
          Positioned(
            left: 7,
            top: 22,
            bottom: 0,
            child: Container(width: 2, color: AppColors.border),
          ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? AppColors.primary : AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child:
                      done
                          ? const Icon(
                            Icons.check,
                            size: 10,
                            color: AppColors.white,
                          )
                          : Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: last ? 0 : 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CareStatusChip(
                            step: item.step,
                            fontScale: fontScale,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        when,
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CareStatusChip extends StatelessWidget {
  const _CareStatusChip({required this.step, required this.fontScale});

  final _CareStep step;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool done = step == _CareStep.done;
    final Color tone = done ? AppColors.textSecondary : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _careStepLabel(step),
        style: TextStyle(
          fontSize: 12 * fontScale,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}

class _CareCaseSheet extends StatefulWidget {
  const _CareCaseSheet({
    required this.item,
    required this.fontScale,
    required this.onAdvance,
  });

  final _CareCase item;
  final double fontScale;
  final VoidCallback onAdvance;

  @override
  State<_CareCaseSheet> createState() => _CareCaseSheetState();
}

class _CareCaseSheetState extends State<_CareCaseSheet> {
  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    final double height = MediaQuery.sizeOf(context).height * 0.86;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    _CareCaseCard(
                      item: widget.item,
                      fontScale: widget.fontScale,
                      onAdvance: () {
                        widget.onAdvance();
                        setState(() {});
                      },
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

class _CareCaseCard extends StatelessWidget {
  const _CareCaseCard({
    required this.item,
    required this.fontScale,
    required this.onAdvance,
  });

  final _CareCase item;
  final double fontScale;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _CareStatusChip(step: item.step, fontScale: fontScale),
            ),
            const SizedBox(height: 10),
            Text(
              item.text,
              style: TextStyle(
                fontSize: 18 * fontScale,
                height: 1.45,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            if (item.photos.isNotEmpty) ...[
              const SizedBox(height: 14),
              PrepPhotoStrip(regions: item.photos, fontScale: fontScale),
            ],
            const SizedBox(height: 22),
            _CareHeading(title: '방문 일정', fontScale: fontScale),
            const SizedBox(height: 10),
            _CareFact(
              label: '가능 기간',
              value: _carePeriodText(item.availableStart, item.availableEnd),
              fontScale: fontScale,
            ),
            _CareFact(
              label: '희망 시간',
              value: _careMinuteText(item.visitMinute),
              fontScale: fontScale,
              last: item.visitDay == null,
            ),
            if (item.visitDay != null)
              _CareFact(
                label: '방문',
                value:
                    '${_careDayText(item.visitDay!)} ${_careMinuteText(item.visitMinute)}',
                fontScale: fontScale,
                last: true,
              ),
            if (item.parking.trim().isNotEmpty ||
                item.entry.trim().isNotEmpty) ...[
              const SizedBox(height: 22),
              _CareHeading(title: '찾아오는 길', fontScale: fontScale),
              const SizedBox(height: 10),
              if (item.parking.trim().isNotEmpty)
                _CareNote(
                  label: '주차',
                  value: item.parking.trim(),
                  fontScale: fontScale,
                ),
              if (item.parking.trim().isNotEmpty &&
                  item.entry.trim().isNotEmpty)
                const SizedBox(height: 8),
              if (item.entry.trim().isNotEmpty)
                _CareNote(
                  label: '문 여는 법',
                  value: item.entry.trim(),
                  fontScale: fontScale,
                ),
            ],
            if (item.step.index >= _CareStep.checked.index &&
                item.visitor != null) ...[
              const SizedBox(height: 22),
              _CareHeading(title: '방문 인력', fontScale: fontScale),
              const SizedBox(height: 10),
              _WorkerCard(
                worker: item.visitor!,
                fontScale: fontScale,
                showPhone: true,
              ),
            ],
            const SizedBox(height: 22),
            _CareHeading(title: '진행', fontScale: fontScale),
            const SizedBox(height: 12),
            for (var i = 0; i < _CareStep.values.length; i++)
              _CareTimelineRow(
                step: _CareStep.values[i],
                log: item.logOf(_CareStep.values[i]),
                current: !item.finished && item.step == _CareStep.values[i],
                linked: i < item.step.index,
                last: i == _CareStep.values.length - 1,
                fontScale: fontScale,
              ),
            if (!item.finished) ...[
              const SizedBox(height: 16),
              AppButton(label: '다음 단계', onPressed: onAdvance),
            ],
          ],
        ),
      ),
    );
  }
}

class _CareTimelineRow extends StatelessWidget {
  const _CareTimelineRow({
    required this.step,
    required this.log,
    required this.current,
    required this.linked,
    required this.last,
    required this.fontScale,
  });

  final _CareStep step;
  final _CareLog? log;
  final bool current;
  final bool linked;
  final bool last;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool reached = log != null;
    final bool done = reached && !current;
    final Color labelColor =
        reached ? AppColors.textPrimary : AppColors.textSecondary;
    final DateTime? at = log?.at;
    return Stack(
      children: [
        if (!last)
          Positioned(
            left: 8,
            top: 18,
            bottom: 0,
            child: Container(
              width: 2,
              color: linked ? AppColors.primary : AppColors.border,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    current
                        ? AppColors.accent
                        : done
                        ? AppColors.primary
                        : AppColors.surface,
                shape: BoxShape.circle,
                border:
                    reached
                        ? null
                        : Border.all(color: AppColors.border, width: 1.5),
              ),
              child:
                  done
                      ? const Icon(
                        Icons.check,
                        size: 10,
                        color: AppColors.white,
                      )
                      : current
                      ? Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _careStepLabel(step),
                            style: TextStyle(
                              fontSize: (current ? 15 : 14) * fontScale,
                              fontWeight: FontWeight.w700,
                              color: labelColor,
                            ),
                          ),
                        ),
                        if (at != null)
                          Text(
                            _careClock(at),
                            style: TextStyle(
                              fontSize: 12 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (reached) ...[
                      const SizedBox(height: 2),
                      Text(
                        _careStepNote(step),
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const SiteWorker _careVisitorFinish = SiteWorker(
  name: '정시우',
  role: 'A/S',
  work: '마감 보수',
  organization: '바론 인테리어',
  career: '8년',
  bio: '준공 이후 마감 하자를 현장에서 살펴 고칩니다',
  phone: '010-4812-9033',
  imageUrl:
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&crop=faces&w=800&h=1000&q=80',
);

const SiteWorker _careVisitorFixture = SiteWorker(
  name: '배수아',
  role: 'A/S',
  work: '설비 점검',
  organization: '바론 인테리어',
  career: '6년',
  bio: '물이 새거나 배수가 막힌 곳을 먼저 확인합니다',
  phone: '010-7390-2216',
  imageUrl:
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&crop=faces&w=800&h=1000&q=80',
);

final List<SiteWorker> _careVisitors = <SiteWorker>[
  _careVisitorFinish,
  _careVisitorFixture,
];

ShowroomReferenceRegion _careShot(String id, String url) {
  return ShowroomReferenceRegion(id: id, label: 'A/S', imageUrl: url);
}

_CareLog _carePast(_CareStep step, int year, int month, int day, int hour) {
  return _CareLog(step: step, at: DateTime(year, month, day, hour, 20));
}

List<_CareCase> _sampleCareCases() {
  return <_CareCase>[
    _CareCase(
      id: 'care-light',
      text: '홀 조명이 가끔 꺼져요. 저녁에 더 자주 그래요.',
      photos: <ShowroomReferenceRegion>[
        _careShot(
          'care-light',
          'https://picsum.photos/seed/care-light/900/900',
        ),
      ],
      visitor: _careVisitorFinish,
      availableStart: DateTime(2026, 11, 4),
      availableEnd: DateTime(2026, 11, 6),
      visitMinute: 10 * 60 + 30,
      visitDay: DateTime(2026, 11, 4),
      parking: '건물 뒤 골목에 한 대 세울 수 있어요',
      entry: '영업 중이면 홀로 들어오면 돼요',
      logs: <_CareLog>[
        _carePast(_CareStep.received, 2026, 11, 1, 10),
        _carePast(_CareStep.checked, 2026, 11, 1, 16),
        _carePast(_CareStep.underway, 2026, 11, 3, 9),
      ],
    ),
    _CareCase(
      id: 'care-sink',
      text: '주방 싱크 배수가 느려요. 물을 받으면 한참 뒤에 빠져요.',
      photos: <ShowroomReferenceRegion>[
        _careShot('care-sink', 'https://picsum.photos/seed/care-sink/900/900'),
      ],
      visitor: _careVisitorFixture,
      availableStart: DateTime(2026, 9, 5),
      availableEnd: DateTime(2026, 9, 6),
      visitMinute: 13 * 60,
      visitDay: DateTime(2026, 9, 6),
      entry: '주방 안쪽 작업대 옆으로 와 주세요',
      logs: <_CareLog>[
        _carePast(_CareStep.received, 2026, 9, 4, 11),
        _carePast(_CareStep.checked, 2026, 9, 4, 15),
        _carePast(_CareStep.underway, 2026, 9, 6, 10),
        _carePast(_CareStep.done, 2026, 9, 6, 16),
      ],
    ),
    _CareCase(
      id: 'care-door',
      text: '카운터 문짝이 잘 안 닫혀요. 아래로 살짝 처졌어요.',
      photos: <ShowroomReferenceRegion>[
        _careShot('care-door', 'https://picsum.photos/seed/care-door/900/900'),
        _careShot(
          'care-door-hinge',
          'https://picsum.photos/seed/care-door-hinge/900/900',
        ),
      ],
      visitor: _careVisitorFinish,
      availableStart: DateTime(2026, 8, 13),
      availableEnd: DateTime(2026, 8, 14),
      visitMinute: 11 * 60,
      visitDay: DateTime(2026, 8, 14),
      parking: '매장 앞에 한 대 댈 수 있어요',
      entry: '옆문으로 들어와 주세요',
      logs: <_CareLog>[
        _carePast(_CareStep.received, 2026, 8, 12, 14),
        _carePast(_CareStep.checked, 2026, 8, 13, 9),
        _carePast(_CareStep.underway, 2026, 8, 14, 11),
        _carePast(_CareStep.done, 2026, 8, 14, 15),
      ],
    ),
  ];
}

class _CareRequestSheet extends StatefulWidget {
  const _CareRequestSheet({
    required this.photos,
    required this.fontScale,
    required this.enabled,
    required this.onSubmit,
  });

  final List<PublicSitePhoto> photos;
  final double fontScale;
  final bool enabled;
  final ValueChanged<_CareDraft> onSubmit;

  @override
  State<_CareRequestSheet> createState() => _CareRequestSheetState();
}

class _CareRequestSheetState extends State<_CareRequestSheet> {
  final _IssueNote _request = _IssueNote();
  late final TextEditingController _note = TextEditingController();
  late final TextEditingController _parking = TextEditingController();
  late final TextEditingController _entry = TextEditingController();
  DateTimeRange? _range;
  int? _visitMinute;

  bool get _ready =>
      _request.explained && _range != null && _visitMinute != null;

  @override
  void dispose() {
    _note.dispose();
    _parking.dispose();
    _entry.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final DateTime today = appCalendarDate(DateTime.now());
    final DateTimeRange? picked = await showAppDateRangeDialog(
      context: context,
      initialRange: _range,
      firstDate: today,
      lastDate: DateTime(today.year, today.month + 3, today.day),
      title: '방문 가능 기간',
    );
    if (!mounted || picked == null) return;
    setState(() => _range = picked);
  }

  Future<void> _pickTime() async {
    const int slotCount = 48;
    final int initial = ((_visitMinute ?? 10 * 60) ~/ 30).clamp(
      0,
      slotCount - 1,
    );
    final FixedExtentScrollController wheel = FixedExtentScrollController(
      initialItem: initial,
    );
    var selected = initial;
    final int? picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final double fontScale = widget.fontScale;
        return SafeArea(
          child: SizedBox(
            height: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Text(
                    '희망 시간',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: wheel,
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) => selected = index,
                    children: [
                      for (var slot = 0; slot < slotCount; slot++)
                        Center(
                          child: Text(
                            _careMinuteText(slot * 30),
                            style: TextStyle(
                              fontSize: 20 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: AppButton(
                    label: '이 시간으로',
                    onPressed: () => Navigator.of(context).pop(selected * 30),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(wheel.dispose);
    if (!mounted || picked == null) return;
    setState(() => _visitMinute = picked);
  }

  Future<void> _addPhotos() async {
    final List<String> urls = await pickWriteImages(
      context,
      photos: widget.photos,
      used:
          (String url) => _request.photos.any(
            (ShowroomReferenceRegion region) => region.imageUrl == url,
          ),
    );
    if (!mounted || urls.isEmpty) return;
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      var added = 0;
      for (final String url in urls) {
        final bool exists = _request.photos.any(
          (ShowroomReferenceRegion region) => region.imageUrl == url,
        );
        if (exists) continue;
        _request.photos.add(
          ShowroomReferenceRegion(
            id: 'care-$stamp-$added',
            label: 'A/S',
            imageUrl: url,
          ),
        );
        added++;
      }
    });
  }

  Future<void> _markPhoto(ShowroomReferenceRegion region) async {
    final ShowroomReferenceRegion? saved = await showShowroomReferenceEditor(
      context,
      region,
      title: '사진 표시',
      saveLabel: '이 표시를 남기기',
      noteHint: '자세한 설명을 적어 주세요',
    );
    if (!mounted || saved == null) return;
    setState(() {
      final int index = _request.photos.indexWhere(
        (ShowroomReferenceRegion item) => item.id == region.id,
      );
      if (index >= 0) _request.photos[index] = saved;
    });
  }

  void _submit() {
    final DateTimeRange? range = _range;
    final int? minute = _visitMinute;
    if (!_ready || range == null || minute == null) return;
    widget.onSubmit(
      _CareDraft(
        text: _request.text.trim(),
        photos: List<ShowroomReferenceRegion>.of(_request.photos),
        availableStart: appCalendarDate(range.start),
        availableEnd: appCalendarDate(range.end),
        visitMinute: minute,
        parking: _parking.text.trim(),
        entry: _entry.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    final double height = (MediaQuery.sizeOf(context).height - inset) * 0.86;
    final double fontScale = widget.fontScale;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A/S 남기기',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.enabled
                        ? '증상과 위치를 적고, 사진을 붙여 주세요.'
                        : '보증이 끝나서 새 A/S는 받을 수 없어요.',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _IssueFields(
                            issue: _request,
                            note: _note,
                            hint: '어디에 어떤 증상이 있는지 적어 주세요',
                            fontScale: fontScale,
                            enabled: widget.enabled,
                            onChanged: (String value) {
                              setState(() => _request.text = value);
                            },
                            onAddPhotos: _addPhotos,
                            onOpenPhoto: _markPhoto,
                            onRemovePhoto: (ShowroomReferenceRegion region) {
                              setState(
                                () => _request.photos.removeWhere(
                                  (ShowroomReferenceRegion item) =>
                                      item.id == region.id,
                                ),
                              );
                            },
                          ),
                          if (widget.enabled) ...[
                            const SizedBox(height: 16),
                            _CarePickRow(
                              label: '가능 기간',
                              value:
                                  _range == null
                                      ? '기간을 골라 주세요'
                                      : _carePeriodText(
                                        _range!.start,
                                        _range!.end,
                                      ),
                              chosen: _range != null,
                              fontScale: fontScale,
                              onTap: _pickRange,
                            ),
                            const SizedBox(height: 8),
                            _CarePickRow(
                              label: '희망 시간',
                              value:
                                  _visitMinute == null
                                      ? '시간을 골라 주세요'
                                      : _careMinuteText(_visitMinute!),
                              chosen: _visitMinute != null,
                              fontScale: fontScale,
                              onTap: _pickTime,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '주차와 문 여는 법은 선택이에요. 적어 두면 기사가 더 쉽게 찾아요.',
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _CareOptionalField(
                              label: '주차',
                              controller: _parking,
                              hint: '어디에 세우면 되는지',
                              fontScale: fontScale,
                            ),
                            const SizedBox(height: 12),
                            _CareOptionalField(
                              label: '문 여는 법',
                              controller: _entry,
                              hint: '가게 문을 어떻게 여는지',
                              fontScale: fontScale,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (widget.enabled) ...[
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'A/S 남기기',
                      onPressed: _ready ? _submit : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarePickRow extends StatelessWidget {
  const _CarePickRow({
    required this.label,
    required this.value,
    required this.chosen,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool chosen;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color:
                      chosen ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareOptionalField extends StatelessWidget {
  const _CareOptionalField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.fontScale,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final double fontScale;

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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          style: TextStyle(
            fontSize: 15 * fontScale,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15 * fontScale,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
      ],
    );
  }
}
