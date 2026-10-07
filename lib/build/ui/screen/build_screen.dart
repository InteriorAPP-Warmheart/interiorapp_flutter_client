import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/finished_space_tile.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/interior_prep_card.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/ongoing_space_pager.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';

enum _SpacePreview { sample, noOngoing, noFinished, prepOnly, empty }

class BuildScreen extends StatefulWidget {
  const BuildScreen({super.key});

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  _SpacePreview _preview = _SpacePreview.sample;

  @override
  void initState() {
    super.initState();
    SpaceBoard.instance.addListener(_onBoard);
  }

  @override
  void dispose() {
    SpaceBoard.instance.removeListener(_onBoard);
    super.dispose();
  }

  void _onBoard() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final AppWindow window = AppWindow.of(context);
    final double finishedHeight = window.isExpanded ? 156 : window.isMedium ? 132 : 112;
    final double prepHeight = window.isExpanded ? 72 : window.isMedium ? 64 : 56;
    final List<SpaceProject> ongoing =
        _preview == _SpacePreview.sample || _preview == _SpacePreview.noFinished
            ? [...SpaceBoard.instance.received, ...SpaceCatalog.ongoing]
            : const [];
    final List<SpaceProject> finished =
        _preview == _SpacePreview.sample || _preview == _SpacePreview.noOngoing
            ? SpaceCatalog.finished
            : const [];
    final bool hasOngoing = ongoing.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: Stack(
        children: [
          Padding(
        padding: EdgeInsets.fromLTRB(padding.left, subGap, padding.right, subGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '진행 중인 공간',
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
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
                                child: _EmptyRegionText(
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
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: subGap),
            SizedBox(
              height: finishedHeight,
              child: finished.isEmpty
                  ? _EmptyRegionText(label: '마친 공간이 없어요', fontScale: fontScale)
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
              child: ListenableBuilder(
                listenable: SpaceBoard.instance,
                builder: (BuildContext context, Widget? child) {
                  final SpaceBoard board = SpaceBoard.instance;
                  final bool showCard = _preview != _SpacePreview.empty &&
                      (board.consults.isNotEmpty || board.trades.isNotEmpty);
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
          Positioned(
            top: subGap,
            left: padding.left,
            right: padding.right,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<_SpacePreview>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const WidgetStatePropertyAll(Color(0xFFFCFCFC)),
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w600),
                  ),
                ),
                segments: const [
                  ButtonSegment(value: _SpacePreview.sample, label: Text('샘플')),
                  ButtonSegment(value: _SpacePreview.noOngoing, label: Text('진행 없음')),
                  ButtonSegment(value: _SpacePreview.noFinished, label: Text('마친 없음')),
                  ButtonSegment(value: _SpacePreview.prepOnly, label: Text('상담 전만')),
                  ButtonSegment(value: _SpacePreview.empty, label: Text('없음')),
                ],
                selected: {_preview},
                onSelectionChanged: (Set<_SpacePreview> next) {
                  setState(() => _preview = next.first);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          color: const Color(0xFFFFFFFF),
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
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '무엇을 정리할까요',
                    style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '상담으로 넘길 내용을 쓰거나, 자리를 고르기 전에 후보지를 남겨 둘 수 있어요.',
                    style: TextStyle(fontSize: 14 * fontScale, height: 1.45, color: const Color(0xFF1A1A1A)),
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
  if (SpaceBoard.instance.trades.length >= SpaceBoard.maxTrades) {
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
      color: const Color(0xFFF6F3EE),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1A1A1A))),
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
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Center(child: Icon(Icons.add, color: Color(0xFFFFFFFF))),
        ),
      ),
    );
  }
}

class _EmptyRegionText extends StatelessWidget {
  const _EmptyRegionText({required this.label, required this.fontScale});

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15 * fontScale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8A8A8A),
        ),
      ),
    );
  }
}
