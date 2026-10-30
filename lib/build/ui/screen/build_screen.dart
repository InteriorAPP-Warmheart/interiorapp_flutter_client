import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/finished_space_tile.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/interior_prep_card.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/ongoing_space_pager.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/theme/tab_bar_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';

class BuildScreen extends ConsumerStatefulWidget {
  const BuildScreen({super.key});

  @override
  ConsumerState<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends ConsumerState<BuildScreen> {
  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final AppWindow window = AppWindow.of(context);
    final double finishedHeight =
        window.isExpanded
            ? 156
            : window.isMedium
            ? 132
            : 112;
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final List<SpaceProject> ongoing = [...board.received, ...board.ongoing];
    final List<SpaceProject> finished = board.finished;
    final bool hasOngoing = ongoing.isNotEmpty;
    final bool inTab = GoRouterState.of(context).uri.path == '/';
    final double bottomGap =
        inTab
            ? AppTabBarTheme.height(context) +
                AppTabBarTheme.floatGap +
                AppTabBarTheme.bottomInset(context) +
                subGap
            : subGap + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          subGap,
          padding.right,
          bottomGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsultLaunchBand(
              consultCount: board.consults.length,
              tradeCount: board.trades.length,
              onPrep: () => context.push(SpaceRoutes.prep),
              onConsult: () => context.push(SpaceRoutes.prepCreate),
              onTrade: () => _openTradeCreate(context),
            ),
            SizedBox(height: sectionGap),
            Text('진행 중인 공간', style: _sectionTitle(fontScale)),
            SizedBox(height: subGap),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child:
                        hasOngoing
                            ? OngoingSpacePager(
                              projects: ongoing,
                              onTap: (SpaceProject project) {
                                context.push(SpaceRoutes.detail(project.id));
                              },
                            )
                            : Column(
                              children: [
                                Expanded(
                                  child: _EmptyRegion(
                                    label: '진행 중인 공간이 없어요',
                                    fontScale: fontScale,
                                  ),
                                ),
                                SizedBox(height: subGap),
                                const SizedBox(
                                  height: kOngoingPageIndicatorHeight,
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Text('마친 공간', style: _sectionTitle(fontScale)),
            SizedBox(height: subGap),
            SizedBox(
              height: finishedHeight,
              child:
                  finished.isEmpty
                      ? _EmptyRegion(label: '마친 공간이 없어요', fontScale: fontScale)
                      : LayoutBuilder(
                        builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                        ) {
                          const double gap = 10;
                          final int count = finished.length;
                          final double width =
                              count <= 2
                                  ? (constraints.maxWidth - gap * (count - 1)) /
                                      count
                                  : (constraints.maxWidth - gap) / 2.2;

                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics:
                                count <= 2
                                    ? const NeverScrollableScrollPhysics()
                                    : const BouncingScrollPhysics(),
                            itemCount: count,
                            separatorBuilder:
                                (context, index) => const SizedBox(width: gap),
                            itemBuilder: (BuildContext context, int index) {
                              final SpaceProject project = finished[index];
                              return SizedBox(
                                width: width,
                                child: FinishedSpaceTile(
                                  project: project,
                                  onTap:
                                      () => context.push(
                                        SpaceRoutes.detail(project.id),
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _sectionTitle(double fontScale) {
  return TextStyle(
    fontSize: 17 * fontScale,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );
}

Future<void> _openTradeCreate(BuildContext context) async {
  if (ProviderScope.containerOf(
        context,
      ).read(spaceBoardProvider).trades.length >=
      SpaceBoard.maxTrades) {
    await showAppDialog<void>(
      context: context,
      title: '후보지는 두 곳까지예요',
      message: '비교 중인 후보지를 정리한 뒤에 새로 남겨 주세요.',
      actions:
          (BuildContext dialogContext) => [
            AppButton(
              label: '확인',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
    );
    return;
  }
  if (!context.mounted) return;
  context.push(SpaceRoutes.tradeCreate);
}

class _EmptyRegion extends StatelessWidget {
  const _EmptyRegion({required this.label, required this.fontScale});

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
