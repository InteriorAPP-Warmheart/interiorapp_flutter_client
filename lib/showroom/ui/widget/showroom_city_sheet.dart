import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_city_catalog.dart';

Future<String?> showShowroomCitySheet(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) => _ShowroomCitySheet(current: current),
  );
}

class _ShowroomCitySheet extends StatefulWidget {
  const _ShowroomCitySheet({this.current});

  final String? current;

  @override
  State<_ShowroomCitySheet> createState() => _ShowroomCitySheetState();
}

class _ShowroomCitySheetState extends State<_ShowroomCitySheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ShowroomCityGroup> groups = showroomCitiesMatching(_query.text);
    final double height = MediaQuery.sizeOf(context).height * 0.72;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '어디를 볼까요?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '시·도 이름',
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF4F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Expanded(
            child:
                groups.isEmpty
                    ? const Center(
                      child: Text(
                        '해당하는 시가 없어요',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                    : ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        for (final ShowroomCityGroup group in groups) ...[
                          _RegionHeader(
                            name: group.name,
                            count: group.cities.length,
                            selected: group.name == widget.current,
                            onTap: () => Navigator.pop(context, group.name),
                          ),
                          for (final String city in group.cities)
                            _CityTile(
                              city: city,
                              selected: city == widget.current,
                              onTap: () => Navigator.pop(context, city),
                            ),
                        ],
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class _RegionHeader extends StatelessWidget {
  const _RegionHeader({
    required this.name,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, color: AppColors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.city,
    required this.selected,
    required this.onTap,
  });

  final String city;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4),
          ),
        ),
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.only(left: 16, right: 12),
          title: Text(
            city,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing:
              selected
                  ? const Icon(Icons.check, color: AppColors.primary, size: 20)
                  : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
