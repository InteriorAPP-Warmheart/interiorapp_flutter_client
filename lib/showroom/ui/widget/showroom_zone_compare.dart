import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_wipe_compare.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 한 칸에서 고르는 시공 전후 구역.
class ShowroomZone {
  const ShowroomZone({
    required this.label,
    required this.beforeUrl,
    required this.afterUrl,
    this.note = '',
  });

  final String label;
  final String beforeUrl;
  final String afterUrl;

  /// 구역 이름과 다른 설명. 이름과 같으면 다시 그리지 않는다.
  final String note;
}

/// 시공 전후를 한 칸에 두고, 구역이 여러 개면 아래에서 고른다.
class ShowroomZoneCompare extends StatefulWidget {
  const ShowroomZoneCompare({super.key, required this.zones, this.onOpen});

  final List<ShowroomZone> zones;

  /// 지금 보이는 전후 사진을 연다. [showingAfter]는 후가 앞에 있을 때다.
  final void Function(int zoneIndex, bool showingAfter)? onOpen;

  @override
  State<ShowroomZoneCompare> createState() => _ShowroomZoneCompareState();
}

class _ShowroomZoneCompareState extends State<ShowroomZoneCompare> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant ShowroomZoneCompare oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.zones.length) {
      _index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zones.isEmpty) return const SizedBox.shrink();
    final ShowroomZone zone = widget.zones[_index];
    final String note = zone.note.trim();
    final bool showNote = note.isNotEmpty && note != zone.label;
    final bool several = widget.zones.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowroomWipeCompare(
          beforeUrl: zone.beforeUrl,
          afterUrl: zone.afterUrl,
          caption: several ? '' : zone.label.trim(),
          onOpen:
              widget.onOpen == null
                  ? null
                  : (bool showingAfter) => widget.onOpen!(_index, showingAfter),
        ),
        if (showNote) ...[
          const SizedBox(height: 8),
          Padding(
            padding: ResponsiveSize.textInset(context),
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Color(0xFF3A3834),
              ),
            ),
          ),
        ],
        if (several) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: ResponsiveSize.textInset(context),
              itemCount: widget.zones.length,
              separatorBuilder:
                  (BuildContext context, int index) =>
                      const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                return _ZoneChip(
                  zone: widget.zones[index],
                  selected: index == _index,
                  onTap: () => setState(() => _index = index),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({
    required this.zone,
    required this.selected,
    required this.onTap,
  });

  final ShowroomZone zone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String photo =
        zone.afterUrl.isNotEmpty ? zone.afterUrl : zone.beforeUrl;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? storyInk : const Color(0xFFE7E1D8),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 76,
                    height: 68,
                    child: AppNetworkImage(url: photo),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              zone.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? storyInk : const Color(0xFF8A847A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
