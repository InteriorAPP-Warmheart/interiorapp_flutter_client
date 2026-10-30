import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/site_photo_days.dart';

/// 갤러리 또는 현장 사진에서 이미지 주소 하나를 고른다.
Future<String?> pickWriteImage(
  BuildContext context, {
  required List<PublicSitePhoto> photos,
  required bool Function(String url) used,
}) async {
  final List<String> urls = await pickWriteImages(
    context,
    photos: photos,
    used: used,
    multiple: false,
  );
  if (urls.isEmpty) return null;
  return urls.first;
}

/// 갤러리와 현장 사진 모두, 본문처럼 여러 장이 허용되면 여러 장을 고른다.
Future<List<String>> pickWriteImages(
  BuildContext context, {
  required List<PublicSitePhoto> photos,
  required bool Function(String url) used,
  bool multiple = true,
}) async {
  final _AttachChoice? choice = await showModalBottomSheet<_AttachChoice>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text(
                  '갤러리에서 첨부',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => Navigator.of(context).pop(_AttachChoice.gallery),
              ),
              ListTile(
                enabled: photos.isNotEmpty,
                leading: const Icon(Icons.apartment_outlined),
                title: const Text(
                  '현장사진 불러오기',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  photos.isEmpty
                      ? '이 공간에 공개된 현장 사진이 없어요'
                      : multiple
                      ? '여러 장을 골라 넣을 수 있어요'
                      : '날짜와 공정으로 골라요',
                ),
                onTap:
                    photos.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_AttachChoice.site),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null || !context.mounted) return const <String>[];
  if (choice == _AttachChoice.gallery) {
    if (!multiple) {
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return const <String>[];
      return <String>[file.path];
    }
    final List<XFile> files = await ImagePicker().pickMultiImage(
      imageQuality: 85,
    );
    return <String>[for (final XFile file in files) file.path];
  }
  if (!context.mounted) return const <String>[];
  final List<String>? urls = await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (BuildContext sheetContext) =>
            _SitePhotoSheet(photos: photos, used: used, multiple: multiple),
  );
  if (urls == null || urls.isEmpty) return const <String>[];
  return urls;
}

class _SitePhotoSheet extends StatefulWidget {
  const _SitePhotoSheet({
    required this.photos,
    required this.used,
    required this.multiple,
  });

  final List<PublicSitePhoto> photos;
  final bool Function(String url) used;
  final bool multiple;

  @override
  State<_SitePhotoSheet> createState() => _SitePhotoSheetState();
}

class _SitePhotoSheetState extends State<_SitePhotoSheet> {
  final List<String> _selected = <String>[];

  void _onPhoto(String url) {
    if (!widget.multiple) {
      Navigator.of(context).pop(<String>[url]);
      return;
    }
    setState(() {
      if (_selected.contains(url)) {
        _selected.remove(url);
      } else {
        _selected.add(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '현장 사진',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.multiple
                  ? '날짜를 넘기고 공정을 고른 뒤, 넣을 사진을 여러 장 고르세요.'
                  : '날짜를 넘기고 공정을 고른 뒤, 넣을 사진을 눌러 주세요.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: SitePhotoDays(
                  photos: widget.photos,
                  used: widget.used,
                  selected: _selected.toSet(),
                  onPhoto: _onPhoto,
                ),
              ),
            ),
            if (widget.multiple) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed:
                      _selected.isEmpty
                          ? null
                          : () => Navigator.of(
                            context,
                          ).pop(List<String>.of(_selected)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? '사진을 골라 주세요'
                        : '${_selected.length}장 넣기',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> pickIndustry(BuildContext context, {String current = ''}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) => _IndustrySheet(current: current),
  );
}

Future<int?> pickPyeong(BuildContext context, {required int current}) {
  final int initial = current.clamp(1, 1000);
  final FixedExtentScrollController wheel = FixedExtentScrollController(
    initialItem: initial - 1,
  );
  int selected = initial;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: SizedBox(
          height: 340,
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
                padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '평수',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: wheel,
                  itemExtent: 36,
                  onSelectedItemChanged: (int index) => selected = index + 1,
                  children: [
                    for (var n = 1; n <= 1000; n++)
                      Center(
                        child: Text(
                          '$n',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '선택',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(wheel.dispose);
}

class _IndustrySheet extends StatefulWidget {
  const _IndustrySheet({required this.current});

  final String current;

  @override
  State<_IndustrySheet> createState() => _IndustrySheetState();
}

class _IndustrySheetState extends State<_IndustrySheet> {
  late String _selected = widget.current;

  String get _groupName {
    for (final IndustryCategory category in industryCategories) {
      for (final IndustryDetail detail in category.details) {
        if (detail.name == _selected) return category.name;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height * 0.78;
    final bool ready = _selected.trim().isNotEmpty;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              '업종',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              ready
                  ? (_groupName.isEmpty
                      ? _selected
                      : '$_groupName · $_selected')
                  : '영역 안에서 하나를 고른 뒤 확인해요',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                for (final IndustryCategory category in industryCategories)
                  _IndustryGroup(
                    category: category,
                    selected: _selected,
                    onSelect: (String name) => setState(() => _selected = name),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed:
                      ready ? () => Navigator.of(context).pop(_selected) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFE4E6EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndustryGroup extends StatelessWidget {
  const _IndustryGroup({
    required this.category,
    required this.selected,
    required this.onSelect,
  });

  final IndustryCategory category;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final bool contains = category.details.any(
      (IndustryDetail detail) => detail.name == selected,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: contains ? AppColors.primary : AppColors.border,
          width: contains ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final IndustryDetail detail in category.details)
                  _ChoiceChip(
                    label: detail.name,
                    selected: detail.name == selected,
                    onTap: () => onSelect(detail.name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

enum _AttachChoice { gallery, site }

String groupedDigits(String raw) {
  final String digits = raw.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return '';
  final int number = int.tryParse(digits) ?? 0;
  return number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match match) => '${match[1]},',
  );
}
