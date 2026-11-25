import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/finished_space_tile.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/ongoing_space_pager.dart';
import 'package:interiorapp_flutter_client/core/widget/consult_button.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/theme/tab_bar_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 내공간 탭. 공간이 있으면 그 공간을 이미지 히어로로 보여 주고,
/// 아무것도 없으면 상담으로 들어오는 시작 화면을 보여 준다. 세로 스크롤은 없다.
class BuildScreen extends ConsumerWidget {
  const BuildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);

    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final List<SpaceProject> ongoing = [...board.received, ...board.ongoing];
    final List<SpaceProject> finished = board.finished;
    final bool hasOngoing = ongoing.isNotEmpty;
    final bool hasFinished = finished.isNotEmpty;
    final bool hasPrep = board.consults.isNotEmpty || board.trades.isNotEmpty;

    final bool inTab = GoRouterState.of(context).uri.path == '/';
    final double tabBarHeight =
        AppTabBarTheme.height(context) +
        AppTabBarTheme.floatGap +
        AppTabBarTheme.bottomInset(context);
    final double reported = MediaQuery.paddingOf(context).bottom;
    final double bottomGap =
        inTab
            ? (reported > tabBarHeight ? reported : tabBarHeight) + subGap + 8
            : subGap + reported;

    void openConsult() => context.push(SpaceRoutes.prepCreate);
    void openPrep() => context.push(SpaceRoutes.prep);
    void openDetail(SpaceProject project) =>
        context.push(SpaceRoutes.detail(project.id));

    final Widget content =
        (!hasOngoing && !hasFinished)
            ? _StartHero(
              hasPrep: hasPrep,
              onConsult: openConsult,
              onPrep: openPrep,
            )
            : _SpaceDashboard(
              label: hasOngoing ? '진행 중인 공간' : '마친 공간',
              hero: OngoingSpacePager(
                projects: hasOngoing ? ongoing : finished,
                progressOf: hasOngoing ? board.constructionFor : null,
                onTap: openDetail,
              ),
              // 진행 중과 마친 공간이 둘 다 있을 때만 아래 줄에 마친 공간을 둔다.
              finishedStrip: hasOngoing && hasFinished ? finished : null,
              onFinishedTap: openDetail,
              prepCaption: _prepCaption(board),
              onConsult: openConsult,
              onPrep: openPrep,
              subGap: subGap,
              sectionGap: sectionGap,
            );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          subGap,
          padding.right,
          bottomGap,
        ),
        child: content,
      ),
    );
  }

  static String _prepCaption(SpaceBoard board) {
    final List<String> parts = <String>[
      if (board.consults.isNotEmpty) '상담 준비 ${board.consults.length}',
      if (board.trades.isNotEmpty) '입지 ${board.trades.length}',
    ];
    if (parts.isEmpty) return '상담 준비 · 입지 선정';
    return parts.join('  ·  ');
  }
}

/// 공간이 하나라도 있을 때. 제목 + 이미지 히어로 + 마친 공간 줄 + 새 공간 준비 바.
class _SpaceDashboard extends StatelessWidget {
  const _SpaceDashboard({
    required this.label,
    required this.hero,
    required this.finishedStrip,
    required this.onFinishedTap,
    required this.prepCaption,
    required this.onConsult,
    required this.onPrep,
    required this.subGap,
    required this.sectionGap,
  });

  final String label;
  final Widget hero;
  final List<SpaceProject>? finishedStrip;
  final ValueChanged<SpaceProject> onFinishedTap;
  final String prepCaption;
  final VoidCallback onConsult;
  final VoidCallback onPrep;
  final double subGap;
  final double sectionGap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<SpaceProject>? strip = finishedStrip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22 * fontScale,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: subGap),
        Expanded(child: hero),
        if (strip != null && strip.isNotEmpty) ...[
          SizedBox(height: sectionGap * 0.8),
          _FinishedStrip(
            projects: strip,
            onTap: onFinishedTap,
            fontScale: fontScale,
            subGap: subGap,
          ),
        ],
        SizedBox(height: subGap + 2),
        _NewSpaceBar(
          caption: prepCaption,
          fontScale: fontScale,
          onOpen: onPrep,
          onConsult: onConsult,
        ),
      ],
    );
  }
}

/// 진행 중 히어로 아래에 두는 마친 공간 가로 줄.
class _FinishedStrip extends StatelessWidget {
  const _FinishedStrip({
    required this.projects,
    required this.onTap,
    required this.fontScale,
    required this.subGap,
  });

  final List<SpaceProject> projects;
  final ValueChanged<SpaceProject> onTap;
  final double fontScale;
  final double subGap;

  @override
  Widget build(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    final double stripHeight =
        window.isExpanded
            ? 136
            : window.isMedium
            ? 120
            : 104;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '마친 공간',
          style: TextStyle(
            fontSize: 15 * fontScale,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: subGap * 0.7),
        SizedBox(
          height: stripHeight,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double gap = 10;
              final int count = projects.length;
              final double width =
                  count <= 2
                      ? (constraints.maxWidth - gap * (count - 1)) / count
                      : (constraints.maxWidth - gap) / 2.2;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics:
                    count <= 2
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                itemCount: count,
                separatorBuilder:
                    (BuildContext context, int index) =>
                        const SizedBox(width: gap),
                itemBuilder: (BuildContext context, int index) {
                  final SpaceProject project = projects[index];
                  return SizedBox(
                    width: width,
                    child: FinishedSpaceTile(
                      project: project,
                      onTap: () => onTap(project),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 맨 아래 새 공간 준비 바. 왼쪽은 준비(상담 준비·입지 선정)로, 오른쪽은 상담받기.
class _NewSpaceBar extends StatelessWidget {
  const _NewSpaceBar({
    required this.caption,
    required this.fontScale,
    required this.onOpen,
    required this.onConsult,
  });

  final String caption;
  final double fontScale;
  final VoidCallback onOpen;
  final VoidCallback onConsult;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 4, 6),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.add_home_work_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '새 공간 준비',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14 * fontScale,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            ConsultButton(height: 48, onPressed: onConsult),
          ],
        ),
      ),
    );
  }
}

/// 공간이 하나도 없을 때. 이미지 위에 상담으로 들어오는 시작 화면.
class _StartHero extends StatelessWidget {
  const _StartHero({
    required this.hasPrep,
    required this.onConsult,
    required this.onPrep,
  });

  final bool hasPrep;
  final VoidCallback onConsult;
  final VoidCallback onPrep;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final AppWindow window = AppWindow.of(context);
    final double pad =
        window.isExpanded
            ? 28
            : window.isMedium
            ? 24
            : 20;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppNetworkImage(url: 'assets/images/app_images/wapll_cafe.png'),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x330B1F38),
                  Color(0x990B1F38),
                  Color(0xF20B1F38),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '이제, 당신의 공간을\n시작할 차례예요',
                  style: TextStyle(
                    fontSize: 26 * fontScale,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.4,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '매장, 사무실, 어떤 공간이든 상담부터 함께해요.',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: const Color(0xE6FFFFFF),
                  ),
                ),
                const SizedBox(height: 20),
                ConsultButton(
                  expand: true,
                  onImage: true,
                  onPressed: onConsult,
                ),
                const SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: onPrep,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              hasPrep ? '새 공간 준비 이어서 보기' : '상담 준비 · 입지 선정 보기',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xE6FFFFFF),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xCCFFFFFF),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
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
