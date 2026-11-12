import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/core/widget/app_segment.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_dialog.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';

/// 저장한 쇼룸과 최근 본 쇼룸을 날짜 묶음으로 본다.
class ContentHistoryScreen extends ConsumerStatefulWidget {
  const ContentHistoryScreen({super.key, this.initialTab = 0});

  /// 0은 저장, 1은 최근 본.
  final int initialTab;

  @override
  ConsumerState<ContentHistoryScreen> createState() =>
      _ContentHistoryScreenState();
}

class _ContentHistoryScreenState extends ConsumerState<ContentHistoryScreen> {
  late int _tab = widget.initialTab.clamp(0, 1);
  _HistorySpan _span = _HistorySpan.month;
  DateTimeRange? _custom;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<SavedContentModel> saved = ref.watch(savedContentVmProvider);
    final List<RecentContentModel> recent = ref.watch(recentContentVmProvider);
    final bool savedReady = ref.watch(savedContentVmProvider.notifier).isReady;
    final bool recentReady =
        ref.watch(recentContentVmProvider.notifier).isReady;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('콘텐츠 기록'),
        actions: [
          if (_tab == 1 && recent.isNotEmpty)
            TextButton(
              onPressed: _confirmClearRecent,
              child: Text(
                '전체 삭제',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: AppSegmentHost(
        length: 2,
        initialIndex: _tab,
        onChanged: (int index) {
          if (!mounted || index == _tab) return;
          setState(() => _tab = index);
        },
        builder: (BuildContext context, AppSegmentController segment) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  subGap,
                  padding.right,
                  0,
                ),
                child: AppSegmentBar(
                  controller: segment,
                  labels: const <String>['저장한 콘텐츠', '최근 본 콘텐츠'],
                  height: 40,
                  fontSize: 13 * fontScale,
                  trackColor: AppColors.surface,
                  thumbColor: AppColors.primary,
                  selectedColor: AppColors.white,
                  unselectedColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                ),
              ),
              SizedBox(height: subGap),
              _SpanBar(
                span: _span,
                custom: _custom,
                horizontal: padding.left,
                onPreset: (_HistorySpan span) {
                  setState(() => _span = span);
                },
                onCustom: _pickRange,
              ),
              SizedBox(height: subGap),
              Expanded(
                child:
                    _tab == 0
                        ? _SavedList(
                          items: saved,
                          ready: savedReady,
                          span: _span,
                          custom: _custom,
                          onOpen: (SavedContentModel item) {
                            context.push('/showroom/${item.id}/board');
                          },
                          onUnsave: _unsave,
                        )
                        : _RecentList(
                          items: recent,
                          ready: recentReady,
                          span: _span,
                          custom: _custom,
                          onOpen: (RecentContentModel item) {
                            context.push('/showroom/${item.id}/board');
                          },
                          onRemove: (String id) {
                            ref
                                .read(recentContentVmProvider.notifier)
                                .remove(id);
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickRange() async {
    final DateTime today = DateTime.now();
    final DateTimeRange? picked = await showAppDateRangeDialog(
      context: context,
      initialRange: _custom,
      firstDate: DateTime(today.year - 2, today.month, today.day),
      lastDate: today,
      title: '기간',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _custom = picked;
      _span = _HistorySpan.custom;
    });
  }

  Future<void> _unsave(String id) async {
    final HotShowroomModel? current =
        ref
            .read(hotShowroomSliderVm)
            .where((HotShowroomModel item) => item.id == id)
            .firstOrNull;
    if (current != null && current.favoriteStatus) {
      await ref.read(hotShowroomSliderVm.notifier).toggleFavoriteByIndex(id);
      return;
    }
    await ref.read(savedContentVmProvider.notifier).remove(id);
  }

  Future<void> _confirmClearRecent() async {
    final bool? clear = await showAppDialog<bool>(
      context: context,
      title: '최근 본 쇼룸을 지울까요?',
      message: '이 기기에 남은 최근 본 기록이 사라져요.',
      actions: (BuildContext dialogContext) {
        return <Widget>[
          AppButton(
            label: '지우기',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          AppButton(
            label: '취소',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ];
      },
    );
    if (clear != true || !mounted) return;
    await ref.read(recentContentVmProvider.notifier).clearAll();
  }
}

enum _HistorySpan { month, quarter, halfYear, all, custom }

class _SpanBar extends StatelessWidget {
  const _SpanBar({
    required this.span,
    required this.custom,
    required this.horizontal,
    required this.onPreset,
    required this.onCustom,
  });

  final _HistorySpan span;
  final DateTimeRange? custom;
  final double horizontal;
  final ValueChanged<_HistorySpan> onPreset;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<(String, VoidCallback, bool)> chips =
        <(String, VoidCallback, bool)>[
          (
            '1개월',
            () => onPreset(_HistorySpan.month),
            span == _HistorySpan.month,
          ),
          (
            '3개월',
            () => onPreset(_HistorySpan.quarter),
            span == _HistorySpan.quarter,
          ),
          (
            '6개월',
            () => onPreset(_HistorySpan.halfYear),
            span == _HistorySpan.halfYear,
          ),
          ('전체', () => onPreset(_HistorySpan.all), span == _HistorySpan.all),
          (
            custom == null ? '기간' : _formatRange(custom!),
            onCustom,
            span == _HistorySpan.custom,
          ),
        ];

    return SizedBox(
      height: _SpanChip.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        itemCount: chips.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (BuildContext context, int index) {
          final (String label, VoidCallback onTap, bool selected) =
              chips[index];
          return _SpanChip(
            label: label,
            selected: selected,
            fontScale: fontScale,
            onTap: onTap,
          );
        },
      ),
    );
  }
}

class _SpanChip extends StatelessWidget {
  const _SpanChip({
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  static const double height = 34;

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderSide side = BorderSide(
      color: selected ? AppColors.primary : AppColors.border,
      width: 1,
    );
    return SizedBox(
      height: height,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: StadiumBorder(side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1,
                  leadingDistribution: TextLeadingDistribution.even,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedList extends StatelessWidget {
  const _SavedList({
    required this.items,
    required this.ready,
    required this.span,
    required this.custom,
    required this.onOpen,
    required this.onUnsave,
  });

  final List<SavedContentModel> items;
  final bool ready;
  final _HistorySpan span;
  final DateTimeRange? custom;
  final ValueChanged<SavedContentModel> onOpen;
  final ValueChanged<String> onUnsave;

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return const _EmptyHistory(
        icon: Icons.bookmark_outline_rounded,
        title: '저장한 쇼룸이 없어요',
        message: '쇼룸에서 하트를 누르면 여기에 모여요.',
      );
    }
    final List<_DayGroup<SavedContentModel>> groups = _groupByDay(
      items.where((SavedContentModel item) {
        return _within(item.savedAt, span, custom);
      }).toList(),
      (SavedContentModel item) => item.savedAt,
    );
    if (groups.isEmpty) {
      return const _EmptyHistory(
        icon: Icons.event_busy_outlined,
        title: '이 기간에는 쇼룸이 없어요',
        message: '기간을 넓혀 다시 볼 수 있어요.',
      );
    }
    return _HistoryGroups(
      groups: groups,
      tileBuilder: (SavedContentModel item) {
        return _HistoryTile(
          key: ValueKey<String>(item.id),
          thumbnailUrl: item.thumbnailUrl,
          title: item.title,
          actionIcon: Icons.bookmark_rounded,
          actionTooltip: '저장 해제',
          onTap: () => onOpen(item),
          onAction: () => onUnsave(item.id),
        );
      },
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({
    required this.items,
    required this.ready,
    required this.span,
    required this.custom,
    required this.onOpen,
    required this.onRemove,
  });

  final List<RecentContentModel> items;
  final bool ready;
  final _HistorySpan span;
  final DateTimeRange? custom;
  final ValueChanged<RecentContentModel> onOpen;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return const _EmptyHistory(
        icon: Icons.history_rounded,
        title: '최근 본 쇼룸이 없어요',
        message: '쇼룸을 열면 여기에 기록돼요.',
      );
    }
    final List<_DayGroup<RecentContentModel>> groups = _groupByDay(
      items.where((RecentContentModel item) {
        return _within(item.viewedAt, span, custom);
      }).toList(),
      (RecentContentModel item) => item.viewedAt,
    );
    if (groups.isEmpty) {
      return const _EmptyHistory(
        icon: Icons.event_busy_outlined,
        title: '이 기간에는 쇼룸이 없어요',
        message: '기간을 넓혀 다시 볼 수 있어요.',
      );
    }
    return _HistoryGroups(
      groups: groups,
      tileBuilder: (RecentContentModel item) {
        return _HistoryTile(
          key: ValueKey<String>(item.id),
          thumbnailUrl: item.thumbnailUrl,
          title: item.title,
          actionIcon: Icons.close_rounded,
          actionTooltip: '기록 삭제',
          onTap: () => onOpen(item),
          onAction: () => onRemove(item.id),
        );
      },
    );
  }
}

class _HistoryGroups<T> extends StatelessWidget {
  const _HistoryGroups({required this.groups, required this.tileBuilder});

  final List<_DayGroup<T>> groups;
  final Widget Function(T item) tileBuilder;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final DateTime today = _localDay(DateTime.now());

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        0,
        padding.right,
        MediaQuery.paddingOf(context).bottom + subGap,
      ),
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) {
        final _DayGroup<T> group = groups[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == groups.length - 1 ? 0 : subGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateHeader(label: _dayLabel(group.day, today)),
              _HistoryGrid(
                tiles: <Widget>[
                  for (final T item in group.items) tileBuilder(item),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 칸 너비가 180 안팎이 되도록 2열에서 4열까지 나눈다.
class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.tiles});

  final List<Widget> tiles;

  static const double _gap = 10;
  static const double _targetWidth = 180;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns =
            (constraints.maxWidth / _targetWidth).floor().clamp(2, 4);
        final double width =
            (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: <Widget>[
            for (final Widget tile in tiles)
              SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13 * fontScale,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onTap,
    required this.onAction,
  });

  final String thumbnailUrl;
  final String title;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onTap;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final String label = title.trim();
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: thumbnailUrl),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 72,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[Color(0x9E000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Tooltip(
                  message: actionTooltip,
                  child: GestureDetector(
                    onTap: onAction,
                    behavior: HitTestBehavior.opaque,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0x66000000),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(actionIcon, size: 16, color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ),
              if (label.isNotEmpty)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: AppColors.white,
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayGroup<T> {
  const _DayGroup({required this.day, required this.items});

  final DateTime day;
  final List<T> items;
}

List<_DayGroup<T>> _groupByDay<T>(List<T> items, DateTime Function(T item) at) {
  final Map<DateTime, List<T>> grouped = <DateTime, List<T>>{};
  for (final T item in items) {
    final DateTime day = _localDay(at(item));
    (grouped[day] ??= <T>[]).add(item);
  }
  final List<DateTime> days =
      grouped.keys.toList()..sort((DateTime a, DateTime b) => b.compareTo(a));
  return <_DayGroup<T>>[
    for (final DateTime day in days)
      _DayGroup<T>(
        day: day,
        items: (grouped[day]!..sort((T a, T b) => at(b).compareTo(at(a)))),
      ),
  ];
}

bool _within(DateTime at, _HistorySpan span, DateTimeRange? custom) {
  final DateTime day = _localDay(at);
  final DateTime today = _localDay(DateTime.now());
  switch (span) {
    case _HistorySpan.month:
      return !day.isBefore(DateTime(today.year, today.month - 1, today.day));
    case _HistorySpan.quarter:
      return !day.isBefore(DateTime(today.year, today.month - 3, today.day));
    case _HistorySpan.halfYear:
      return !day.isBefore(DateTime(today.year, today.month - 6, today.day));
    case _HistorySpan.all:
      return true;
    case _HistorySpan.custom:
      if (custom == null) return true;
      final DateTime start = _localDay(custom.start);
      final DateTime end = _localDay(custom.end);
      return !day.isBefore(start) && !day.isAfter(end);
  }
}

DateTime _localDay(DateTime at) {
  final DateTime local = at.toLocal();
  return DateTime(local.year, local.month, local.day);
}

const List<String> _weekdays = <String>['월', '화', '수', '목', '금', '토', '일'];

String _dayLabel(DateTime day, DateTime today) {
  if (day == today) return '오늘';
  if (day == today.subtract(const Duration(days: 1))) return '어제';
  final String week = _weekdays[day.weekday - 1];
  if (day.year == today.year) return '${day.month}월 ${day.day}일 $week';
  return '${day.year}년 ${day.month}월 ${day.day}일 $week';
}

String _formatRange(DateTimeRange range) {
  String one(DateTime date) {
    final DateTime local = date.toLocal();
    if (local.year == DateTime.now().year) {
      return '${local.month}.${local.day}';
    }
    return '${local.year}.${local.month}.${local.day}';
  }

  return '${one(range.start)} - ${one(range.end)}';
}
