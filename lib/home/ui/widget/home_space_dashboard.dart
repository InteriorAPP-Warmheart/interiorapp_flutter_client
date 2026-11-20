import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/process_schedule_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/estimate_reader_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/home/domain/home_agenda.dart';
import 'package:interiorapp_flutter_client/home/presentation/provider/home_task_check_provider.dart';

/// 광고 아래. 날짜에 맞춰 현장의 공정과 내가 할 일.
class HomeSpaceDashboard extends StatelessWidget {
  const HomeSpaceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = ResponsiveSize.textInset(context);

    return Padding(padding: inset, child: const _DutyBoard());
  }
}

class _DutyBoard extends ConsumerStatefulWidget {
  const _DutyBoard();

  @override
  ConsumerState<_DutyBoard> createState() => _DutyBoardState();
}

class _DutyBoardState extends ConsumerState<_DutyBoard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final HomeAgenda agenda = homeAgenda(
      projects: <SpaceProject>[...board.received, ...board.ongoing],
      progressOf: board.constructionFor,
      schedule: ref.watch(processScheduleProvider),
      now: DateTime.now(),
    );
    final int index = _index.clamp(0, agenda.days.length - 1);
    final DateTime day = agenda.days[index];
    final List<HomeCollection> collections = agenda.collectionsOn(day);
    final double fontScale = ResponsiveSize.fontScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: <Widget>[
            for (var i = 0; i < agenda.days.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 4),
              _DayTab(
                label: homeAgendaDayLabel(agenda.days[i], agenda.today),
                count: agenda.countOn(agenda.days[i]),
                selected: i == index,
                fontScale: fontScale,
                onTap: () => setState(() => _index = i),
              ),
            ],
          ],
        ),
        SizedBox(height: ResponsiveSize.subGap(context)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var i = 0; i < collections.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _CollectionCard(
                  collection: collections[i],
                  fontScale: fontScale,
                  onTap: () => _openCollection(collections[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _openCollection(HomeCollection collection) async {
    if (collection.pieces.isEmpty) return;
    final bool tasks = collection.kind == HomeCollectionKind.task;
    if (!tasks && collection.pieces.length == 1) {
      _go(collection.pieces.first);
      return;
    }
    final HomePiece? picked = await showAppBottomSheet<HomePiece>(
      context: context,
      title: collection.label,
      size: AppBottomSheetSize.compact,
      child: _PieceList(kind: collection.kind, pieces: collection.pieces),
    );
    if (picked == null || !mounted) return;
    _go(picked);
  }

  void _go(HomePiece piece) {
    if (piece.projectId.isEmpty) return;
    if (piece.open == HomePieceOpen.estimate) {
      final WorkQuote? quote =
          ref.read(spaceBoardProvider).find(piece.projectId)?.workQuote;
      if (quote != null) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (BuildContext context) => EstimateReaderScreen(quote: quote),
          ),
        );
        return;
      }
    }
    context.push(SpaceRoutes.detail(piece.projectId));
  }
}

class _DayTab extends StatelessWidget {
  const _DayTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color ink = selected ? AppColors.white : AppColors.textPrimary;
    final Color countInk =
        selected ? AppColors.white.withValues(alpha: 0.78) : AppColors.accent;
    return Material(
      color: selected ? AppColors.primary : const Color(0x00000000),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: ink,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: countInk,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.fontScale,
    required this.onTap,
  });

  final HomeCollection collection;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = collection.count > 0;
    final Color wash = _collectionWash(collection.kind);
    return Material(
      color: wash,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: active ? onTap : null,
        child: Ink(
          height: 148,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                url: _collectionImage(collection.kind),
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      wash.withValues(alpha: 0.22),
                      wash.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _collectionIcon(collection.kind),
                      size: 22,
                      color: AppColors.white,
                    ),
                    const Spacer(),
                    Text(
                      collection.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${collection.count}',
                      style: TextStyle(
                        fontSize: 22 * fontScale,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColors.white,
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

/// 칸은 세로로 길다. 배경은 그 비율의 고정 사진이다.
String _collectionImage(HomeCollectionKind kind) {
  return switch (kind) {
    HomeCollectionKind.trade => 'assets/images/home/prep_trade.jpg',
    HomeCollectionKind.task => 'assets/images/home/prep_task.jpg',
  };
}

IconData _collectionIcon(HomeCollectionKind kind) {
  return switch (kind) {
    HomeCollectionKind.trade => Icons.architecture_rounded,
    HomeCollectionKind.task => Icons.checklist_rounded,
  };
}

Color _collectionWash(HomeCollectionKind kind) {
  return switch (kind) {
    HomeCollectionKind.trade => AppColors.primary,
    HomeCollectionKind.task => AppColors.accent,
  };
}

class _PieceList extends ConsumerWidget {
  const _PieceList({required this.kind, required this.pieces});

  final HomeCollectionKind kind;
  final List<HomePiece> pieces;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final Set<String> checked = ref.watch(homeTaskCheckProvider);
    final bool tasks = kind == HomeCollectionKind.task;
    return ListView.separated(
      itemCount: pieces.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (BuildContext context, int index) {
        final HomePiece piece = pieces[index];
        final bool done = tasks && homeTaskDone(piece, checked);
        return Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFD7DCE3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(piece),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
              child: Row(
                children: [
                  if (tasks)
                    _TaskCheck(
                      done: done,
                      onTap: () {
                        if (piece.settled) return;
                        ref
                            .read(homeTaskCheckProvider.notifier)
                            .toggle(piece.id);
                      },
                    )
                  else
                    const _TradeMark(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          piece.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15 * fontScale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                            color:
                                done
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        if (piece.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            piece.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13 * fontScale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskCheck extends StatelessWidget {
  const _TaskCheck({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: done ? AppColors.accent : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: done ? AppColors.accent : const Color(0xFFD7DCE3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            done ? Icons.check_rounded : null,
            size: 20,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _TradeMark extends StatelessWidget {
  const _TradeMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.architecture_rounded,
        size: 18,
        color: AppColors.primary,
      ),
    );
  }
}
