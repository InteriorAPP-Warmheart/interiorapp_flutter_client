import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';

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
        backgroundColor: const Color(0xFFFCFCFC),
        appBar: AppBar(title: const Text('상담준비')),
        body: Center(
          child: Text(
            '상담준비를 찾을 수 없어요',
            style: TextStyle(fontSize: 16 * fontScale, color: const Color(0xFF1A1A1A)),
          ),
        ),
      );
    }

    return _PrepDetailScaffold(
      record: current,
      onEdit: (int step) => context.push(SpaceRoutes.prepEdit(step), extra: current),
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
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(title: const Text('상담준비')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding.left, subGap, padding.right, subGap),
          child: PrepDetailView(
            record: record,
            onEdit: onEdit,
          ),
        ),
      ),
    );
  }
}

/// 현장, 조건, 첨부를 한 스크롤로 보여 준다.
class PrepDetailView extends StatelessWidget {
  const PrepDetailView({
    super.key,
    required this.record,
    required this.onEdit,
  });

  final PrepRecord record;
  final ValueChanged<int> onEdit;

  Future<void> _requestConsult(BuildContext context, {DateTime? periodStart}) async {
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
    final _PrepDateCheck check = _checkPrepDate(periodStart ?? record.periodStart);
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
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final String fullAddress = record.detailAddress.isEmpty
        ? record.address
        : '${record.address} ${record.detailAddress}';

    return ListView(
      children: [
        _PlaceCard(
          placeName: record.placeName,
          address: fullAddress,
          detailAddress: record.detailAddress.isEmpty ? '상세주소 없음' : record.detailAddress,
          area: _areaLabel(record.area),
          buildingType: record.buildingType,
          industry: record.industry.isEmpty ? '미입력' : record.industry,
          contact: record.contact.isEmpty ? '미입력' : record.contact,
          fontScale: fontScale,
          onEdit: () => onEdit(0),
        ),
        SizedBox(height: sectionGap),
        _ReviewSection(
          title: '조건',
          fontScale: fontScale,
          onEdit: () => onEdit(1),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ValueChip(
                  label: '공사 형태',
                  value: record.workScope.isEmpty ? '미입력' : record.workScope,
                  fontScale: fontScale,
                ),
                _ValueChip(label: '철거 여부', value: record.buildingCondition, fontScale: fontScale),
                _ValueChip(label: '스타일', value: record.style, fontScale: fontScale),
              ],
            ),
            const SizedBox(height: 20),
            _EmphasisLine(label: '예산', value: record.budget, fontScale: fontScale),
            const SizedBox(height: 16),
            _EmphasisLine(label: '기간', value: record.period, fontScale: fontScale),
            if (record.workScope == PrepLabels.partialWork) ...[
              const SizedBox(height: 16),
              _EmphasisLine(
                label: '공사할 곳',
                value: record.workPlace.isEmpty ? '아직 없어요' : record.workPlace,
                fontScale: fontScale,
              ),
            ],
            const SizedBox(height: 20),
            _NoteBlock(
              label: '상담에서 말하고 싶은 점',
              value: record.needs.isEmpty ? '적어 둔 내용이 없어요' : record.needs,
              fontScale: fontScale,
            ),
          ],
        ),
        SizedBox(height: sectionGap),
        _ReviewSection(
          title: '첨부',
          fontScale: fontScale,
          onEdit: () => onEdit(2),
          children: [
            _AttachmentPreview(
              label: '평면도',
              labels: record.floorPlanLabels,
              emptyLabel: '올린 평면도가 없어요',
              fontScale: fontScale,
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 20),
            _AttachmentPreview(
              label: '참고 이미지',
              labels: record.referenceImageLabels,
              emptyLabel: '올린 참고 이미지가 없어요',
              fontScale: fontScale,
              icon: Icons.image_outlined,
            ),
          ],
        ),
        SizedBox(height: sectionGap),
        Text(
          '날짜 안내 테스트',
          style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DateTestButton(
              label: '지난 날짜',
              fontScale: fontScale,
              onTap: () => _requestConsult(context, periodStart: DateTime.now().subtract(const Duration(days: 1))),
            ),
            _DateTestButton(
              label: '일주일 이내',
              fontScale: fontScale,
              onTap: () => _requestConsult(context, periodStart: DateTime.now().add(const Duration(days: 3))),
            ),
            _DateTestButton(
              label: '여유 있는 날짜',
              fontScale: fontScale,
              onTap: () => _requestConsult(context, periodStart: DateTime.now().add(const Duration(days: 30))),
            ),
          ],
        ),
        SizedBox(height: sectionGap),
        ListenableBuilder(
          listenable: SpaceBoard.instance,
          builder: (BuildContext context, Widget? child) {
            final SpaceProject? opened = SpaceBoard.instance.projectForRecord(record.id);
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
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(24),
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
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                _EditPill(
                  fontScale: fontScale,
                  onTap: onEdit,
                  background: const Color(0xFFFFFFFF),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              placeName,
              style: TextStyle(fontSize: 26 * fontScale, fontWeight: FontWeight.w700, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              address,
              style: TextStyle(fontSize: 14 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 2),
            Text(
              detailAddress,
              style: TextStyle(fontSize: 13 * fontScale, color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(value: area, label: '평수', fontScale: fontScale),
                const SizedBox(width: 12),
                _Stat(value: buildingType, label: '공간', fontScale: fontScale),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(value: industry, label: '업종', fontScale: fontScale),
                const SizedBox(width: 12),
                _Stat(value: contact, label: '연락처', fontScale: fontScale),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.fontScale});

  final String value;
  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
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
                    style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w700),
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
    this.background = const Color(0xFFF6F3EE),
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
            style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value, required this.fontScale});

  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label  ',
                style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFFFFFFFF)),
              ),
              TextSpan(
                text: value,
                style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmphasisLine extends StatelessWidget {
  const _EmphasisLine({required this.label, required this.value, required this.fontScale});

  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.w700, height: 1.3),
        ),
      ],
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.label, required this.value, required this.fontScale});

  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 220),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 16 * fontScale, height: 1.6),
              ),
            ],
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
              style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text(
              labels.isEmpty ? '없음' : '${labels.length}',
              style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
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
              color: const Color(0xFFF7F5F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              emptyLabel,
              style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
            ),
          )
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool single = labels.length == 1;
              final double tileWidth = single ? constraints.maxWidth : (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  for (final String itemLabel in labels)
                    SizedBox(
                      width: tileWidth,
                      child: _PhotoFrame(label: itemLabel, fontScale: fontScale, icon: icon),
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
  const _PhotoFrame({required this.label, required this.fontScale, required this.icon});

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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3EFE8), Color(0xFFD9D1C7)],
              ),
            ),
            child: Icon(icon, color: const Color(0xFF8C7358)),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w600, height: 1.3),
          ),
        ],
      ],
    );
  }
}

class _DateTestButton extends StatelessWidget {
  const _DateTestButton({required this.label, required this.fontScale, required this.onTap});

  final String label;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1A1A1A),
        side: const BorderSide(color: Color(0xFF1A1A1A)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      child: Text(label, style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700)),
    );
  }
}

String _areaLabel(String area) {
  if (area.isEmpty) return '미입력';
  if (area == PrepLabels.areaUnknown) return area;
  return '$area평';
}

class _ConsultGap {
  const _ConsultGap({required this.title, required this.body, required this.step});

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
  if (record.workScope == PrepLabels.partialWork && record.workPlace.trim().isEmpty) {
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
