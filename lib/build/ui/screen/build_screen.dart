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
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final AppWindow window = AppWindow.of(context);
    final double finishedHeight = window.isExpanded ? 156 : window.isMedium ? 132 : 112;
    final double prepHeight = window.isExpanded ? 72 : window.isMedium ? 64 : 56;
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final List<SpaceProject> ongoing = [
      ...board.received,
      ...board.ongoing,
    ];
    final List<SpaceProject> finished = board.finished;
    final bool hasOngoing = ongoing.isNotEmpty;
    final bool inTab = GoRouterState.of(context).uri.path == '/';
    final double bottomGap = inTab
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
            Text(
              '진행 중인 공간',
              style: _sectionTitle(fontScale),
            ),
            SizedBox(height: subGap),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: hasOngoing
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
                              const SizedBox(height: kOngoingPageIndicatorHeight),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Text(
              '마친 공간',
              style: _sectionTitle(fontScale),
            ),
            SizedBox(height: subGap),
            SizedBox(
              height: finishedHeight,
              child: finished.isEmpty
                  ? _EmptyRegion(label: '마친 공간이 없어요', fontScale: fontScale)
                  : LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        const double gap = 10;
                        final int count = finished.length;
                        final double width = count <= 2
                            ? (constraints.maxWidth - gap * (count - 1)) / count
                            : (constraints.maxWidth - gap) / 2.2;

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: count <= 2
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          itemCount: count,
                          separatorBuilder: (context, index) => const SizedBox(width: gap),
                          itemBuilder: (BuildContext context, int index) {
                            final SpaceProject project = finished[index];
                            return SizedBox(
                              width: width,
                              child: FinishedSpaceTile(
                                project: project,
                                onTap: () => context.push(SpaceRoutes.detail(project.id)),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            SizedBox(height: sectionGap),
            SizedBox(
              height: prepHeight,
              child: Builder(
                builder: (BuildContext context) {
                  final bool showCard =
                      board.consults.isNotEmpty || board.trades.isNotEmpty;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showCard) ...[
                        Expanded(
                          child: BeforeConsultEntry(
                            consultCount: board.consults.length,
                            tradeCount: board.trades.length,
                            onTap: () => context.push(SpaceRoutes.prep),
                          ),
                        ),
                        SizedBox(width: subGap),
                      ] else
                        const Spacer(),
                      _PrepAddButton(
                        size: prepHeight,
                        onPressed: () => _openAddSheet(context),
                      ),
                    ],
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

Future<void> _openAddSheet(BuildContext context) async {
  final String? choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (BuildContext sheetContext) {
      final double fontScale = ResponsiveSize.fontScale(sheetContext);
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Material(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    '무엇을 정리할까요',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '상담으로 넘길 내용을 쓰거나, 자리를 고르기 전에 후보지를 남겨 둘 수 있어요.',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AddChoice(
                    title: '상담준비',
                    body: '업종, 현장, 공사 조건을 적어 상담으로 넘깁니다.',
                    onTap: () => Navigator.of(sheetContext).pop('consult'),
                  ),
                  const SizedBox(height: 8),
                  _AddChoice(
                    title: '상권 후보지',
                    body: '어디에 둘지 비교할 자리를 남깁니다. 점수는 만들지 않아요.',
                    onTap: () => Navigator.of(sheetContext).pop('trade'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  if (!context.mounted || choice == null) return;
  if (choice == 'consult') {
    context.push(SpaceRoutes.prepCreate);
    return;
  }
  if (ProviderScope.containerOf(context).read(spaceBoardProvider).trades.length >= SpaceBoard.maxTrades) {
    await showAppDialog<void>(
      context: context,
      title: '후보지는 두 곳까지예요',
      message: '비교 중인 후보지를 정리한 뒤에 새로 남겨 주세요.',
      actions: (BuildContext dialogContext) => [
        AppButton(label: '확인', onPressed: () => Navigator.of(dialogContext).pop()),
      ],
    );
    return;
  }
  context.push(SpaceRoutes.tradeCreate);
}

class _AddChoice extends StatelessWidget {
  const _AddChoice({required this.title, required this.body, required this.onTap});

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrepAddButton extends StatelessWidget {
  const _PrepAddButton({required this.size, required this.onPressed});

  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Center(child: Icon(Icons.add, color: AppColors.white)),
        ),
      ),
    );
  }
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
