part of '../project_progress_view.dart';

class _ConsultStage extends StatelessWidget {
  const _ConsultStage({required this.record, required this.fontScale});

  final PrepRecord? record;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final PrepRecord? current = record;
    final String industry =
        current == null ? '확인 중' : _shown(current.industryLine);
    final String area = current == null ? '확인 중' : _shown(current.areaLine);
    final String budget = current == null ? '확인 중' : _briefBudget(current);
    final String period = _consultText(current?.period);
    final String startTiming = _consultText(current?.startTiming);
    final String openTiming = _consultText(current?.openTiming);
    final String address =
        current == null
            ? '확인 중'
            : _shown(
              current.detailAddress.isEmpty
                  ? current.address
                  : '${current.address} ${current.detailAddress}',
            );

    return CustomScrollView(
      physics: const _ScrollOnlyWhenNeeded(),
      slivers: [
        industryCoverBar(industry),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveSize.responsivePadding(context).left,
              4,
              ResponsiveSize.responsivePadding(context).right,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Headline(text: '상담이 접수됐어요', fontScale: fontScale),
                const SizedBox(height: 16),
                _ConsultMini(
                  icon: Icons.square_foot_outlined,
                  label: '면적',
                  value: area,
                  fontScale: fontScale,
                ),
                const SizedBox(height: 8),
                _ConsultBudget(value: budget, fontScale: fontScale),
                const SizedBox(height: 8),
                _IconLine(
                  icon: Icons.place_outlined,
                  label: '현장 주소',
                  value: address,
                  fontScale: fontScale,
                ),
                const SizedBox(height: 14),
                Text('일정', style: _sectionTitle(fontScale)),
                const SizedBox(height: 8),
                _ConsultSchedule(
                  startTiming: startTiming,
                  openTiming: openTiming,
                  period: period,
                  fontScale: fontScale,
                ),
                if (current != null) ...[
                  const SizedBox(height: 8),
                  _SubmittedEntry(record: current, fontScale: fontScale),
                ],
                const SizedBox(height: 28),
                const _ConsultCallout(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsultMini extends StatelessWidget {
  const _ConsultMini({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    style: _kicker(fontScale).copyWith(height: 1.15),
                  ),
                  const SizedBox(height: 2),
                  _FitLine(
                    value,
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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

class _ConsultBudget extends StatelessWidget {
  const _ConsultBudget({required this.value, required this.fontScale});

  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text('예산', style: _kicker(fontScale)),
              const SizedBox(width: 12),
              Expanded(
                child: _FitLine(
                  value,
                  align: Alignment.centerRight,
                  style: TextStyle(
                    fontSize: 20 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultSchedule extends StatelessWidget {
  const _ConsultSchedule({
    required this.startTiming,
    required this.openTiming,
    required this.period,
    required this.fontScale,
  });

  final String startTiming;
  final String openTiming;
  final String period;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            _ScheduleRow(
              icon: Icons.event_available_outlined,
              label: '착공 일정',
              value: startTiming,
              fontScale: fontScale,
            ),
            const Divider(height: 1, color: AppColors.border),
            _ScheduleRow(
              icon: Icons.flag_outlined,
              label: '목표 개업',
              value: openTiming,
              fontScale: fontScale,
            ),
            const Divider(height: 1, color: AppColors.border),
            _ScheduleRow(
              icon: Icons.timelapse_outlined,
              label: '공사 기간',
              value: period,
              fontScale: fontScale,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: _kicker(fontScale).copyWith(height: 1.15)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16 * fontScale,
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

class _ConsultCallout extends StatelessWidget {
  const _ConsultCallout();

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE7EBE4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            const _RingingPhone(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '다음 단계',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전화 상담',
                    style: TextStyle(
                      fontSize: 20 * fontScale,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '접수한 내용을 바탕으로 전화로 상담을 이어가요.',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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

class _RingingPhone extends StatefulWidget {
  const _RingingPhone();

  @override
  State<_RingingPhone> createState() => _RingingPhoneState();
}

class _RingingPhoneState extends State<_RingingPhone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const _PhoneMark(angle: 0, ring: 1);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        final double shake =
            t < 0.45 ? math.sin(t / 0.45 * math.pi * 4) * 0.22 : 0;
        final double ring = t < 0.7 ? t / 0.7 : 1;
        return _PhoneMark(angle: shake, ring: ring);
      },
    );
  }
}

class _PhoneMark extends StatelessWidget {
  const _PhoneMark({required this.angle, required this.ring});

  final double angle;
  final double ring;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: (1 - ring) * 0.4,
            child: Transform.scale(
              scale: 0.7 + ring * 0.55,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                child: SizedBox.square(dimension: 52),
              ),
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 44,
              child: Transform.rotate(
                angle: angle,
                child: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FitLine extends StatelessWidget {
  const _FitLine(
    this.value, {
    required this.style,
    this.align = Alignment.centerLeft,
  });

  final String value;
  final TextStyle style;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: align,
      child: Text(value, softWrap: false, style: style),
    );
  }
}

class _SubmittedEntry extends StatelessWidget {
  const _SubmittedEntry({required this.record, required this.fontScale});

  final PrepRecord record;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder:
                  (BuildContext context) =>
                      SubmittedConsultScreen(record: record),
            ),
          );
        },
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
                        '접수한 내용',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
