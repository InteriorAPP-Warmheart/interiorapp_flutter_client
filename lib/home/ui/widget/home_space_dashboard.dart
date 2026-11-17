import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/space_confirm_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/process_schedule_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/home/domain/home_space_glance.dart';

/// 광고 아래. 확인이 필요한 알림과 오늘·내일 일정을 서로 다른 영역으로 둔다.
class HomeSpaceDashboard extends ConsumerWidget {
  const HomeSpaceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final List<SpaceProject> projects = <SpaceProject>[
      ...board.received,
      ...board.ongoing,
    ];
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final HomeSpaceGlance? glance =
        projects.isEmpty
            ? null
            : homeSpaceGlance(
              projects: projects,
              progressOf: board.constructionFor,
              schedule: ref.watch(processScheduleProvider),
              now: DateTime.now(),
            );
    final List<HomeNotice> notices = <HomeNotice>[
      ..._confirmNotices(board, ref.watch(spaceConfirmProvider)),
      ...?glance?.notices,
    ];
    final HomeBrief? brief = glance?.brief;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notices.isNotEmpty)
          Padding(
            padding: inset,
            child: _AttentionShake(
              token: notices
                  .map((HomeNotice n) => '${n.projectId}:${n.title}')
                  .join('|'),
              child: _AttentionStack(notices: notices, fontScale: fontScale),
            ),
          ),
        if (brief != null) ...[
          if (notices.isNotEmpty)
            SizedBox(height: ResponsiveSize.sectionGap(context)),
          Padding(padding: inset, child: _SectionTitle('일정', fontScale)),
          SizedBox(height: subGap),
          Padding(
            padding: inset,
            child: _BriefCard(brief: brief, fontScale: fontScale),
          ),
        ] else if (notices.isEmpty) ...[
          Padding(padding: inset, child: _SectionTitle('일정', fontScale)),
          SizedBox(height: subGap),
          Padding(padding: inset, child: const _EmptySchedule()),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, this.fontScale);

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return DecoratedBox(
      decoration: _cardDecoration(),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 28 * fontScale,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              '예정된 일정이 없어요',
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<HomeNotice> _confirmNotices(
  SpaceBoard board,
  List<SpaceConfirm> confirms,
) {
  return <HomeNotice>[
    for (final SpaceConfirm confirm in confirms)
      if (board.find(confirm.projectId) != null)
        HomeNotice(
          projectId: confirm.projectId,
          placeName: board.find(confirm.projectId)!.placeName,
          imageUrl: board.find(confirm.projectId)!.imageUrl,
          kind: '확인',
          title: confirm.title,
        ),
  ];
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({required this.brief, required this.fontScale});

  final HomeBrief brief;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool showTomorrow = brief.tomorrow.trade.trim().isNotEmpty;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(SpaceRoutes.detail(brief.projectId)),
        child: Ink(
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 148,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: brief.imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x000B1F38), Color(0xCC0B1F38)],
                          stops: [0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Text(
                        brief.placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20 * fontScale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _MomentTile(
                          moment: brief.today,
                          fontScale: fontScale,
                          outlined: true,
                        ),
                      ),
                      if (showTomorrow) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MomentTile(
                            moment: brief.tomorrow,
                            fontScale: fontScale,
                          ),
                        ),
                      ],
                    ],
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

class _MomentTile extends StatelessWidget {
  const _MomentTile({
    required this.moment,
    required this.fontScale,
    this.outlined = false,
  });

  final HomeMoment moment;
  final double fontScale;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: outlined ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border:
            outlined ? Border.all(color: AppColors.primary, width: 1) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (outlined)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: Text(
                    moment.label,
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            else
              Text(
                moment.label,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              moment.trade,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18 * fontScale,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            if (_momentSub(moment).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _momentSub(moment),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttentionShake extends StatefulWidget {
  const _AttentionShake({required this.token, required this.child});

  final String token;
  final Widget child;

  @override
  State<_AttentionShake> createState() => _AttentionShakeState();
}

class _AttentionShakeState extends State<_AttentionShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dx;
  Timer? _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _dx = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: -6),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -6, end: 6),
        weight: 2,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 6, end: -4),
        weight: 2,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -4, end: 2),
        weight: 2,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 2, end: 0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _shake();
    _pulse = Timer.periodic(const Duration(seconds: 3), (_) => _shake());
  }

  void _shake() {
    if (!mounted) return;
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _AttentionShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) _shake();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dx,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(offset: Offset(_dx.value, 0), child: child);
      },
      child: widget.child,
    );
  }
}

class _AttentionStack extends StatelessWidget {
  const _AttentionStack({required this.notices, required this.fontScale});

  final List<HomeNotice> notices;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            for (var i = 0; i < notices.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 0.6,
                  thickness: 0.6,
                  indent: 12,
                  endIndent: 12,
                  color: Color(0x33B94B45),
                ),
              _AlertLine(notice: notices[i], fontScale: fontScale),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlertLine extends StatelessWidget {
  const _AlertLine({required this.notice, required this.fontScale});

  final HomeNotice notice;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String line = notice.title.isNotEmpty ? notice.title : notice.mark;
    return Material(
      color: AppColors.error.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => context.push(SpaceRoutes.detail(notice.projectId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _KindPill(label: notice.kind, fontScale: fontScale),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: notice.placeName,
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (line.isNotEmpty)
                        TextSpan(
                          text: '  $line',
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18 * fontScale,
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindPill extends StatelessWidget {
  const _KindPill({required this.label, required this.fontScale});

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

String _momentSub(HomeMoment moment) {
  if (moment.more.isEmpty) return moment.caption;
  if (moment.more.length == 1) return moment.more.first;
  return '${moment.more.first} 외 ${moment.more.length - 1}';
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border, width: 0.7),
  );
}
