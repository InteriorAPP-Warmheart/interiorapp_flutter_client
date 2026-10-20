import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/kakao_address_search_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_reference_pick.dart';

/// 상담준비 작성. 현장, 조건 순서로 나눈다.
class PrepCreateScreen extends StatefulWidget {
  const PrepCreateScreen({super.key, this.initial, this.initialStep = 0});

  final PrepRecord? initial;
  final int initialStep;

  @override
  State<PrepCreateScreen> createState() => _PrepCreateScreenState();
}

class _FormAnchors {
  final GlobalKey address = GlobalKey();
  final GlobalKey placeName = GlobalKey();
  final GlobalKey industry = GlobalKey();
  final GlobalKey workScope = GlobalKey();
  final GlobalKey area = GlobalKey();
  final GlobalKey demolition = GlobalKey();
  final GlobalKey style = GlobalKey();
  final GlobalKey budget = GlobalKey();
  final GlobalKey period = GlobalKey();
  final GlobalKey contact = GlobalKey();
  final GlobalKey needs = GlobalKey();
}

class _FieldIssue {
  const _FieldIssue(this.message, this.anchor);

  final String message;
  final GlobalKey anchor;
}

class _PrepCreateScreenState extends State<PrepCreateScreen> with TickerProviderStateMixin {
  static const List<String> _steps = ['현장', '조건'];
  static const String _commercial = '상가';
  static const String _residential = '주거';
  static final List<String> _styles = [
    for (final StyleMoodCard card in styleMoodCards) card.title,
  ];
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
  static const List<String> _workScopes = [
    PrepLabels.fullWork,
    PrepLabels.partialWork,
  ];
  static const List<String> _periods = [
    '1개월 이내',
    '1개월',
    '2개월',
    PrepLabels.periodUndecided,
  ];
  static const List<String> _buildingConditions = ['전체 철거', '부분 철거', '철거 없음', '상담필요'];

  final TextEditingController _address = TextEditingController();
  final TextEditingController _detailAddress = TextEditingController();
  final TextEditingController _buildingName = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _budget = TextEditingController();
  final TextEditingController _needs = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _industryNote = TextEditingController();
  final TextEditingController _styleNote = TextEditingController();
  final TextEditingController _workPlace = TextEditingController();
  final ScrollController _formScroll = ScrollController();

  int _step = 0;
  bool _saved = false;
  String _recordId = '';
  final List<ShowroomReferenceRegion> _floorPlans = <ShowroomReferenceRegion>[];
  final List<ShowroomReferenceRegion> _stylePhotos = <ShowroomReferenceRegion>[];
  List<String> _legacyFloorLabels = const <String>[];
  List<String> _legacyStyleLabels = const <String>[];
  String? _industry;
  String? _workScope = PrepLabels.fullWork;
  String? _buildingCondition;
  String? _style;
  String? _period;
  bool _areaUnknown = false;
  _AreaUnit _areaUnit = _AreaUnit.pyeong;
  bool _budgetUndecided = false;
  DateTimeRange? _targetRange;
  String? _error;
  GlobalKey? _errorAnchor;
  bool? _errorAbove;
  ShowroomStyleRef? _styleRef;
  final _FormAnchors _anchors = _FormAnchors();
  late final AnimationController _stepMotion;
  int _stepDirection = 1;

  @override
  void initState() {
    super.initState();
    _stepMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..value = 1;
    _formScroll.addListener(_onFormScroll);
    final PrepRecord? initial = widget.initial;
    if (initial == null) return;
    _recordId = initial.id;
    _styleRef = initial.styleRef;
    _address.text = initial.address;
    _detailAddress.text = initial.detailAddress;
    _buildingName.text = initial.placeName;
    _areaUnknown = initial.area == PrepLabels.areaUnknown;
    _areaUnit = _areaUnitOf(initial.area);
    _area.text = _areaUnknown ? '' : _areaNumber(initial.area);
    _budgetUndecided = initial.budget == PrepLabels.budgetUndecided;
    _budget.text = _budgetUndecided ? '' : _budgetFieldText(initial.budget);
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
    _workScope =
        _workScopes.contains(initial.workScope)
            ? initial.workScope
            : PrepLabels.fullWork;
    _workPlace.text = initial.workPlace;
    _buildingCondition = initial.buildingCondition;
    final String savedStyle = initial.style;
    final int styleSplit = savedStyle.indexOf(' · ');
    if (styleSplit >= 0) {
      final String mood = savedStyle.substring(0, styleSplit);
      if (_styles.contains(mood)) {
        _style = mood;
        _styleNote.text = savedStyle.substring(styleSplit + 3);
      } else {
        _styleNote.text = savedStyle;
      }
    } else if (_styles.contains(savedStyle)) {
      _style = savedStyle;
    } else if (savedStyle.isNotEmpty) {
      _styleNote.text = savedStyle;
    }
    if (initial.periodStart != null && initial.periodEnd != null) {
      _targetRange = DateTimeRange(
        start: initial.periodStart!,
        end: initial.periodEnd!,
      );
    } else {
      _period = initial.period;
    }
    _floorPlans.addAll(initial.floorPlans);
    _stylePhotos.addAll(initial.stylePhotos);
    _legacyFloorLabels = initial.floorPlanLabels;
    _legacyStyleLabels = initial.referenceImageLabels;
    _step = widget.initialStep.clamp(0, _steps.length - 1);
  }

  @override
  void dispose() {
    _stepMotion.dispose();
    _formScroll.removeListener(_onFormScroll);
    _formScroll.dispose();
    _address.dispose();
    _detailAddress.dispose();
    _buildingName.dispose();
    _area.dispose();
    _budget.dispose();
    _needs.dispose();
    _contact.dispose();
    _industryNote.dispose();
    _styleNote.dispose();
    _workPlace.dispose();
    super.dispose();
  }

  void _next() {
    final _FieldIssue? issue = _validate();
    if (issue != null) {
      _showIssue(issue);
      return;
    }
    if (_step >= _steps.length - 1) {
      if (_recordId.isEmpty)
        _recordId = 'consult-${DateTime.now().microsecondsSinceEpoch}';
      SpaceBoard.instance.saveConsult(_currentRecord);
      setState(() {
        _error = null;
        _errorAnchor = null;
        _saved = true;
      });
      return;
    }
    setState(() {
      _error = null;
      _errorAnchor = null;
      _stepDirection = 1;
      _step += 1;
    });
    _stepMotion.forward(from: 0);
    _scrollFormToTop();
  }

  void _scrollFormToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_formScroll.hasClients) return;
      _formScroll.jumpTo(0);
    });
  }

  _FieldIssue? _validate() {
    if (_step == 0) {
      if (_address.text.trim().isEmpty) return _FieldIssue('주소를 검색해 주세요', _anchors.address);
      if (_detailAddress.text.trim().isEmpty) return _FieldIssue('상세주소를 적어 주세요', _anchors.address);
      if (_buildingName.text.trim().isEmpty) return _FieldIssue('공간 이름을 적어 주세요', _anchors.placeName);
      if (_industry == null) return _FieldIssue('업종을 골라 주세요', _anchors.industry);
      if (_industry == _industryOther && _industryNote.text.trim().isEmpty) {
        return _FieldIssue('업종을 적어 주세요', _anchors.industry);
      }
      final int contactDigits = _contact.text.replaceAll(RegExp(r'\D'), '').length;
      if (contactDigits == 0) return _FieldIssue('연락처를 적어 주세요', _anchors.contact);
      if (contactDigits < 10) return _FieldIssue('연락처를 다시 확인해 주세요', _anchors.contact);
    }
    if (_step == 1) {
      if (_workScope == null) return _FieldIssue('공사 형태를 골라 주세요', _anchors.workScope);
      if (_workScope == PrepLabels.partialWork && _workPlace.text.trim().isEmpty) {
        return _FieldIssue('부분공사로 손볼 곳을 적어 주세요', _anchors.workScope);
      }
      if (!_areaUnknown && _area.text.trim().isEmpty) {
        return _FieldIssue('평수를 적거나, 정확히 모른다고 골라 주세요', _anchors.area);
      }
      if (_buildingCondition == null) return _FieldIssue('철거 여부를 골라 주세요', _anchors.demolition);
      if (_style == null && _styleNote.text.trim().isEmpty) {
        return _FieldIssue('원하는 스타일을 고르거나 적어 주세요', _anchors.style);
      }
      if (!_budgetUndecided && _budget.text.trim().isEmpty) {
        return _FieldIssue('예산을 적거나, 아직 정하지 못했다고 골라 주세요', _anchors.budget);
      }
      if (_period == null && _targetRange == null) {
        return _FieldIssue('희망공사기간을 골라 주세요', _anchors.period);
      }
      if (_needs.text.trim().isEmpty) return _FieldIssue('상담에서 말하고 싶은 점을 적어 주세요', _anchors.needs);
    }
    return null;
  }

  void _showIssue(_FieldIssue issue) {
    setState(() {
      _error = issue.message;
      _errorAnchor = issue.anchor;
      _errorAbove = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureErrorDirection());
  }

  void _onFormScroll() {
    if (_errorAnchor == null) return;
    _measureErrorDirection();
  }

  void _measureErrorDirection() {
    if (!mounted) return;
    final BuildContext? target = _errorAnchor?.currentContext;
    final RenderObject? object = target?.findRenderObject();
    final ScrollableState? scrollable = target == null ? null : Scrollable.maybeOf(target);
    final RenderObject? viewport = scrollable?.context.findRenderObject();
    if (object is! RenderBox || !object.hasSize || viewport is! RenderBox || !viewport.hasSize) return;
    final double fieldTop = object.localToGlobal(Offset.zero).dy;
    final double fieldBottom = fieldTop + object.size.height;
    final double viewTop = viewport.localToGlobal(Offset.zero).dy;
    final double viewBottom = viewTop + viewport.size.height;
    final bool? above = fieldBottom < viewTop + 4
        ? true
        : fieldTop > viewBottom - 4
            ? false
            : null;
    if (above == _errorAbove) return;
    setState(() => _errorAbove = above);
  }

  void _revealError() {
    final BuildContext? target = _errorAnchor?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.08,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _addPhoto({required bool floorPlan}) async {
    final List<XFile> files;
    try {
      files = await ImagePicker().pickMultiImage(imageQuality: 85);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '사진을 불러오지 못했어요');
      return;
    }
    if (!mounted || files.isEmpty) return;
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    final String label = floorPlan ? '평면도' : '스타일';
    setState(() {
      _error = null;
      final List<ShowroomReferenceRegion> items = floorPlan ? _floorPlans : _stylePhotos;
      for (var index = 0; index < files.length; index++) {
        items.add(
          ShowroomReferenceRegion(
            id: 'local-$stamp-$index',
            label: label,
            imageUrl: files[index].path,
          ),
        );
      }
    });
  }

  Future<void> _openPhoto(ShowroomReferenceRegion region, {required bool floorPlan}) async {
    final ShowroomReferenceRegion? saved = await showShowroomReferenceEditor(
      context,
      region,
      title: floorPlan ? '평면도 설명' : '스타일 설명',
      saveLabel: floorPlan ? '도면사진 첨부' : '스타일 사진 첨부',
    );
    if (!mounted || saved == null) return;
    setState(() {
      final List<ShowroomReferenceRegion> items = floorPlan ? _floorPlans : _stylePhotos;
      final int index = items.indexWhere((ShowroomReferenceRegion item) => item.id == region.id);
      if (index >= 0) items[index] = saved;
    });
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
      helpText: '희망공사기간',
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

  String _styleRecord() {
    final String note = _styleNote.text.trim();
    final String? mood = _style;
    if (mood != null && note.isNotEmpty) return '$mood · $note';
    if (note.isNotEmpty) return note;
    return mood ?? '';
  }

  PrepRecord get _currentRecord {
    final DateTimeRange? range = _targetRange;
    return PrepRecord(
      id: _recordId,
      placeName: _buildingName.text.trim(),
      buildingType: _commercial,
      address: _address.text.trim(),
      detailAddress: _detailAddress.text.trim(),
      area: _areaUnknown ? PrepLabels.areaUnknown : _areaRecordText(_area.text, _areaUnit),
      buildingCondition: _buildingCondition ?? '',
      style: _styleRecord(),
      budget: _budgetUndecided ? PrepLabels.budgetUndecided : _budgetRecordText(_budget.text),
      period: range != null ? _formatDateRange(range) : (_period ?? ''),
      periodStart: range?.start,
      periodEnd: range?.end,
      needs: _needs.text.trim(),
      floorPlanLabels: _floorPlans.isEmpty
          ? _legacyFloorLabels
          : [
              for (final ShowroomReferenceRegion item in _floorPlans)
                if (item.note.trim().isNotEmpty) item.note.trim(),
            ],
      referenceImageLabels: _stylePhotos.isEmpty
          ? _legacyStyleLabels
          : [
              for (final ShowroomReferenceRegion item in _stylePhotos)
                if (item.note.trim().isNotEmpty) item.note.trim(),
            ],
      floorPlans: List<ShowroomReferenceRegion>.unmodifiable(_floorPlans),
      stylePhotos: List<ShowroomReferenceRegion>.unmodifiable(_stylePhotos),
      industry:
          _industry == _industryOther
              ? _industryNote.text.trim()
              : (_industry ?? ''),
      workScope: _workScope ?? '',
      contact: _contact.text.trim(),
      workPlace:
          _workScope == PrepLabels.partialWork ? _workPlace.text.trim() : '',
      styleRef: _styleRef,
    );
  }

  ShowroomStyleRef _withRegions(ShowroomStyleRef reference, List<ShowroomReferenceRegion> regions) {
    return ShowroomStyleRef(
      showroomId: reference.showroomId,
      title: reference.title,
      imageUrl: reference.imageUrl,
      aspects: reference.aspects,
      regions: regions,
      note: reference.note,
    );
  }

  Future<void> _editReferenceRegion(ShowroomReferenceRegion region) async {
    final ShowroomReferenceRegion? saved = await showShowroomReferenceEditor(
      context,
      region,
      title: '참고 메모',
    );
    final ShowroomStyleRef? reference = _styleRef;
    if (!mounted || saved == null || reference == null) return;
    setState(() {
      _styleRef = _withRegions(reference, [
        for (final ShowroomReferenceRegion item in reference.regions)
          if (item.id == saved.id) saved else item,
      ]);
    });
  }

  void _deleteReferenceRegion(ShowroomReferenceRegion region) {
    final ShowroomStyleRef? reference = _styleRef;
    if (reference == null) return;
    setState(() {
      _styleRef = _withRegions(reference, [
        for (final ShowroomReferenceRegion item in reference.regions)
          if (item.id != region.id) item,
      ]);
    });
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
                  title: Text(
                    candidate.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${candidate.industry} · ${candidate.address}',
                  ),
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
      _areaUnit = _areaUnitOf(picked.area);
      _area.text = _areaUnknown || picked.area.isEmpty ? '' : _areaNumber(picked.area);
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

  void _setAreaUnit(_AreaUnit unit) {
    if (unit == _areaUnit) return;
    final double? value = double.tryParse(_area.text.trim());
    setState(() {
      if (value != null) {
        final double converted = unit == _AreaUnit.squareMeter
            ? value * _sqmPerPyeong
            : value / _sqmPerPyeong;
        _area.text = _formatAreaNumber(converted);
      }
      _areaUnit = unit;
    });
  }

  Future<void> _onWorkScope(String value) async {
    if (value != PrepLabels.partialWork) {
      setState(() => _workScope = value);
      return;
    }
    await showAppDialog<void>(
      context: context,
      title: '부분공사는 아직이에요',
      message: '지금은 전체공사만 상담준비를 진행할 수 있어요.',
      actions:
          (BuildContext dialogContext) => [
            AppButton(
              label: '확인',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
    );
  }

  Future<void> _onSpaceKind(String value) async {
    if (value != _residential) return;
    await showAppDialog<void>(
      context: context,
      title: '주거는 아직이에요',
      message: '지금은 상가 공간만 상담준비를 진행할 수 있어요.',
      actions:
          (BuildContext dialogContext) => [
            AppButton(
              label: '확인',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double messageFont = MediaQuery.textScalerOf(context).scale(13 * fontScale);
    final double messagePad = subGap * 0.75;
    final double messageSlot = messagePad + messageFont * 1.35 * 2 + messagePad;

    final bool leaveScreen = _saved || (_step == 0 && !_hasDraft);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _unfocusIfOutside,
      child: PopScope(
      canPop: leaveScreen,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (!_saved && _step > 0) {
          _previousStep();
          return;
        }
        _leaveForm();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('상담준비'),
        leading: BackButton(onPressed: _back),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            padding.left,
            subGap,
            padding.right,
            subGap,
          ),
          child:
              _saved
                  ? PrepDetailView(
                    record: _currentRecord,
                    onEdit:
                        (int step) => setState(() {
                          _saved = false;
                          _step = step;
                          _error = null;
                          _errorAnchor = null;
                          _stepDirection = 1;
                          _stepMotion.forward(from: 0);
                          _scrollFormToTop();
                        }),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StepHeader(
                        steps: _steps,
                        index: _step,
                        fontScale: fontScale,
                      ),
                      SizedBox(height: sectionGap),
                      Expanded(
                        child: ListView(
                          controller: _formScroll,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          children: [
                            ClipRect(
                              child: AnimatedBuilder(
                                animation: _stepMotion,
                                builder: (BuildContext context, Widget? child) {
                                  final double travel = (1 - Curves.easeOut.transform(_stepMotion.value)) * _stepDirection;
                                  return FractionalTranslation(
                                    translation: Offset(travel, 0),
                                    child: child,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _StepTitle(
                                      title: _step == 0 ? '공간을 정해주세요' : '원하는 조건을 적어 주세요',
                                      body: _step == 0
                                          ? '상가 공간을 기준으로 주소와 업종, 연락처를 적어 두면 상담으로 이어갈 수 있어요. 업종을 아직 모르면 그렇게 골라도 돼요.'
                                          : '모르는 항목은 그대로 두어도 돼요. 상담에서 이어서 확인해요.',
                                      fontScale: fontScale,
                                    ),
                                    if (_styleRef case final ShowroomStyleRef reference) ...[
                                      SizedBox(height: sectionGap),
                                      ShowroomStyleReferenceTile(
                                        reference: reference,
                                        fontScale: fontScale,
                                        onRegionTap: _editReferenceRegion,
                                        onRegionDelete: _deleteReferenceRegion,
                                      ),
                                    ],
                                    SizedBox(height: sectionGap),
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
                                onIndustry:
                                    (String value) =>
                                        setState(() => _industry = value),
                                onSpaceKind: _onSpaceKind,
                                onImport:
                                    SpaceBoard.instance.trades.isEmpty
                                        ? null
                                        : _importTrade,
                                anchors: _anchors,
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
                                areaUnit: _areaUnit,
                                onAreaUnit: _setAreaUnit,
                                budgetUndecided: _budgetUndecided,
                                workPlace: _workPlace,
                                targetRange: _targetRange,
                                area: _area,
                                budget: _budget,
                                needs: _needs,
                                styleNote: _styleNote,
                                onStyle:
                                    (String value) =>
                                        setState(() => _style = value),
                                onBuildingCondition:
                                    (String value) => setState(
                                      () => _buildingCondition = value,
                                    ),
                                onWorkScope: _onWorkScope,
                                onAreaUnknown:
                                    () => setState(() {
                                      _areaUnknown = !_areaUnknown;
                                      if (_areaUnknown) _area.clear();
                                    }),
                                onAreaChanged: (String value) {
                                  if (value.trim().isNotEmpty && _areaUnknown) {
                                    setState(() => _areaUnknown = false);
                                  }
                                },
                                onBudgetUndecided:
                                    () => setState(() {
                                      _budgetUndecided = !_budgetUndecided;
                                      if (_budgetUndecided) _budget.clear();
                                    }),
                                onBudgetChanged: (String value) {
                                  if (value.trim().isNotEmpty &&
                                      _budgetUndecided) {
                                    setState(() => _budgetUndecided = false);
                                  }
                                },
                                onPeriod:
                                    (String value) => setState(() {
                                      _period = value;
                                      _targetRange = null;
                                    }),
                                onPickDate: _pickTargetRange,
                                onClearDate:
                                    () => setState(() => _targetRange = null),
                                floorPlans: _floorPlans,
                                stylePhotos: _stylePhotos,
                                onAddFloorPlan: () => _addPhoto(floorPlan: true),
                                onOpenFloorPlan: (ShowroomReferenceRegion region) =>
                                    _openPhoto(region, floorPlan: true),
                                onRemoveFloorPlan: (ShowroomReferenceRegion region) =>
                                    setState(() => _floorPlans.remove(region)),
                                onAddStylePhoto: () => _addPhoto(floorPlan: false),
                                onOpenStylePhoto: (ShowroomReferenceRegion region) =>
                                    _openPhoto(region, floorPlan: false),
                                onRemoveStylePhoto: (ShowroomReferenceRegion region) =>
                                    setState(() => _stylePhotos.remove(region)),
                                anchors: _anchors,
                              ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: messageSlot,
                        child: Padding(
                          padding: EdgeInsets.only(top: messagePad, bottom: messagePad),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _error == null
                                ? const SizedBox.shrink()
                                : Material(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: _revealError,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _error!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13 * fontScale,
                                                  height: 1.35,
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: AppColors.error,
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),
                                            if (_errorAbove != null) ...[
                                              const SizedBox(width: 8),
                                              Icon(
                                                _errorAbove! ? Icons.arrow_upward : Icons.arrow_downward,
                                                size: 16,
                                                color: AppColors.error,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      AppButton(
                        label: _step == 0 ? '조건설정 넘어가기' : '상담준비 저장',
                        onPressed: _next,
                      ),
                    ],
                  ),
        ),
      ),
      ),
      ),
    );
  }

  bool get _hasDraft {
    if (_saved) return false;
    return _address.text.trim().isNotEmpty ||
        _detailAddress.text.trim().isNotEmpty ||
        _buildingName.text.trim().isNotEmpty ||
        _industry != null ||
        _industryNote.text.trim().isNotEmpty ||
        _contact.text.trim().isNotEmpty ||
        _area.text.trim().isNotEmpty ||
        _areaUnknown ||
        _buildingCondition != null ||
        _style != null ||
        _styleNote.text.trim().isNotEmpty ||
        _budget.text.trim().isNotEmpty ||
        _budgetUndecided ||
        _period != null ||
        _targetRange != null ||
        _needs.text.trim().isNotEmpty ||
        _workPlace.text.trim().isNotEmpty ||
        _floorPlans.isNotEmpty ||
        _stylePhotos.isNotEmpty ||
        _styleRef != null ||
        _recordId.isNotEmpty;
  }

  void _back() {
    if (_saved) {
      Navigator.of(context).pop();
      return;
    }
    if (_step > 0) {
      _previousStep();
      return;
    }
    _leaveForm();
  }

  void _storeDraft() {
    if (_recordId.isEmpty) _recordId = 'consult-${DateTime.now().microsecondsSinceEpoch}';
    SpaceBoard.instance.saveConsult(_currentRecord);
  }

  Future<void> _leaveForm() async {
    if (!_hasDraft) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final String? choice = await showAppDialog<String>(
      context: context,
      title: '지금까지 저장할까요?',
      message: '지금 적은 만큼만 저장해 둘 수 있어요. 비어 있는 항목이 있어도 되고, 상담 신청은 나중에 해도 돼요.',
      actions: (BuildContext dialogContext) => [
        AppButton(
          label: '저장하고 나가기',
          onPressed: () => Navigator.of(dialogContext).pop('save'),
        ),
        AppButton(
          label: '저장하지 않기',
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(dialogContext).pop('discard'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('계속 작성'),
        ),
      ],
    );
    if (!mounted || choice == null) return;
    if (choice == 'save') _storeDraft();
    Navigator.of(context).pop();
  }

  void _previousStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _step -= 1;
      _error = null;
      _errorAnchor = null;
      _stepDirection = -1;
    });
    _stepMotion.forward(from: 0);
    _scrollFormToTop();
  }

  void _unfocusIfOutside(PointerDownEvent event) {
    final FocusNode? focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasFocus) return;
    final RenderObject? object = focus.context?.findRenderObject();
    if (object is RenderBox && object.hasSize) {
      final Rect field = object.localToGlobal(Offset.zero) & object.size;
      if (field.inflate(24).contains(event.position)) return;
    }
    focus.unfocus();
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.steps,
    required this.index,
    required this.fontScale,
  });

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
                    color: i <= index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: i == index ? FontWeight.w700 : FontWeight.w500,
                    color: i == index ? AppColors.primary : AppColors.textSecondary,
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
    required this.anchors,
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
  final _FormAnchors anchors;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onImport != null) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('상권 후보지에서 불러오기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: subGap),
        ],
        _FormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label: '공간', fontScale: fontScale),
              SizedBox(height: subGap),
              _OptionSegment(
                values: const [
                  _PrepCreateScreenState._commercial,
                  _PrepCreateScreenState._residential,
                ],
                selected: _PrepCreateScreenState._commercial,
                fontScale: fontScale,
                onSelected: onSpaceKind,
              ),
              SizedBox(height: subGap),
              Text(
                '지금은 상가 공간만 진행할 수 있어요.',
                style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.address,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.placeName,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label: '공간 이름', fontScale: fontScale),
              SizedBox(height: subGap),
              _PrepTextField(controller: buildingName, hint: '예: 성수 사옥, 동탄 고기집'),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.industry,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label: '업종', fontScale: fontScale),
              SizedBox(height: subGap),
              Text(
                '자주 있는 업종만 골랐어요. 없으면 기타에 직접 적어 주세요.',
                style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: AppColors.textPrimary),
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
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.contact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label: '연락처', fontScale: fontScale),
              SizedBox(height: subGap),
              Text(
                '하이픈 없이 숫자만 적어 주세요. 010-0000-0000 형태로 보여 드려요.',
                style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: AppColors.textPrimary),
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: contact,
                hint: '01012345678',
                keyboardType: TextInputType.number,
                inputFormatters: const [_KoreanMobileFormatter()],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
        color: AppColors.background,
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
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
                                  color: value == selected ? AppColors.white : AppColors.textPrimary,
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

String _formatDateRange(DateTimeRange range) {
  final DateTime start = range.start;
  final DateTime end = range.end;
  final String startLabel = '${start.year}년 ${start.month}월 ${start.day}일';
  final String endLabel =
      start.year == end.year
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
    required this.areaUnit,
    required this.onAreaUnit,
    required this.budgetUndecided,
    required this.workPlace,
    required this.targetRange,
    required this.area,
    required this.budget,
    required this.needs,
    required this.styleNote,
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
    required this.floorPlans,
    required this.stylePhotos,
    required this.onAddFloorPlan,
    required this.onOpenFloorPlan,
    required this.onRemoveFloorPlan,
    required this.onAddStylePhoto,
    required this.onOpenStylePhoto,
    required this.onRemoveStylePhoto,
    required this.anchors,
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
  final _AreaUnit areaUnit;
  final ValueChanged<_AreaUnit> onAreaUnit;
  final bool budgetUndecided;
  final TextEditingController workPlace;
  final DateTimeRange? targetRange;
  final TextEditingController area;
  final TextEditingController budget;
  final TextEditingController needs;
  final TextEditingController styleNote;
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
  final List<ShowroomReferenceRegion> floorPlans;
  final List<ShowroomReferenceRegion> stylePhotos;
  final VoidCallback onAddFloorPlan;
  final ValueChanged<ShowroomReferenceRegion> onOpenFloorPlan;
  final ValueChanged<ShowroomReferenceRegion> onRemoveFloorPlan;
  final VoidCallback onAddStylePhoto;
  final ValueChanged<ShowroomReferenceRegion> onOpenStylePhoto;
  final ValueChanged<ShowroomReferenceRegion> onRemoveStylePhoto;
  final _FormAnchors anchors;

  @override
  Widget build(BuildContext context) {
    final String dateLabel =
        targetRange == null ? '날짜로 진행 기간 지정' : _formatDateRange(targetRange!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormSection(
          key: anchors.workScope,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        _FieldLabel(label: '공사 형태', fontScale: fontScale),
        SizedBox(height: subGap),
        _OptionSegment(
          values: workScopes,
          selected: workScope,
          fontScale: fontScale,
          onSelected: onWorkScope,
        ),
        SizedBox(height: subGap),
        Text(
          '지금은 전체공사만 진행할 수 있어요.',
          style: TextStyle(
            fontSize: 13 * fontScale,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
        ),
        if (workScope == PrepLabels.partialWork) ...[
          SizedBox(height: subGap),
          Text(
            '주방, 홀처럼 손볼 곳을 간단히 적어 주세요.',
            style: TextStyle(
              fontSize: 13 * fontScale,
              height: 1.4,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: subGap),
          _PrepTextField(controller: workPlace, hint: '예: 주방, 홀', maxLines: 2),
        ],
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.area,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Row(
          children: [
            _FieldLabel(label: '평수', fontScale: fontScale),
            const Spacer(),
            _AreaUnitSwitch(unit: areaUnit, fontScale: fontScale, onChanged: onAreaUnit),
          ],
        ),
        SizedBox(height: subGap),
        _PrepTextField(
          controller: area,
          hint: areaUnit == _AreaUnit.pyeong ? '예: 32' : '예: 106',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const <TextInputFormatter>[_DecimalFormatter()],
          suffixText: _areaUnitLabel(areaUnit),
          onChanged: onAreaChanged,
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: const [PrepLabels.areaUnknown],
          selected: areaUnknown ? PrepLabels.areaUnknown : null,
          fontScale: fontScale,
          onSelected: (_) => onAreaUnknown(),
        ),
        _QuietAttach(
          action: '평면도 올리기',
          items: floorPlans,
          fontScale: fontScale,
          subGap: subGap,
          onAdd: onAddFloorPlan,
          onOpen: onOpenFloorPlan,
          onRemove: onRemoveFloorPlan,
        ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.demolition,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        _FieldLabel(label: '철거 여부', fontScale: fontScale),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: buildingConditions,
          selected: buildingCondition,
          fontScale: fontScale,
          onSelected: onBuildingCondition,
        ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        _FieldLabel(label: '원하는 스타일', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '가까운 분위기를 고르거나, 원하는 스타일을 직접 적어도 돼요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: AppColors.textPrimary),
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: styles,
          selected: style,
          fontScale: fontScale,
          onSelected: onStyle,
        ),
        SizedBox(height: subGap),
        _PrepTextField(controller: styleNote, hint: '예: 호텔 라운지, 노출 콘크리트'),
        _QuietAttach(
          action: '사진으로 설명하기',
          items: stylePhotos,
          fontScale: fontScale,
          subGap: subGap,
          onAdd: onAddStylePhoto,
          onOpen: onOpenStylePhoto,
          onRemove: onRemoveStylePhoto,
        ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.budget,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        _FieldLabel(label: '예산', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(
          controller: budget,
          hint: '예: 30,000,000',
          keyboardType: TextInputType.number,
          inputFormatters: const <TextInputFormatter>[_GroupedIntFormatter()],
          suffixText: '원',
          onChanged: onBudgetChanged,
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: const [PrepLabels.budgetUndecided],
          selected: budgetUndecided ? PrepLabels.budgetUndecided : null,
          fontScale: fontScale,
          onSelected: (_) => onBudgetUndecided(),
        ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.period,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        _FieldLabel(label: '희망공사기간', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '공사가 진행됨에 따라 인건비가 늘어나요. 희망하는 공사의 진행 기간을 골라 주세요. 상담을 통해 기간은 달라질 수 있어요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: AppColors.textPrimary),
        ),
        SizedBox(height: subGap),
        _ChoiceWrap(
          values: periods,
          selected: period,
          fontScale: fontScale,
          onSelected: onPeriod,
        ),
        SizedBox(height: subGap),
        _DatePickField(
          label: dateLabel,
          selected: targetRange != null,
          fontScale: fontScale,
          onTap: onPickDate,
          onClear: onClearDate,
        ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.needs,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        _FieldLabel(label: '상담에서 말하고 싶은 점', fontScale: fontScale),
        SizedBox(height: subGap),
        _PrepTextField(
          controller: needs,
          hint: '예: 주방을 넓히고, 수납을 늘리고 싶어요',
          maxLines: 4,
        ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? const Color(0xFF1A1A1A) : const Color(0xFFE4E4E4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color:
                    selected
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF8C7358),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        selected
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFB0B0B0),
                  ),
                ),
              ),
              if (selected)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFF8C7358),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double pad = ResponsiveSize.subGap(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: child,
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({
    required this.title,
    required this.body,
    required this.fontScale,
  });

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
          style: TextStyle(
            fontSize: 22 * fontScale,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

enum _AreaUnit { pyeong, squareMeter }

const double _sqmPerPyeong = 3.305785;

String _areaUnitLabel(_AreaUnit unit) => unit == _AreaUnit.pyeong ? '평' : '㎡';

_AreaUnit _areaUnitOf(String saved) => saved.endsWith('㎡') ? _AreaUnit.squareMeter : _AreaUnit.pyeong;

String _areaNumber(String saved) {
  return saved.replaceAll('평', '').replaceAll('㎡', '').trim();
}

String _areaRecordText(String field, _AreaUnit unit) {
  final String trimmed = field.trim();
  if (trimmed.isEmpty) return '';
  return '$trimmed${_areaUnitLabel(unit)}';
}

String _formatAreaNumber(double value) {
  if (value <= 0) return '';
  final double rounded = (value * 10).round() / 10;
  if ((rounded - rounded.roundToDouble()).abs() < 0.05) return rounded.round().toString();
  return rounded.toStringAsFixed(1);
}

class _AreaUnitSwitch extends StatelessWidget {
  const _AreaUnitSwitch({required this.unit, required this.fontScale, required this.onChanged});

  final _AreaUnit unit;
  final double fontScale;
  final ValueChanged<_AreaUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final _AreaUnit item in _AreaUnit.values)
              GestureDetector(
                onTap: () => onChanged(item),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: item == unit ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      _areaUnitLabel(item),
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: item == unit ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DecimalFormatter extends TextInputFormatter {
  const _DecimalFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty || RegExp(r'^\d*\.?\d{0,1}$').hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class _QuietAttach extends StatelessWidget {
  const _QuietAttach({
    required this.action,
    required this.items,
    required this.fontScale,
    required this.subGap,
    required this.onAdd,
    required this.onOpen,
    required this.onRemove,
  });

  final String action;
  final List<ShowroomReferenceRegion> items;
  final double fontScale;
  final double subGap;
  final VoidCallback onAdd;
  final ValueChanged<ShowroomReferenceRegion> onOpen;
  final ValueChanged<ShowroomReferenceRegion> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: subGap),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
            label: Text(action),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: TextStyle(fontSize: 15 * fontScale, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (items.isNotEmpty) ...[
          SizedBox(height: subGap),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(subGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사진을 누르면 그 장에 설명을 넣을 수 있어요.',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: subGap * 0.5),
                  PrepPhotoStrip(
                    regions: items,
                    fontScale: fontScale,
                    onTap: onOpen,
                    onDelete: onRemove,
                  ),
                ],
              ),
            ),
          ),
        ],
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
      color: AppColors.background,
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
                    color:
                        empty
                            ? const Color(0xFFB0B0B0)
                            : const Color(0xFF1A1A1A),
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

String _budgetFieldText(String saved) {
  final String trimmed = saved.trim();
  if (!trimmed.endsWith('원')) return trimmed;
  final String withoutUnit = trimmed.substring(0, trimmed.length - 1).trim();
  if (RegExp(r'^[\d,]+$').hasMatch(withoutUnit)) return withoutUnit;
  return trimmed;
}

String _budgetRecordText(String field) {
  final String trimmed = field.trim();
  if (trimmed.isEmpty || trimmed.endsWith('원')) return trimmed;
  if (RegExp(r'^[\d,]+$').hasMatch(trimmed)) return '$trimmed원';
  return trimmed;
}

String _formatKoreanMobile(String raw) {
  final String digits = raw.replaceAll(RegExp(r'\D'), '');
  final String clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
  if (clipped.length <= 3) return clipped;
  if (clipped.length <= 7)
    return '${clipped.substring(0, 3)}-${clipped.substring(3)}';
  return '${clipped.substring(0, 3)}-${clipped.substring(3, 7)}-${clipped.substring(7)}';
}

class _KoreanMobileFormatter extends TextInputFormatter {
  const _KoreanMobileFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var digitCursor = _digitsBefore(
      newValue.text,
      newValue.selection.extentOffset,
    );
    final String oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    final bool removedSeparatorOnly =
        digits == oldDigits && newValue.text.length < oldValue.text.length;
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
      selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(formatted, digitCursor),
      ),
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

class _GroupedIntFormatter extends TextInputFormatter {
  const _GroupedIntFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var digitCursor = _digitsBefore(newValue.text, newValue.selection.extentOffset);
    final String oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    final bool removedSeparatorOnly =
        digits == oldDigits && newValue.text.length < oldValue.text.length;
    if (removedSeparatorOnly && digitCursor > 0) {
      final int removeAt = digitCursor - 1;
      digits = digits.substring(0, removeAt) + digits.substring(removeAt + 1);
      digitCursor = removeAt;
    }
    if (digits.length > 1) digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
      digitCursor = digitCursor.clamp(0, 12);
    }
    digitCursor = digitCursor.clamp(0, digits.length);
    final String formatted = _groupDigits(digits);
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
    for (var index = 0; index < formatted.length; index++) {
      final int code = formatted.codeUnitAt(index);
      if (code >= 48 && code <= 57) {
        seen++;
        if (seen == digitCount) return index + 1;
      }
    }
    return formatted.length;
  }
}

String _groupDigits(String digits) {
  if (digits.isEmpty) return '';
  final StringBuffer buffer = StringBuffer();
  final int lead = digits.length % 3;
  if (lead > 0) buffer.write(digits.substring(0, lead));
  for (int index = lead; index < digits.length; index += 3) {
    if (buffer.isNotEmpty) buffer.write(',');
    buffer.write(digits.substring(index, index + 3));
  }
  return buffer.toString();
}

class _PrepTextField extends StatelessWidget {
  const _PrepTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.suffixText,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      scrollPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 96),
      style: TextStyle(fontSize: 15 * fontScale),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffixText,
        suffixStyle: TextStyle(fontSize: 15 * fontScale, color: const Color(0xFF1A1A1A)),
        hintStyle: TextStyle(
          fontSize: 15 * fontScale,
          color: const Color(0xFFB0B0B0),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
              color:
                  selected == value
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF1A1A1A),
            ),
            selectedColor: const Color(0xFF111111),
            backgroundColor: AppColors.background,
            side: BorderSide(
              color:
                  selected == value
                      ? const Color(0xFF111111)
                      : const Color(0xFFE4E4E4),
            ),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}
