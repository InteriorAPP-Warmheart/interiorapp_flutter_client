part of '../project_progress_view.dart';

class _VisitStage extends StatelessWidget {
  const _VisitStage({required this.visit, required this.fontScale});

  final VisitAppointment? visit;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final VisitAppointment? appointment = visit;
    final DateTime? day = appointment?.when;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool roomy = constraints.maxHeight >= 560;
        final double gap = roomy ? 10 : 6;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Headline(text: '현장을 보러 갑니다', fontScale: fontScale),
            SizedBox(height: gap),
            SizedBox(
              height: roomy ? 116 : 96,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: _VisitCalendar(day: day, fontScale: fontScale),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: _VisitSideTile(
                            label: '시간',
                            value: day == null ? '—' : _koreanTime(day),
                            fontScale: fontScale,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _VisitSideTile(
                            label: '남은 날',
                            value: day == null ? '—' : _dDayLabel(day),
                            fontScale: fontScale,
                            emphasize: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gap),
            if (appointment == null)
              Text(
                '전화 상담에서 날짜, 시간, 위치와 방문하는 분을 정해요.',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              )
            else ...[
              _VisitInfo(
                icon: Icons.place_outlined,
                label: '방문 위치',
                value: appointment.place,
                fontScale: fontScale,
              ),
              SizedBox(height: gap),
              _VisitProfile(
                name: appointment.visitorName,
                role: appointment.visitorRole,
                fontScale: fontScale,
                avatar: roomy ? 80 : 68,
              ),
            ],
            SizedBox(height: roomy ? 14 : 8),
            Text('현장에선 다음과 같은 내용들을 확인하고 상담해요', style: _sectionTitle(fontScale)),
            const SizedBox(height: 6),
            const Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: _VisitChecks(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VisitCalendar extends StatelessWidget {
  const _VisitCalendar({required this.day, required this.fontScale});

  final DateTime? day;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final DateTime? date = day;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: Center(
                  child: Text(
                    date == null ? '방문' : '${date.year}년',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date == null ? '—' : '${date.month}월',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? '' : '${date.day}',
                    style: TextStyle(
                      fontSize: 40 * fontScale,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: AppColors.primary,
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

class _VisitSideTile extends StatelessWidget {
  const _VisitSideTile({
    required this.label,
    required this.value,
    required this.fontScale,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final double fontScale;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _kicker(fontScale).copyWith(height: 1.1)),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: (emphasize ? 26 : 18) * fontScale,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      letterSpacing: emphasize ? -0.6 : 0,
                      color:
                          emphasize ? AppColors.primary : AppColors.textPrimary,
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

class _VisitInfo extends StatelessWidget {
  const _VisitInfo({
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
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: _kicker(fontScale).copyWith(height: 1.1)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
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

class _VisitProfile extends StatelessWidget {
  const _VisitProfile({
    required this.name,
    required this.role,
    required this.fontScale,
    required this.avatar,
  });

  final String name;
  final String role;
  final double fontScale;
  final double avatar;

  @override
  Widget build(BuildContext context) {
    final String mark =
        name.runes.isEmpty ? '방' : String.fromCharCode(name.runes.first);
    return DecoratedBox(
      decoration: _card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: avatar,
                height: avatar,
                child: Center(
                  child: Text(
                    mark,
                    style: TextStyle(
                      fontSize: avatar * 0.38,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '방문하는 분',
                    style: _kicker(fontScale).copyWith(height: 1.15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24 * fontScale,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      height: 1.2,
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
    );
  }
}

class _VisitChecks extends StatelessWidget {
  const _VisitChecks();

  static const List<(IconData, String, String)> _items = [
    (Icons.straighten, '현장 실측', '벽, 바닥, 천장 치수를 재요.'),
    (Icons.bolt_outlined, '전기증설여부', '지금 용량으로 충분한지 확인해요.'),
    (Icons.water_drop_outlined, '급배수', '업종에 따라서 필요하다면,물이 들어오고 빠지는 위치를 봐요.'),
    (Icons.layers_clear_outlined, '철거여부', '철거할 곳과 남길 곳을 확인해요.'),
  ];

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxHeight = constraints.maxHeight;
        final bool squeeze =
            maxHeight.isFinite && maxHeight < _items.length * 76;
        return DecoratedBox(
          decoration: _card,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: squeeze ? MainAxisSize.max : MainAxisSize.min,
              children: [
                for (var i = 0; i < _items.length; i++)
                  squeeze
                      ? Expanded(
                        child: _VisitCheckRow(
                          icon: _items[i].$1,
                          title: _items[i].$2,
                          note: _items[i].$3,
                          fontScale: fontScale,
                          divider: i > 0,
                          flex: true,
                        ),
                      )
                      : _VisitCheckRow(
                        icon: _items[i].$1,
                        title: _items[i].$2,
                        note: _items[i].$3,
                        fontScale: fontScale,
                        divider: i > 0,
                        flex: false,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VisitCheckRow extends StatelessWidget {
  const _VisitCheckRow({
    required this.icon,
    required this.title,
    required this.note,
    required this.fontScale,
    required this.divider,
    required this.flex,
  });

  final IconData icon;
  final String title;
  final String note;
  final double fontScale;
  final bool divider;
  final bool flex;

  @override
  Widget build(BuildContext context) {
    final Widget copy =
        flex
            ? _VisitCheckCopy(title: title, note: note, fontScale: fontScale)
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
    final Widget body = Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: copy),
      ],
    );
    if (!flex) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (divider) const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: body,
          ),
        ],
      );
    }
    return Column(
      children: [
        if (divider) const Divider(height: 1, color: AppColors.border),
        Expanded(child: body),
      ],
    );
  }
}

class _VisitCheckCopy extends StatelessWidget {
  const _VisitCheckCopy({
    required this.title,
    required this.note,
    required this.fontScale,
  });

  final String title;
  final String note;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _koreanTime(DateTime day) {
  final String minute = day.minute.toString().padLeft(2, '0');
  if (day.hour < 12) {
    final int hour = day.hour == 0 ? 12 : day.hour;
    return '오전 $hour:$minute';
  }
  final int hour = day.hour == 12 ? 12 : day.hour - 12;
  return '오후 $hour:$minute';
}

String _dDayLabel(DateTime day) {
  final DateTime today = DateTime.now();
  final int days =
      DateTime(
        day.year,
        day.month,
        day.day,
      ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (days == 0) return '오늘';
  if (days > 0) return 'D-$days일';
  return 'D+${-days}일';
}
