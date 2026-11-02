import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/process_schedule_provider.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/schedule/process_schedule_calendar.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/schedule/process_schedule_grid.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';

enum ProcessScheduleKind { calendar, table }

/// 캘린더 공정표와 가로 표 공정표. 둘은 같은 일정을 본다.
class ProcessScheduleScreen extends ConsumerStatefulWidget {
  const ProcessScheduleScreen({super.key});

  @override
  ConsumerState<ProcessScheduleScreen> createState() =>
      _ProcessScheduleScreenState();
}

class _ProcessScheduleScreenState extends ConsumerState<ProcessScheduleScreen> {
  ProcessScheduleKind _kind = ProcessScheduleKind.calendar;
  late DateTime _month;
  late DateTime _gridStart;
  late DateTime _gridEnd;

  @override
  void initState() {
    super.initState();
    final DateTime today = appCalendarDate(DateTime.now());
    _month = appCalendarMonth(today);
    _gridStart = DateTime(today.year, today.month, 1);
    _gridEnd = DateTime(today.year, today.month + 2, 0);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final List<ProcessScheduleTask> tasks = ref.watch(processScheduleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('공정표')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: inset.copyWith(top: 12, bottom: 8),
            child: _KindSwitch(
              kind: _kind,
              onChanged: (ProcessScheduleKind kind) {
                setState(() => _kind = kind);
              },
            ),
          ),
          if (_kind == ProcessScheduleKind.table)
            Padding(
              padding: inset.copyWith(bottom: 8),
              child: Text(
                '칸을 누르면 그 날이 켜지고, 길게 눌러 끌면 이어집니다. 이름은 눌러 고치고, 길게 누르면 빠집니다.',
                style: TextStyle(
                  fontSize: 12 * ResponsiveSize.fontScale(context),
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Expanded(
            child:
                _kind == ProcessScheduleKind.calendar
                    ? Padding(
                      padding: inset.copyWith(bottom: 16),
                      child: ProcessScheduleCalendar(
                        month: _month,
                        tasks: tasks,
                        onMonthChanged: (DateTime month) {
                          setState(() => _month = month);
                        },
                      ),
                    )
                    : ProcessScheduleGrid(
                      start: _gridStart,
                      end: _gridEnd,
                      tasks: tasks,
                      onDaySet: (String id, int dayKey, bool on) {
                        ref
                            .read(processScheduleProvider.notifier)
                            .setDay(id, dayKey, on);
                      },
                      onRename: (String id, String name) {
                        ref
                            .read(processScheduleProvider.notifier)
                            .rename(id, name);
                      },
                      onRemove: (String id) {
                        ref.read(processScheduleProvider.notifier).remove(id);
                      },
                      onAdd: () {
                        ref.read(processScheduleProvider.notifier).add();
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _KindSwitch extends StatelessWidget {
  const _KindSwitch({required this.kind, required this.onChanged});

  final ProcessScheduleKind kind;
  final ValueChanged<ProcessScheduleKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _KindOption(
              label: '캘린더',
              selected: kind == ProcessScheduleKind.calendar,
              onTap: () => onChanged(ProcessScheduleKind.calendar),
            ),
            _KindOption(
              label: '표',
              selected: kind == ProcessScheduleKind.table,
              onTap: () => onChanged(ProcessScheduleKind.table),
            ),
          ],
        ),
      ),
    );
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
