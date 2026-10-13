import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/kakao_address_search_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';

/// 상담준비 작성. 현장, 조건, 첨부 순서로 나눈다.
class PrepCreateScreen extends StatefulWidget {
  const PrepCreateScreen({super.key, this.initial, this.initialStep = 0});

  final PrepRecord? initial;
  final int initialStep;

  @override
  State<PrepCreateScreen> createState() => _PrepCreateScreenState();
}

class _PrepCreateScreenState extends State<PrepCreateScreen> {
  static const List<String> _steps = ['현장', '조건', '첨부'];
  static const String _commercial = '상가';
  static const String _residential = '주거';
  static const List<String> _styles = ['모던', '내추럴', '미니멀', '북유럽', '빈티지', '아직 모르겠어요'];
  static const String _industryOther = '기타';
  static const List<String> _industries = [
    '카페',
    '식당',
    '베이커리',
    '미용',
    '학원',
    '병원',
    '사무실',
    '소매',
    _industryOther,
    PrepLabels.industryUndecided,
  ];
  static const List<String> _workScopes = [PrepLabels.fullWork, PrepLabels.partialWork];
  static const List<String> _periods = ['1개월 이내', '1개월', '2개월', PrepLabels.periodUndecided];
  static const List<String> _buildingConditions = ['전체 철거', '부분 철거', '철거 없음'];

  final TextEditingController _address = TextEditingController();
  final TextEditingController _detailAddress = TextEditingController();
  final TextEditingController _buildingName = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _budget = TextEditingController();
  final TextEditingController _needs = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _industryNote = TextEditingController();
  final TextEditingController _workPlace = TextEditingController();

  int _step = 0;
  bool _saved = false;
  String _recordId = '';
  final List<TextEditingController> _floorPlanLabels = [];
  final List<TextEditingController> _referenceImageLabels = [];
  String? _industry;
  String? _workScope;
  String? _buildingCondition;
  String? _style;
  String? _period;
  bool _areaUnknown = false;
  bool _budgetUndecided = false;
  DateTimeRange? _targetRange;
  String? _error;

  @override
  void initState() {
    super.initState();
    final PrepRecord? initial = widget.initial;
    if (initial == null) return;
    _recordId = initial.id;
    _address.text = initial.address;
    _detailAddress.text = initial.detailAddress;
    _buildingName.text = initial.placeName;
    _areaUnknown = initial.area == PrepLabels.areaUnknown;
    _area.text = _areaUnknown ? '' : initial.area;
    _budgetUndecided = initial.budget == PrepLabels.budgetUndecided;
    _budget.text = _budgetUndecided ? '' : initial.budget;
    _needs.text = initial.needs;
    _contact.text = _formatKoreanMobile(initial.contact);
    final String savedIndustry = initial.industry;
    if (savedIndustry.isEmpty) {
      _industry = null;
    } else if (_industries.contains(savedIndustry)) {
      _industry = savedIndustry;
    } else {
      _industry = _industryOther;
      _industryNote.text = savedIndustry;
    }
    _workScope = _workScopes.contains(initial.workScope)
        ? initial.workScope
        : initial.workScope == '전체 인테리어'
            ? PrepLabels.fullWork
            : null;
    _workPlace.text = initial.workPlace;
    _buildingCondition = initial.buildingCondition;
    _style = initial.style;
    if (initial.periodStart != null && initial.periodEnd != null) {
      _targetRange = DateTimeRange(start: initial.periodStart!, end: initial.periodEnd!);
    } else {
      _period = initial.period;
    }
    for (final String label in initial.floorPlanLabels) {
      _floorPlanLabels.add(TextEditingController(text: label));
    }
    for (final String label in initial.referenceImageLabels) {
      _referenceImageLabels.add(TextEditingController(text: label));
    }
    _step = widget.initialStep.clamp(0, _steps.length - 1);
  }

  @override
  void dispose() {
    _address.dispose();
    _detailAddress.dispose();
    _buildingName.dispose();
    _area.dispose();
    _budget.dispose();
    _needs.dispose();
    _contact.dispose();
    _industryNote.dispose();
    _workPlace.dispose();
    for (final TextEditingController controller in _floorPlanLabels) {
      controller.dispose();
    }
    for (final TextEditingController controller in _referenceImageLabels) {
      controller.dispose();
    }
    super.dispose();
  }

  void _next() {
    final String? error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (_step >= _steps.length - 1) {
      if (_recordId.isEmpty) _recordId = 'consult-${DateTime.now().microsecondsSinceEpoch}';
      SpaceBoard.instance.saveConsult(_currentRecord);
    }
    setState(() {
      _error = null;
      if (_step < _steps.length - 1) {
        _step += 1;
      } else {
        _saved = true;
      }
    });
  }

  String? _validate() {
    if (_step == 0) {
      if (_address.text.trim().isEmpty) return '주소를 검색해 주세요';
      if (_buildingName.text.trim().isEmpty) return '건물 이름을 적어 주세요';
      if (_industry == null) return '업종을 골라 주세요';
      if (_industry == _industryOther && _industryNote.text.trim().isEmpty) return '업종을 적어 주세요';
    }
    if (_step == 1) {
      if (!_areaUnknown && _area.text.trim().isEmpty) return '평수를 적거나, 정확히 모른다고 골라 주세요';
      if (_workScope == null) return '공사 형태를 골라 주세요';
      if (_workScope == PrepLabels.partialWork && _workPlace.text.trim().isEmpty) {
        return '부분공사로 손볼 곳을 적어 주세요';
      }
      if (_buildingCondition == null) return '철거 여부를 골라 주세요';
      if (_style == null) return '원하는 스타일을 골라 주세요';
      if (!_budgetUndecided && _budget.text.trim().isEmpty) return '예산을 적거나, 아직 정하지 못했다고 골라 주세요';
      if (_period == null && _targetRange == null) return '기간을 골라 주세요';
    }
    return null;
  }

  Future<void> _pickTargetRange() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime lastDate = DateTime(today.year + 3);
    final DateTimeRange? initial = _targetRange;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: today,
      lastDate: lastDate,
      helpText: '공사 기간',
      cancelText: '취소',
      saveText: '선택',
      fieldStartLabelText: '시작',
      fieldEndLabelText: '종료',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _targetRange = picked;
      _period = null;
    });
  }

  PrepRecord get _currentRecord {
    final DateTimeRange? range = _targetRange;
    return PrepRecord(
      id: _recordId,
      placeName: _buildingName.text.trim(),
      buildingType: _commercial,
      address: _address.text.trim(),
      detailAddress: _detailAddress.text.trim(),
      area: _areaUnknown ? PrepLabels.areaUnknown : _area.text.trim(),
      buildingCondition: _buildingCondition ?? '',
      style: _style ?? '',
      budget: _budgetUndecided ? PrepLabels.budgetUndecided : _budget.text.trim(),
      period: range != null ? _formatDateRange(range) : (_period ?? ''),
      periodStart: range?.start,
      periodEnd: range?.end,
      needs: _needs.text.trim(),
      floorPlanLabels: [for (final TextEditingController item in _floorPlanLabels) item.text.trim()],
      referenceImageLabels: [for (final TextEditingController item in _referenceImageLabels) item.text.trim()],
      industry: _industry == _industryOther ? _industryNote.text.trim() : (_industry ?? ''),
      workScope: _workScope ?? '',
      contact: _contact.text.trim(),
      workPlace: _workScope == PrepLabels.partialWork ? _workPlace.text.trim() : '',
    );
  }

  Future<void> _searchAddress() async {
    final String? picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const KakaoAddressSearchScreen()),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    setState(() => _address.text = picked);
  }

  Future<void> _importTrade() async {
    final TradeCandidate? picked = await showAppBottomSheet<TradeCandidate>(
      context: context,
      title: '후보지 불러오기',
      message: '주소, 업종, 이름을 상담준비에 채워요.',
      size: AppBottomSheetSize.compact,
      child: Builder(
        builder: (BuildContext sheetContext) {
          return ListView(
            children: [
              for (final TradeCandidate candidate in SpaceBoard.instance.trades)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(candidate.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${candidate.industry} · ${candidate.address}'),
                  onTap: () => Navigator.of(sheetContext).pop(candidate),
                ),
            ],
          );
        },
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _buildingName.text = picked.name;
      _address.text = picked.address;
      _detailAddress.text = picked.detailAddress;
      _areaUnknown = picked.area == PrepLabels.areaUnknown;
      _area.text = _areaUnknown || picked.area.isEmpty ? '' : picked.area;
      if (picked.area.isEmpty) _areaUnknown = false;
      if (_industries.contains(picked.industry)) {
        _industry = picked.industry;
        _industryNote.clear();
      } else if (picked.industry.isNotEmpty) {
        _industry = _industryOther;
        _industryNote.text = picked.industry;
      }
      if (picked.reason.trim().isNotEmpty && _needs.text.trim().isEmpty) {
        _needs.text = picked.toConsultSeed().needs;
      }
    });
  }

  Future<void> _onSpaceKind(String value) async {
    if (value != _residential) return;
    await showAppDialog<void>(
      context: context,
      title: '주거는 아직이에요',
      message: '지금은 상가 공간만 상담준비를 진행할 수 있어요.',
      actions: (BuildContext dialogContext) => [
        AppButton(label: '확인', onPressed: () => Navigator.of(dialogContext).pop()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double subGap = ResponsiveSize.subGap(context);

    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('상담준비')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding.left, subGap, padding.right, subGap),
          child: _saved
              ? PrepDetailView(
                  record: _currentRecord,
                  onEdit: (int step) => setState(() {
                    _saved = false;
                    _step = step;
                    _error = null;
                  }),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StepHeader(steps: _steps, index: _step, fontScale: fontScale),
                    SizedBox(height: sectionGap),
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(bottom: keyboardInset),
                        children: [
                          if (_step == 0)
                            _SiteStep(
                              fontScale: fontScale,
                              subGap: subGap,
                              sectionGap: sectionGap,
                              address: _address,
                              detailAddress: _detailAddress,
                              buildingName: _buildingName,
                              onSearchAddress: _searchAddress,
                              industry: _industry,
                              industries: _industries,
                              industryNote: _industryNote,
                              contact: _contact,
                              onIndustry: (String value) => setState(() => _industry = value),
                              onSpaceKind: _onSpaceKind,
                              onImport: SpaceBoard.instance.trades.isEmpty ? null : _importTrade,
                            ),
                          if (_step == 1)
                            _NeedsStep(
                              fontScale: fontScale,
                              subGap: subGap,
                              sectionGap: sectionGap,
                              styles: _styles,
                              periods: _periods,
                              buildingConditions: _buildingConditions,
                              workScopes: _workScopes,
                              style: _style,
                              period: _period,
                              buildingCondition: _buildingCondition,
                              workScope: _workScope,
                              areaUnknown: _areaUnknown,
                              budgetUndecided: _budgetUndecided,
                              workPlace: _workPlace,
                              targetRange: _targetRange,
                              area: _area,
                              budget: _budget,
                              needs: _needs,
                              onStyle: (String value) => setState(() => _style = value),
                              onBuildingCondition: (String value) => setState(() => _buildingCondition = value),
                              onWorkScope: (String value) => setState(() => _workScope = value),
                              onAreaUnknown: () => setState(() {
                                _areaUnknown = !_areaUnknown;
                                if (_areaUnknown) _area.clear();
                              }),
                              onAreaChanged: (String value) {
                                if (value.trim().isNotEmpty && _areaUnknown) {
                                  setState(() => _areaUnknown = false);
                                }
                              },
                              onBudgetUndecided: () => setState(() {
                                _budgetUndecided = !_budgetUndecided;
                                if (_budgetUndecided) _budget.clear();
                              }),
                              onBudgetChanged: (String value) {
                                if (value.trim().isNotEmpty && _budgetUndecided) {
                                  setState(() => _budgetUndecided = false);
                                }
                              },
                              onPeriod: (String value) => setState(() {
                                _period = value;
                                _targetRange = null;
                              }),
                              onPickDate: _pickTargetRange,
                              onClearDate: () => setState(() => _targetRange = null),
                            ),
                          if (_step == 2)
                            _FloorPlanStep(
                              fontScale: fontScale,
                              subGap: subGap,
                              sectionGap: sectionGap,
                              floorPlanLabels: _floorPlanLabels,
                              referenceImageLabels: _referenceImageLabels,
                              onAddFloorPlan: () => setState(() => _floorPlanLabels.add(TextEditingController())),
                              onAddReferenceImage: () => setState(() => _referenceImageLabels.add(TextEditingController())),
                              onRemoveFloorPlan: (int index) => setState(() => _floorPlanLabels.removeAt(index).dispose()),
                              onRemoveReferenceImage: (int index) =>
                                  setState(() => _referenceImageLabels.removeAt(index).dispose()),
                            ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(fontSize: 13 * fontScale, color: const Color(0xFFB42318)),
                      ),
                      SizedBox(height: subGap),
                    ],
                    AppButton(
                      label: _step == _steps.length - 1 ? '상담준비 저장' : '다음',
                      onPressed: _next,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.steps, required this.index, required this.fontScale});

  final List<String> steps;
  final int index;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= index ? const Color(0xFF1A1A1A) : const Color(0xFFE4E4E4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: i == index ? FontWeight.w700 : FontWeight.w500,
                    color: i == index
                        ? const Color(0xFF1A1A1A)
                        : i < index
                            ? const Color(0xFF6E6E6E)
                            : const Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SiteStep extends StatelessWidget {
  const _SiteStep({
    required this.fontScale,
    required this.subGap,
    required this.sectionGap,
    required this.address,
    required this.detailAddress,
    required this.buildingName,
    required this.industry,
    required this.industries,
    required this.industryNote,
    required this.contact,
    required this.onIndustry,
    required this.onSpaceKind,
    required this.onSearchAddress,
    this.onImport,
  });

  final double fontScale;
  final double subGap;
  final double sectionGap;
  final TextEditingController address;
  final TextEditingController detailAddress;
  final TextEditingController buildingName;
  final String? industry;
  final List<String> industries;
  final TextEditingController industryNote;
  final TextEditingController contact;
  final ValueChanged<String> onIndustry;
  final ValueChanged<String> onSpaceKind;
  final VoidCallback onSearchAddress;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(
          title: '어느 공간을 정리할까요',
          body: '상가 공간을 기준으로 주소와 업종, 연락처를 적어 두면 상담으로 이어갈 수 있어요. 업종을 아직 모르면 그렇게 골라도 돼요.',
          fontScale: fontScale,
        ),
        if (onImport != null) ...[
          SizedBox(height: subGap),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onImport,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A1A),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '상권 후보지에서 불러오기',
                style: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
        SizedBox(height: sectionGap),
        _FieldLabel(label: '공간', fontScale: fontScale),
        SizedBox(height: subGap),
        _OptionSegment(
          values: const [_PrepCreateScreenState._commercial, _PrepCreateScreenState._residential],
          selected: _PrepCreateScreenState._commercial,
          fontScale: fontScale,
          onSelected: onSpaceKind,
        ),
        SizedBox(height: subGap),
        Text(
          '지금은 상가 공간만 진행할 수 있어요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '주소', fontScale: fontScale),
        SizedBox(height: subGap),
        _AddressSearchField(
          address: address.text,
          fontScale: fontScale,
          onTap: onSearchAddress,
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '상세주소', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(controller: detailAddress, hint: '건물 이름, 동, 호수'),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '공간 이름', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(controller: buildingName, hint: '예: 성수 사옥, 동탄 고기집'),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '업종', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '자주 있는 업종만 골랐어요. 없으면 기타에 직접 적어 주세요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: industries,
          selected: industry,
          fontScale: fontScale,
          onSelected: onIndustry,
        ),
        if (industry == _PrepCreateScreenState._industryOther) ...[
          SizedBox(height: subGap),
          _PrepTextField(controller: industryNote, hint: '예: 복지시설, 창고, 공방'),
        ],
        SizedBox(height: sectionGap),
        _FieldLabel(label: '연락처', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '하이픈 없이 숫자만 적어 주세요. 010-0000-0000 형태로 보여 드려요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: subGap),
        _PrepTextField(
          controller: contact,
          hint: '01012345678',
          keyboardType: TextInputType.number,
          inputFormatters: const [_KoreanMobileFormatter()],
        ),
        const SizedBox(height: 88),
      ],
    );
  }
}

class _OptionSegment extends StatelessWidget {
  const _OptionSegment({
    required this.values,
    required this.selected,
    required this.fontScale,
    required this.onSelected,
  });

  final List<String> values;
  final String? selected;
  final double fontScale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final int index = selected == null ? -1 : values.indexOf(selected!);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth / values.length;
            return SizedBox(
              height: 48,
              child: Stack(
                children: [
                  if (index >= 0)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      left: width * index,
                      top: 0,
                      bottom: 0,
                      width: width,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      for (final String value in values)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(value),
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 15 * fontScale,
                                  fontWeight: FontWeight.w700,
                                  color: value == selected ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FloorPlanStep extends StatelessWidget {
  const _FloorPlanStep({
    required this.fontScale,
    required this.subGap,
    required this.sectionGap,
    required this.floorPlanLabels,
    required this.referenceImageLabels,
    required this.onAddFloorPlan,
    required this.onAddReferenceImage,
    required this.onRemoveFloorPlan,
    required this.onRemoveReferenceImage,
  });

  final double fontScale;
  final double subGap;
  final double sectionGap;
  final List<TextEditingController> floorPlanLabels;
  final List<TextEditingController> referenceImageLabels;
  final VoidCallback onAddFloorPlan;
  final VoidCallback onAddReferenceImage;
  final ValueChanged<int> onRemoveFloorPlan;
  final ValueChanged<int> onRemoveReferenceImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(
          title: '첨부가 있으면 올려 주세요',
          body: '여러 장 올릴 수 있어요. 어떤 도면인지, 어떤 사진인지는 라벨로 적어도 되고, 비워 둬도 돼요.',
          fontScale: fontScale,
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '평면도', fontScale: fontScale),
        SizedBox(height: subGap),
        _AttachmentRow(
          label: '평면도 올리기',
          count: floorPlanLabels.length,
          fontScale: fontScale,
          onAdd: onAddFloorPlan,
        ),
        for (var i = 0; i < floorPlanLabels.length; i++) ...[
          SizedBox(height: subGap),
          _LabeledAttachment(
            controller: floorPlanLabels[i],
            hint: '예: 1층, 주방',
            fontScale: fontScale,
            onRemove: () => onRemoveFloorPlan(i),
          ),
        ],
        SizedBox(height: sectionGap),
        _FieldLabel(label: '참고 이미지', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '참고할 사진이 있으면 올려 두세요. 없어도 돼요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF6E6E6E)),
        ),
        SizedBox(height: subGap),
        _AttachmentRow(
          label: '참고 이미지 올리기',
          count: referenceImageLabels.length,
          fontScale: fontScale,
          onAdd: onAddReferenceImage,
        ),
        for (var i = 0; i < referenceImageLabels.length; i++) ...[
          SizedBox(height: subGap),
          _LabeledAttachment(
            controller: referenceImageLabels[i],
            hint: '예: 거실 예상',
            fontScale: fontScale,
            onRemove: () => onRemoveReferenceImage(i),
          ),
        ],
      ],
    );
  }
}

class _LabeledAttachment extends StatelessWidget {
  const _LabeledAttachment({
    required this.controller,
    required this.hint,
    required this.fontScale,
    required this.onRemove,
  });

  final TextEditingController controller;
  final String hint;
  final double fontScale;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: const SizedBox(
            width: 96,
            height: 72,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF6F3EE), Color(0xFFE7E1D8)],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PrepTextField(controller: controller, hint: hint),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close, size: 18, color: Color(0xFF8C7358)),
        ),
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.label,
    required this.count,
    required this.fontScale,
    required this.onAdd,
  });

  final String label;
  final int count;
  final double fontScale;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bool attached = count > 0;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: attached ? const Color(0xFFF6F3EE) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: attached ? const Color(0xFF8C7358) : const Color(0xFFE4E4E4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      attached ? Icons.check_circle_outline : Icons.upload_file_outlined,
                      size: 18,
                      color: const Color(0xFF8C7358),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attached ? '첨부됨' : label,
                        style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _AttachmentCount(count: count, fontScale: fontScale),
      ],
    );
  }
}

class _AttachmentCount extends StatelessWidget {
  const _AttachmentCount({required this.count, required this.fontScale});

  final int count;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count개',
            style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFF8C7358)),
          ),
        ],
      ),
    );
  }
}

String _formatDateRange(DateTimeRange range) {
  final DateTime start = range.start;
  final DateTime end = range.end;
  final String startLabel = '${start.year}년 ${start.month}월 ${start.day}일';
  final String endLabel = start.year == end.year
      ? '${end.month}월 ${end.day}일'
      : '${end.year}년 ${end.month}월 ${end.day}일';
  return '$startLabel – $endLabel';
}

class _NeedsStep extends StatelessWidget {
  const _NeedsStep({
    required this.fontScale,
    required this.subGap,
    required this.sectionGap,
    required this.styles,
    required this.periods,
    required this.buildingConditions,
    required this.workScopes,
    required this.style,
    required this.period,
    required this.buildingCondition,
    required this.workScope,
    required this.areaUnknown,
    required this.budgetUndecided,
    required this.workPlace,
    required this.targetRange,
    required this.area,
    required this.budget,
    required this.needs,
    required this.onStyle,
    required this.onBuildingCondition,
    required this.onWorkScope,
    required this.onAreaUnknown,
    required this.onAreaChanged,
    required this.onBudgetUndecided,
    required this.onBudgetChanged,
    required this.onPeriod,
    required this.onPickDate,
    required this.onClearDate,
  });

  final double fontScale;
  final double subGap;
  final double sectionGap;
  final List<String> styles;
  final List<String> periods;
  final List<String> buildingConditions;
  final List<String> workScopes;
  final String? style;
  final String? period;
  final String? buildingCondition;
  final String? workScope;
  final bool areaUnknown;
  final bool budgetUndecided;
  final TextEditingController workPlace;
  final DateTimeRange? targetRange;
  final TextEditingController area;
  final TextEditingController budget;
  final TextEditingController needs;
  final ValueChanged<String> onStyle;
  final ValueChanged<String> onBuildingCondition;
  final ValueChanged<String> onWorkScope;
  final VoidCallback onAreaUnknown;
  final ValueChanged<String> onAreaChanged;
  final VoidCallback onBudgetUndecided;
  final ValueChanged<String> onBudgetChanged;
  final ValueChanged<String> onPeriod;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    final String dateLabel = targetRange == null ? '기간 상세 지정' : _formatDateRange(targetRange!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(
          title: '원하는 조건을 적어 주세요',
          body: '모르는 항목은 그대로 두어도 돼요. 상담에서 이어서 확인해요.',
          fontScale: fontScale,
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '공사 형태', fontScale: fontScale),
        SizedBox(height: subGap),
        _OptionSegment(
          values: workScopes,
          selected: workScope,
          fontScale: fontScale,
          onSelected: onWorkScope,
        ),
        if (workScope == PrepLabels.partialWork) ...[
          SizedBox(height: subGap),
          Text(
            '주방, 홀처럼 손볼 곳을 간단히 적어 주세요.',
            style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
          ),
          SizedBox(height: subGap),
          _PrepTextField(controller: workPlace, hint: '예: 주방, 홀', maxLines: 2),
        ],
        SizedBox(height: sectionGap),
        _FieldLabel(label: '평수', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(
          controller: area,
          hint: '예: 32',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onAreaChanged,
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: const [PrepLabels.areaUnknown],
          selected: areaUnknown ? PrepLabels.areaUnknown : null,
          fontScale: fontScale,
          onSelected: (_) => onAreaUnknown(),
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '철거 여부', fontScale: fontScale),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: buildingConditions,
          selected: buildingCondition,
          fontScale: fontScale,
          onSelected: onBuildingCondition,
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '원하는 스타일', fontScale: fontScale),
        SizedBox(height: subGap),
        _ChoiceWrap(values: styles, selected: style, fontScale: fontScale, onSelected: onStyle),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '예산', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(controller: budget, hint: '예: 3,000만 원 (대략적으로도 돼요)', onChanged: onBudgetChanged),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: const [PrepLabels.budgetUndecided],
          selected: budgetUndecided ? PrepLabels.budgetUndecided : null,
          fontScale: fontScale,
          onSelected: (_) => onBudgetUndecided(),
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '기간', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '대략 고르거나, 시작과 끝 날짜로 기간을 지정할 수 있어요. 아직 정하지 못했어도 돼요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(values: periods, selected: period, fontScale: fontScale, onSelected: onPeriod),
        SizedBox(height: subGap),
        _DatePickField(
          label: dateLabel,
          selected: targetRange != null,
          fontScale: fontScale,
          onTap: onPickDate,
          onClear: onClearDate,
        ),
        SizedBox(height: sectionGap),
        _FieldLabel(label: '상담에서 말하고 싶은 점', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(controller: needs, hint: '예: 주방을 넓히고, 수납을 늘리고 싶어요', maxLines: 4),
        const SizedBox(height: 88),
      ],
    );
  }
}

class _DatePickField extends StatelessWidget {
  const _DatePickField({
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? const Color(0xFF1A1A1A) : const Color(0xFFE4E4E4)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF8C7358),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? const Color(0xFF1A1A1A) : const Color(0xFFB0B0B0),
                  ),
                ),
              ),
              if (selected)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF8C7358)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.body, required this.fontScale});

  final String title;
  final String body;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22 * fontScale, fontWeight: FontWeight.w700, height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(fontSize: 14 * fontScale, height: 1.4, color: const Color(0xFF6E6E6E)),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.fontScale});

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
    );
  }
}

class _AddressSearchField extends StatelessWidget {
  const _AddressSearchField({
    required this.address,
    required this.fontScale,
    required this.onTap,
  });

  final String address;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool empty = address.isEmpty;

    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  empty ? '주소 검색' : address,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    color: empty ? const Color(0xFFB0B0B0) : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const Icon(Icons.search, color: Color(0xFF8C7358)),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatKoreanMobile(String raw) {
  final String digits = raw.replaceAll(RegExp(r'\D'), '');
  final String clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
  if (clipped.length <= 3) return clipped;
  if (clipped.length <= 7) return '${clipped.substring(0, 3)}-${clipped.substring(3)}';
  return '${clipped.substring(0, 3)}-${clipped.substring(3, 7)}-${clipped.substring(7)}';
}

class _KoreanMobileFormatter extends TextInputFormatter {
  const _KoreanMobileFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var digitCursor = _digitsBefore(newValue.text, newValue.selection.extentOffset);
    final String oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    final bool removedSeparatorOnly = digits == oldDigits && newValue.text.length < oldValue.text.length;
    if (removedSeparatorOnly && digitCursor > 0) {
      final int removeAt = digitCursor - 1;
      digits = digits.substring(0, removeAt) + digits.substring(removeAt + 1);
      digitCursor = removeAt;
    }
    if (digits.length > 11) digits = digits.substring(0, 11);
    digitCursor = digitCursor.clamp(0, digits.length);
    final String formatted = _formatKoreanMobile(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: _offsetAfterDigits(formatted, digitCursor)),
    );
  }

  static int _digitsBefore(String text, int offset) {
    final int end = offset.clamp(0, text.length);
    return text.substring(0, end).replaceAll(RegExp(r'\D'), '').length;
  }

  static int _offsetAfterDigits(String formatted, int digitCount) {
    if (digitCount <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      final int code = formatted.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        seen++;
        if (seen == digitCount) return i + 1;
      }
    }
    return formatted.length;
  }
}

class _PrepTextField extends StatelessWidget {
  const _PrepTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 15 * fontScale),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 15 * fontScale, color: const Color(0xFFB0B0B0)),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.fontScale,
    required this.onSelected,
  });

  final List<String> values;
  final String? selected;
  final double fontScale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String value in values)
          ChoiceChip(
            label: Text(value),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
            labelStyle: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w600,
              color: selected == value ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
            ),
            selectedColor: const Color(0xFF111111),
            backgroundColor: const Color(0xFFFFFFFF),
            side: BorderSide(
              color: selected == value ? const Color(0xFF111111) : const Color(0xFFE4E4E4),
            ),
            showCheckmark: false,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
          ),
      ],
    );
  }
}

