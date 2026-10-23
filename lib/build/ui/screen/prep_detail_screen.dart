import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_survey.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_reference_pick.dart';

/// 저장해 둔 상담준비 한 건. 허브에서 열고, 작성 직후에도 같은 화면을 쓴다.
class PrepDetailScreen extends StatelessWidget {
  const PrepDetailScreen({super.key, required this.record});

  final PrepRecord? record;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final PrepRecord? current = record;

    if (current == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('상담준비')),
        body: Center(
          child: Text(
            '상담준비를 찾을 수 없어요',
            style: TextStyle(
              fontSize: 16 * fontScale,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return _PrepDetailScaffold(
      record: current,
      onEdit:
          (int step) =>
              context.push(SpaceRoutes.prepEdit(step), extra: current),
    );
  }
}

class _PrepDetailScaffold extends StatelessWidget {
  const _PrepDetailScaffold({required this.record, required this.onEdit});

  final PrepRecord record;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('상담준비')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            padding.left,
            subGap,
            padding.right,
            subGap,
          ),
          child: PrepDetailView(record: record, onEdit: onEdit),
        ),
      ),
    );
  }
}

/// 현장과 조건을 한 스크롤로 보여 준다.
class PrepDetailView extends ConsumerWidget {
  const PrepDetailView({super.key, required this.record, required this.onEdit});

  final PrepRecord record;
  final ValueChanged<int> onEdit;

  Future<void> _requestConsult(
    BuildContext context, {
    DateTime? periodStart,
  }) async {
    final _ConsultGap? gap = _consultGap(record);
    if (gap != null) {
      final bool? goEdit = await _showDateNotice(
        context,
        title: gap.title,
        body: gap.body,
        confirmLabel: '입력하러 가기',
      );
      if (!context.mounted) return;
      if (goEdit == true) onEdit(gap.step);
      return;
    }
    final _PrepDateCheck check = _checkPrepDate(
      periodStart ?? record.periodStart,
    );
    if (check == _PrepDateCheck.past) {
      final bool? changeDate = await _showDateNotice(
        context,
        title: '날짜를 바꿔 주세요',
        body: '직접 고른 시작일이 오늘보다 앞이에요. 상담을 신청하려면 기간을 다시 정해 주세요.',
        confirmLabel: '날짜 변경',
      );
      if (!context.mounted) return;
      if (changeDate == true) onEdit(1);
      return;
    }
    if (check == _PrepDateCheck.soon) {
      final bool? proceed = await _showDateNotice(
        context,
        title: '시작일이 곧이에요',
        body: '직접 고른 시작일까지 일주일이 채 남지 않았어요. 상담 일정을 잡으면서 날짜가 바뀔 수 있어요.',
        confirmLabel: '이대로 상담 신청',
        cancelLabel: '날짜 변경',
      );
      if (!context.mounted || proceed == null) return;
      if (!proceed) {
        onEdit(1);
        return;
      }
      context.push(SpaceRoutes.prepConsult, extra: record);
      return;
    }
    final bool? confirmed = await _showDateNotice(
      context,
      title: '상담을 신청할까요?',
      body: '이 내용이 관리자에게 전달돼요. 담당자가 전화로 확인한 뒤에 상담 일자를 정해요.',
      confirmLabel: '신청하기',
      cancelLabel: '취소',
    );
    if (!context.mounted || confirmed != true) return;
    context.push(SpaceRoutes.prepConsult, extra: record);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final String fullAddress =
        record.detailAddress.isEmpty
            ? record.address
            : '${record.address} ${record.detailAddress}';

    return ListView(
      children: [
        _PlaceCard(
          placeName: record.placeName,
          address: fullAddress,
          detailAddress:
              record.detailAddress.isEmpty ? '상세주소 없음' : record.detailAddress,
          area: _areaLabel(record.areaLine),
          buildingType: record.buildingType,
          industry: record.industryLine,
          contact: record.contact,
          fontScale: fontScale,
          onEdit: () => onEdit(0),
        ),
        if (record.styleRef case final ShowroomStyleRef reference) ...[
          SizedBox(height: sectionGap),
          ShowroomStyleReferenceTile(
            reference: reference,
            fontScale: fontScale,
          ),
        ],
        SizedBox(height: sectionGap),
        _ReviewSection(
          title: '조건',
          fontScale: fontScale,
          onEdit: () => onEdit(1),
          children: [
            _FactGrid(
              fontScale: fontScale,
              items: [
                _Fact(
                  icon: Icons.home_repair_service_outlined,
                  label: '공사 형태',
                  value: record.workScope,
                ),
                _Fact(
                  icon: Icons.layers_clear_outlined,
                  label: '철거 여부',
                  value: record.buildingCondition,
                ),
                _Fact(
                  icon: Icons.palette_outlined,
                  label: '스타일',
                  value: record.style,
                ),
                _Fact(
                  icon: Icons.payments_outlined,
                  label: '예산',
                  value: record.budgetLine,
                ),
                _Fact(
                  icon: Icons.calendar_month_outlined,
                  label: '희망공사기간',
                  value: record.period,
                ),
                _Fact(
                  icon: Icons.flag_outlined,
                  label: '희망 착공',
                  value: record.startTiming,
                ),
                _Fact(
                  icon: Icons.event_available_outlined,
                  label: '희망 오픈·완료',
                  value: record.openTiming,
                ),
                if (record.workScope == PrepLabels.partialWork)
                  _Fact(
                    icon: Icons.place_outlined,
                    label: '공사할 곳',
                    value: record.workPlace,
                  ),
              ],
            ),
            if (record.floorPlans.isNotEmpty) ...[
              const SizedBox(height: 16),
              _AttachedPhotoBlock(
                label: '평면도',
                regions: record.floorPlans,
                fontScale: fontScale,
              ),
            ] else if (record.floorPlanLabels.any(
              (String label) => label.trim().isNotEmpty,
            )) ...[
              const SizedBox(height: 16),
              _AttachmentPreview(
                label: '평면도',
                labels: record.floorPlanLabels,
                emptyLabel: '올린 평면도가 없어요',
                fontScale: fontScale,
                icon: Icons.map_outlined,
              ),
            ],
            if (record.stylePhotos.isNotEmpty) ...[
              const SizedBox(height: 16),
              _AttachedPhotoBlock(
                label: '스타일 사진',
                regions: record.stylePhotos,
                fontScale: fontScale,
              ),
            ] else if (record.referenceImageLabels.any(
              (String label) => label.trim().isNotEmpty,
            )) ...[
              const SizedBox(height: 16),
              _AttachmentPreview(
                label: '스타일 사진',
                labels: record.referenceImageLabels,
                emptyLabel: '올린 참고 이미지가 없어요',
                fontScale: fontScale,
                icon: Icons.image_outlined,
              ),
            ],
            const SizedBox(height: 8),
            _FactRow(
              icon: Icons.chat_bubble_outline,
              label: '상담에서 말하고 싶은 점',
              value: record.needs,
              fontScale: fontScale,
            ),
          ],
        ),
        SizedBox(height: sectionGap),
        _ReviewSection(
          title: '마감',
          fontScale: fontScale,
          onEdit: () => onEdit(2),
          children: [
            if (PrepSurvey.details.every(
              (PrepQuestion question) =>
                  record.finishes[question.id]?.isEmpty ?? true,
            ))
              Text(
                '선택 항목이에요. 아직 적지 않아도 상담으로 이어갈 수 있어요.',
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              )
            else
              _FactGrid(
                fontScale: fontScale,
                items: [
                  for (final PrepQuestion question in PrepSurvey.details)
                    if (record.finishes[question.id]
                        case final PrepFinishAnswer answer)
                      if (!answer.isEmpty)
                        _Fact(
                          icon: _finishIcon(question.id),
                          label: question.title,
                          value: answer.summary,
                        ),
                ],
              ),
          ],
        ),
        SizedBox(height: sectionGap),
        Text(
          '날짜 안내 테스트',
          style: TextStyle(
            fontSize: 13 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DateTestButton(
              label: '지난 날짜',
              fontScale: fontScale,
              onTap:
                  () => _requestConsult(
                    context,
                    periodStart: DateTime.now().subtract(
                      const Duration(days: 1),
                    ),
                  ),
            ),
            _DateTestButton(
              label: '일주일 이내',
              fontScale: fontScale,
              onTap:
                  () => _requestConsult(
                    context,
                    periodStart: DateTime.now().add(const Duration(days: 3)),
                  ),
            ),
            _DateTestButton(
              label: '여유 있는 날짜',
              fontScale: fontScale,
              onTap:
                  () => _requestConsult(
                    context,
                    periodStart: DateTime.now().add(const Duration(days: 30)),
                  ),
            ),
          ],
        ),
        SizedBox(height: sectionGap),
        Builder(
          builder: (BuildContext context) {
            final SpaceProject? opened = ref
                .watch(spaceBoardProvider)
                .projectForRecord(record.id);
            if (opened != null) {
              return AppButton(
                label: '내 공간에서 보기',
                onPressed: () => context.push(SpaceRoutes.detail(opened.id)),
              );
            }
            return AppButton(
              label: '위 내용으로 상담신청하기',
              onPressed: () => _requestConsult(context),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.placeName,
    required this.address,
    required this.detailAddress,
    required this.area,
    required this.buildingType,
    required this.industry,
    required this.contact,
    required this.fontScale,
    required this.onEdit,
  });

  final String placeName;
  final String address;
  final String detailAddress;
  final String area;
  final String buildingType;
  final String industry;
  final String contact;
  final double fontScale;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '현장',
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                _EditPill(
                  fontScale: fontScale,
                  onTap: onEdit,
                  background: AppColors.background,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              placeName,
              style: TextStyle(
                fontSize: 26 * fontScale,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address,
              style: TextStyle(
                fontSize: 14 * fontScale,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detailAddress,
              style: TextStyle(
                fontSize: 13 * fontScale,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _FactGrid(
              fontScale: fontScale,
              items: [
                _Fact(
                  icon: Icons.square_foot_outlined,
                  label: '평수',
                  value: area,
                ),
                _Fact(
                  icon: Icons.storefront_outlined,
                  label: '공간',
                  value: buildingType,
                ),
                _Fact(
                  icon: Icons.category_outlined,
                  label: '업종',
                  value: industry,
                ),
                _Fact(icon: Icons.phone_outlined, label: '연락처', value: contact),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.items, required this.fontScale});

  final List<_Fact> items;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FactCell(fact: items[i], fontScale: fontScale),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      i + 1 < items.length
                          ? _FactCell(fact: items[i + 1], fontScale: fontScale)
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FactCell extends StatelessWidget {
  const _FactCell({required this.fact, required this.fontScale});

  final _Fact fact;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool empty = fact.value.trim().isEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(fact.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fact.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              empty ? '아직 없어요' : fact.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: empty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool empty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  empty ? '아직 없어요' : value,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color:
                        empty ? AppColors.textSecondary : AppColors.textPrimary,
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

IconData _finishIcon(String id) {
  return switch (id) {
    'signboard' => Icons.storefront_outlined,
    'signage' => Icons.campaign_outlined,
    'lighting' => Icons.lightbulb_outline,
    'facilities' => Icons.plumbing_outlined,
    'floor' => Icons.grid_on_outlined,
    'ceiling' => Icons.roofing_outlined,
    'paint' => Icons.format_paint_outlined,
    _ => Icons.tune_outlined,
  };
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.fontScale,
    required this.onEdit,
    required this.children,
  });

  final String title;
  final double fontScale;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _EditPill(fontScale: fontScale, onTap: onEdit),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _EditPill extends StatelessWidget {
  const _EditPill({
    required this.fontScale,
    required this.onTap,
    this.background = AppColors.background,
  });

  final double fontScale;
  final VoidCallback onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            '수정',
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.label,
    required this.labels,
    required this.emptyLabel,
    required this.fontScale,
    required this.icon,
  });

  final String label;
  final List<String> labels;
  final String emptyLabel;
  final double fontScale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              labels.isEmpty ? '없음' : '${labels.length}',
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (labels.isEmpty)
          Container(
            width: double.infinity,
            height: 112,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              emptyLabel,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool single = labels.length == 1;
              final double tileWidth =
                  single
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  for (final String itemLabel in labels)
                    SizedBox(
                      width: tileWidth,
                      child: _PhotoFrame(
                        label: itemLabel,
                        fontScale: fontScale,
                        icon: icon,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({
    required this.label,
    required this.fontScale,
    required this.icon,
  });

  final String label;
  final double fontScale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.imagePlaceholder,
            ),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _AttachedPhotoBlock extends StatelessWidget {
  const _AttachedPhotoBlock({
    required this.label,
    required this.regions,
    required this.fontScale,
  });

  final String label;
  final List<ShowroomReferenceRegion> regions;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final double pad = ResponsiveSize.subGap(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: pad * 0.5),
            PrepPhotoStrip(regions: regions, fontScale: fontScale),
          ],
        ),
      ),
    );
  }
}

/// 조건에 올린 평면도나 스타일 사진. 화면 폭에 맞춰 한 줄에 보이는 장 수가 달라진다.
class PrepPhotoStrip extends StatelessWidget {
  const PrepPhotoStrip({
    super.key,
    required this.regions,
    required this.fontScale,
    this.onTap,
    this.onDelete,
  });

  final List<ShowroomReferenceRegion> regions;
  final double fontScale;
  final ValueChanged<ShowroomReferenceRegion>? onTap;
  final ValueChanged<ShowroomReferenceRegion>? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool caption = regions.any(
      (ShowroomReferenceRegion region) => region.note.trim().isNotEmpty,
    );
    final AppWindow window = AppWindow.of(context);
    final int visible =
        window.isExpanded
            ? 6
            : window.isMedium
            ? 5
            : 4;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 8;
        final double tile =
            (constraints.maxWidth - gap * (visible - 1)) / visible;
        final double captionHeight = 4 + 13 * fontScale * 1.3 * 2;
        final double height = tile + (caption ? captionHeight : 0);
        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics:
                regions.length > visible
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            itemCount: regions.length,
            separatorBuilder:
                (BuildContext context, int index) => const SizedBox(width: gap),
            itemBuilder: (BuildContext context, int index) {
              final ShowroomReferenceRegion region = regions[index];
              return _ReferenceImageTile(
                region: region,
                width: tile,
                fontScale: fontScale,
                showCaption: caption,
                onTap: onTap == null ? null : () => onTap!(region),
                onDelete: onDelete == null ? null : () => onDelete!(region),
              );
            },
          ),
        );
      },
    );
  }
}

/// 쇼룸에서 넘어온 참고 사례. 상담준비 작성과 저장 내역에서 같이 쓴다.
class ShowroomStyleReferenceTile extends StatelessWidget {
  const ShowroomStyleReferenceTile({
    super.key,
    required this.reference,
    required this.fontScale,
    this.onRegionTap,
    this.onRegionDelete,
    this.inset = false,
  });

  final ShowroomStyleRef reference;
  final double fontScale;
  final ValueChanged<ShowroomReferenceRegion>? onRegionTap;
  final ValueChanged<ShowroomReferenceRegion>? onRegionDelete;
  final bool inset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참고한 쇼룸',
          style: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: inset ? AppColors.background : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: reference.imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0x000B1F38),
                            Color(0x660B1F38),
                            Color(0xE60B1F38),
                          ],
                          stops: <double>[0.35, 0.62, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Text(
                        reference.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22 * fontScale,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          letterSpacing: -0.3,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (reference.regions.isNotEmpty ||
                  reference.aspects.isNotEmpty ||
                  reference.note.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reference.regions.isNotEmpty) ...[
                        _ReferenceImageStrip(
                          regions: reference.regions,
                          fontScale: fontScale,
                          onTap: onRegionTap,
                          onDelete: onRegionDelete,
                        ),
                      ],
                      if (reference.aspects.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final String aspect in reference.aspects)
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    aspect,
                                    style: TextStyle(
                                      fontSize: 12 * fontScale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (reference.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          reference.note.trim(),
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceImageStrip extends StatelessWidget {
  const _ReferenceImageStrip({
    required this.regions,
    required this.fontScale,
    this.onTap,
    this.onDelete,
  });

  final List<ShowroomReferenceRegion> regions;
  final double fontScale;
  final ValueChanged<ShowroomReferenceRegion>? onTap;
  final ValueChanged<ShowroomReferenceRegion>? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool caption = regions.any(
      (ShowroomReferenceRegion region) => region.note.trim().isNotEmpty,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 8;
        final double tile = (constraints.maxWidth - gap * 3) / 4;
        final double height = tile + (caption ? 40 : 0);
        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics:
                regions.length > 4
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            itemCount: regions.length,
            separatorBuilder:
                (BuildContext context, int index) => const SizedBox(width: gap),
            itemBuilder: (BuildContext context, int index) {
              final ShowroomReferenceRegion region = regions[index];
              return _ReferenceImageTile(
                region: region,
                width: tile,
                fontScale: fontScale,
                showCaption: caption,
                onTap: onTap == null ? null : () => onTap!(region),
                onDelete: onDelete == null ? null : () => onDelete!(region),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReferenceImageTile extends StatelessWidget {
  const _ReferenceImageTile({
    required this.region,
    required this.width,
    required this.fontScale,
    required this.showCaption,
    this.onTap,
    this.onDelete,
  });

  final ShowroomReferenceRegion region;
  final double width;
  final double fontScale;
  final bool showCaption;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final String detail = region.note.trim();
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            height: width,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ShowroomReferenceMarkView(
                          imageUrl: region.imageUrl,
                          crop: region.crop,
                          marks: region.marks,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onDelete != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showCaption) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11 * fontScale,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateTestButton extends StatelessWidget {
  const _DateTestButton({
    required this.label,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _areaLabel(String area) {
  if (area.isEmpty) return '미입력';
  if (area == PrepLabels.areaUnknown) return area;
  if (area.endsWith('평') || area.endsWith('㎡')) return area;
  return '$area평';
}

class _ConsultGap {
  const _ConsultGap({
    required this.title,
    required this.body,
    required this.step,
  });

  final String title;
  final String body;
  final int step;
}

_ConsultGap? _consultGap(PrepRecord record) {
  if (record.address.trim().isEmpty) {
    return const _ConsultGap(
      title: '현장주소가 필요해요',
      body: '정식 상담은 공사할 현장의 주소가 정해진 뒤에 시작해요.',
      step: 0,
    );
  }
  if (!record.industryReady) {
    return const _ConsultGap(
      title: '업종을 정해 주세요',
      body: '업종이 아직이면 상담으로 넘기지 않아요. 업종을 고른 뒤에 신청해 주세요.',
      step: 0,
    );
  }
  if (!record.contactReady) {
    return const _ConsultGap(
      title: '연락처가 필요해요',
      body: '담당자가 전화로 상담하려면 연락처가 필요해요.',
      step: 0,
    );
  }
  if (record.workScope.trim().isEmpty) {
    return const _ConsultGap(
      title: '공사 형태를 골라 주세요',
      body: '전체 공사인지 부분 공사인지 골라 주세요.',
      step: 1,
    );
  }
  if (record.workScope == PrepLabels.partialWork &&
      record.workPlace.trim().isEmpty) {
    return const _ConsultGap(
      title: '공사할 곳을 적어 주세요',
      body: '부분 공사라면 어디를 손볼지 적어 주세요.',
      step: 1,
    );
  }
  return null;
}

enum _PrepDateCheck { ok, past, soon }

_PrepDateCheck _checkPrepDate(DateTime? start) {
  if (start == null) return _PrepDateCheck.ok;
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(start.year, start.month, start.day);
  if (day.isBefore(today)) return _PrepDateCheck.past;
  if (day.difference(today).inDays <= 7) return _PrepDateCheck.soon;
  return _PrepDateCheck.ok;
}

Future<bool?> _showDateNotice(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final bool? proceed = await showAppDialog<bool>(
    context: context,
    title: title,
    message: body,
    actions: (BuildContext dialogContext) {
      return [
        AppButton(
          label: confirmLabel,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
        if (cancelLabel != null)
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
      ];
    },
  );
  return proceed;
}
