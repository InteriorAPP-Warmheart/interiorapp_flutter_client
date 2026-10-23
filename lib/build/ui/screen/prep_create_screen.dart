import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_budget_guide.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_survey.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/kakao_address_search_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/form_step_header.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/prep_budget_reading_card.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_reference_pick.dart';

/// 상담준비 작성. 현장, 조건, 그리고 선택인 마감 순서로 나눈다.
class PrepCreateScreen extends ConsumerStatefulWidget {
  const PrepCreateScreen({super.key, this.initial, this.initialStep = 0});

  final PrepRecord? initial;
  final int initialStep;

  @override
  ConsumerState<PrepCreateScreen> createState() => _PrepCreateScreenState();
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

class _PrepCreateScreenState extends ConsumerState<PrepCreateScreen>
    with TickerProviderStateMixin {
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
  final List<ShowroomReferenceRegion> _stylePhotos =
      <ShowroomReferenceRegion>[];
  List<String> _legacyFloorLabels = const <String>[];
  List<String> _legacyStyleLabels = const <String>[];
  String? _industry;
  String? _industryGroup;
  String? _secondaryBrowse;
  final List<String> _secondaryIndustries = <String>[];
  String? _workScope = PrepLabels.fullWork;
  String? _buildingCondition;
  final Map<String, List<String>> _finishChoices = <String, List<String>>{};
  final Map<String, TextEditingController> _finishNotes =
      <String, TextEditingController>{};
  String? _style;
  String? _period;
  bool _areaUnknown = false;
  String? _areaRange;
  String? _budgetRange;
  bool _budgetUndecided = false;
  String? _startTiming;
  String? _openTiming;
  bool _contactEdited = false;
  _AreaUnit _areaUnit = _AreaUnit.pyeong;
  DateTimeRange? _targetRange;
  String? _error;
  GlobalKey? _errorAnchor;
  bool? _errorAbove;
  ShowroomStyleRef? _styleRef;
  final _FormAnchors _anchors = _FormAnchors();

  /// 화면을 연 직후의 작성 내용. 계정 연락처를 자동으로 채운 값도 여기에 포함한다.
  late String _openedDraft;
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
    _bindFinishes(widget.initial);
    final PrepRecord? initial = widget.initial;
    if (initial == null) {
      _openedDraft = _draftSignature();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyAccountPhone(ref.read(myPageUserVmProvider)?.phone);
      });
      return;
    }
    _recordId = initial.id;
    _styleRef = initial.styleRef;
    _address.text = initial.address;
    _detailAddress.text = initial.detailAddress;
    _buildingName.text = initial.placeName;
    _areaUnknown = initial.area == PrepLabels.areaUnknown;
    _areaRange = initial.areaRange.isEmpty ? null : initial.areaRange;
    if (_areaRange == null && PrepSurvey.areaRanges.contains(initial.area)) {
      _areaRange = initial.area;
    }
    _areaUnit = _areaUnitOf(initial.area);
    final bool areaIsRange = _areaRange != null && initial.area == _areaRange;
    _area.text = _areaUnknown || areaIsRange ? '' : _areaNumber(initial.area);
    _budgetUndecided = initial.budget == PrepLabels.budgetUndecided;
    _budgetRange = initial.budgetRange.isEmpty ? null : initial.budgetRange;
    if (_budgetRange == null &&
        PrepSurvey.budgetRanges.contains(initial.budget)) {
      _budgetRange = initial.budget;
    }
    final bool budgetIsRange =
        _budgetRange != null && initial.budget == _budgetRange;
    _budget.text =
        _budgetUndecided || budgetIsRange
            ? ''
            : _budgetFieldText(initial.budget);
    _startTiming = initial.startTiming.isEmpty ? null : initial.startTiming;
    _openTiming = initial.openTiming.isEmpty ? null : initial.openTiming;
    _needs.text = initial.needs;
    _contact.text = _formatKoreanMobile(initial.contact);
    _contactEdited = initial.contact.trim().isNotEmpty;
    final String savedIndustry = initial.industry;
    final String? catalogGroup = PrepSurvey.groupOf(savedIndustry);
    if (savedIndustry.isEmpty) {
      _industry = null;
    } else if (catalogGroup != null) {
      _industry = savedIndustry;
      _industryGroup =
          initial.industryGroup.isEmpty ? catalogGroup : initial.industryGroup;
    } else if (PrepSurvey.industry.choices.contains(savedIndustry)) {
      _industry = savedIndustry;
      if (initial.industryGroup.isNotEmpty)
        _industryGroup = initial.industryGroup;
    } else {
      _industry = PrepSurvey.industryOther;
      _industryNote.text = savedIndustry;
    }
    _secondaryIndustries.addAll(initial.secondaryIndustries);
    _secondaryBrowse = _industryGroup;
    _workScope =
        PrepSurvey.workScope.choices.contains(initial.workScope)
            ? initial.workScope
            : PrepLabels.fullWork;
    _workPlace.text = initial.workPlace;
    _buildingCondition =
        initial.buildingCondition.isEmpty ? null : initial.buildingCondition;
    final String savedStyle = initial.style;
    final int styleSplit = savedStyle.indexOf(' · ');
    if (styleSplit >= 0) {
      final String mood = savedStyle.substring(0, styleSplit);
      if (PrepSurvey.style.choices.contains(mood)) {
        _style = mood;
        _styleNote.text = savedStyle.substring(styleSplit + 3);
      } else {
        _styleNote.text = savedStyle;
      }
    } else if (PrepSurvey.style.choices.contains(savedStyle)) {
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
    _step = widget.initialStep.clamp(0, PrepSurvey.steps.length - 1);
    _openedDraft = _draftSignature();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyAccountPhone(ref.read(myPageUserVmProvider)?.phone);
    });
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
    for (final TextEditingController note in _finishNotes.values) {
      note.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    final _FieldIssue? issue = _validate();
    if (issue != null) {
      _showIssue(issue);
      return;
    }
    if (_step >= PrepSurvey.steps.length - 1) {
      final bool save = await _confirmBudget();
      if (!save || !mounted) return;
      if (_recordId.isEmpty) {
        _recordId = 'consult-${DateTime.now().microsecondsSinceEpoch}';
      }
      ref.read(spaceBoardProvider).saveConsult(_currentRecord);
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

  Future<bool> _confirmBudget() async {
    if (_budget.text.trim().isEmpty) return true;
    final PrepPyeongBasis? basis = await ref
        .read(pyeongBasisUseCaseProvider)
        .find(_pyeongQuery);
    if (!mounted) return false;
    final PrepBudgetReading reading = PrepBudgetGuide.read(
      area: _storedArea,
      budget: _storedBudget,
      finishes: _finishRecord(),
      query: _pyeongQuery,
      basis: basis,
    );
    final bool? save = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => PrepBudgetSaveDialog(reading: reading),
    );
    return save == true;
  }

  void _scrollFormToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_formScroll.hasClients) return;
      _formScroll.jumpTo(0);
    });
  }

  _FieldIssue? _validate() {
    if (_step == 0) {
      if (_address.text.trim().isEmpty) {
        return _FieldIssue(PrepSurvey.address.emptyMessage!, _anchors.address);
      }
      if (_detailAddress.text.trim().isEmpty) {
        return _FieldIssue(
          PrepSurvey.detailAddress.emptyMessage!,
          _anchors.address,
        );
      }
      if (_industry == null)
        return _FieldIssue(
          PrepSurvey.industry.emptyMessage!,
          _anchors.industry,
        );
      if (_industry == PrepSurvey.industryOther &&
          _industryNote.text.trim().isEmpty) {
        return _FieldIssue(PrepSurvey.industryNoteEmpty, _anchors.industry);
      }
      final int contactDigits =
          _contact.text.replaceAll(RegExp(r'\D'), '').length;
      if (contactDigits == 0)
        return _FieldIssue(PrepSurvey.contactEmpty, _anchors.contact);
      if (contactDigits < 10)
        return _FieldIssue(PrepSurvey.contactInvalid, _anchors.contact);
    }
    if (_step == 1) {
      if (_workScope == null)
        return _FieldIssue(
          PrepSurvey.workScope.emptyMessage!,
          _anchors.workScope,
        );
      if (_workScope == PrepLabels.partialWork &&
          _workPlace.text.trim().isEmpty) {
        return _FieldIssue(PrepSurvey.partialPlaceEmpty, _anchors.workScope);
      }
      if (!_areaUnknown &&
          _area.text.trim().isEmpty &&
          (_areaRange == null || _areaRange!.isEmpty)) {
        return _FieldIssue(PrepSurvey.area.emptyMessage!, _anchors.area);
      }
      if (_buildingCondition == null) {
        return _FieldIssue(
          PrepSurvey.demolition.emptyMessage!,
          _anchors.demolition,
        );
      }
      if (_style == null && _styleNote.text.trim().isEmpty) {
        return _FieldIssue(PrepSurvey.style.emptyMessage!, _anchors.style);
      }
      if (_budget.text.trim().isEmpty &&
          !_budgetUndecided &&
          (_budgetRange == null || _budgetRange!.isEmpty)) {
        return _FieldIssue(PrepSurvey.budget.emptyMessage!, _anchors.budget);
      }
      if (_period == null && _targetRange == null) {
        return _FieldIssue(PrepSurvey.period.emptyMessage!, _anchors.period);
      }
      if (_needs.text.trim().isEmpty)
        return _FieldIssue(PrepSurvey.needs.emptyMessage!, _anchors.needs);
    }
    return null;
  }

  void _showIssue(_FieldIssue issue) {
    setState(() {
      _error = issue.message;
      _errorAnchor = issue.anchor;
      _errorAbove = null;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _measureErrorDirection(),
    );
  }

  void _onFormScroll() {
    if (_errorAnchor == null) return;
    _measureErrorDirection();
  }

  void _measureErrorDirection() {
    if (!mounted) return;
    final BuildContext? target = _errorAnchor?.currentContext;
    final RenderObject? object = target?.findRenderObject();
    final ScrollableState? scrollable =
        target == null ? null : Scrollable.maybeOf(target);
    final RenderObject? viewport = scrollable?.context.findRenderObject();
    if (object is! RenderBox ||
        !object.hasSize ||
        viewport is! RenderBox ||
        !viewport.hasSize)
      return;
    final double fieldTop = object.localToGlobal(Offset.zero).dy;
    final double fieldBottom = fieldTop + object.size.height;
    final double viewTop = viewport.localToGlobal(Offset.zero).dy;
    final double viewBottom = viewTop + viewport.size.height;
    final bool? above =
        fieldBottom < viewTop + 4
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
      final List<ShowroomReferenceRegion> items =
          floorPlan ? _floorPlans : _stylePhotos;
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

  Future<void> _openPhoto(
    ShowroomReferenceRegion region, {
    required bool floorPlan,
  }) async {
    final ShowroomReferenceRegion? saved = await showShowroomReferenceEditor(
      context,
      region,
      title: floorPlan ? '평면도 설명' : '스타일 설명',
      saveLabel: floorPlan ? '도면사진 첨부' : '스타일 사진 첨부',
    );
    if (!mounted || saved == null) return;
    setState(() {
      final List<ShowroomReferenceRegion> items =
          floorPlan ? _floorPlans : _stylePhotos;
      final int index = items.indexWhere(
        (ShowroomReferenceRegion item) => item.id == region.id,
      );
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

  void _bindFinishes(PrepRecord? initial) {
    for (final PrepQuestion question in PrepSurvey.details) {
      final PrepFinishAnswer? saved = initial?.finishes[question.id];
      _finishChoices[question.id] = <String>[...?saved?.choices];
      _finishNotes[question.id] = TextEditingController(
        text: saved?.note ?? '',
      );
    }
  }

  Map<String, PrepFinishAnswer> _finishRecord() {
    final Map<String, PrepFinishAnswer> answers = <String, PrepFinishAnswer>{};
    for (final PrepQuestion question in PrepSurvey.details) {
      final List<String> choices =
          _finishChoices[question.id] ?? const <String>[];
      final String note = _finishNotes[question.id]?.text.trim() ?? '';
      if (choices.isEmpty && note.isEmpty) continue;
      answers[question.id] = PrepFinishAnswer(
        choices: List<String>.unmodifiable(choices),
        note: note,
      );
    }
    return Map<String, PrepFinishAnswer>.unmodifiable(answers);
  }

  void _pickFinish(PrepQuestion question, String value) {
    final List<String> selected = _finishChoices[question.id] ??= <String>[];
    setState(() {
      if (question.many) {
        question.toggle(selected, value);
        return;
      }
      if (selected.length == 1 && selected.first == value) {
        selected.clear();
      } else {
        selected
          ..clear()
          ..add(value);
      }
    });
  }

  (String, String) get _stepHeading {
    return switch (_step) {
      0 => (
        '공간을 정해주세요',
        '상가 공간을 기준으로 주소와 업종, 연락처를 적어 두면 상담으로 이어갈 수 있어요. 업종을 아직 모르면 그렇게 골라도 돼요.',
      ),
      1 => ('원하는 조건을 적어 주세요', '모르는 항목은 그대로 두어도 돼요. 상담에서 이어서 확인해요.'),
      2 || _ => (PrepSurvey.detailsIntro.title, PrepSurvey.detailsIntro.help!),
    };
  }

  PrepPyeongQuery get _pyeongQuery {
    final String industry =
        _industry == PrepSurvey.industryOther
            ? _industryNote.text.trim()
            : (_industry ?? '');
    return PrepPyeongQuery(
      industry: industry,
      environment: _buildingCondition ?? '',
      situation: _workScope ?? '',
    );
  }

  String _styleRecord() {
    final String note = _styleNote.text.trim();
    final String? mood = _style;
    if (mood != null && note.isNotEmpty) return '$mood · $note';
    if (note.isNotEmpty) return note;
    return mood ?? '';
  }

  String get _resolvedIndustry {
    if (_industry == PrepSurvey.industryOther) return _industryNote.text.trim();
    return _industry ?? '';
  }

  String get _tempPlaceName =>
      consultTempPlaceName(address: _address.text, industry: _resolvedIndustry);

  String get _resolvedPlaceName {
    final String written = _buildingName.text.trim();
    if (written.isNotEmpty) return written;
    return _tempPlaceName;
  }

  String get _storedArea {
    if (_areaUnknown) return PrepLabels.areaUnknown;
    final String exact = _areaRecordText(_area.text, _areaUnit);
    if (exact.isNotEmpty) return exact;
    return _areaRange ?? '';
  }

  String get _storedBudget {
    if (_budgetUndecided) return PrepLabels.budgetUndecided;
    final String amount = _budgetRecordText(_budget.text);
    if (amount.isNotEmpty) return amount;
    return _budgetRange ?? '';
  }

  PrepRecord get _currentRecord {
    final DateTimeRange? range = _targetRange;
    return PrepRecord(
      id: _recordId,
      placeName: _resolvedPlaceName,
      buildingType: PrepSurvey.commercial,
      address: _address.text.trim(),
      detailAddress: _detailAddress.text.trim(),
      area: _storedArea,
      buildingCondition: _buildingCondition ?? '',
      style: _styleRecord(),
      budget: _storedBudget,
      period: range != null ? _formatDateRange(range) : (_period ?? ''),
      periodStart: range?.start,
      periodEnd: range?.end,
      needs: _needs.text.trim(),
      floorPlanLabels:
          _floorPlans.isEmpty
              ? _legacyFloorLabels
              : [
                for (final ShowroomReferenceRegion item in _floorPlans)
                  if (item.note.trim().isNotEmpty) item.note.trim(),
              ],
      referenceImageLabels:
          _stylePhotos.isEmpty
              ? _legacyStyleLabels
              : [
                for (final ShowroomReferenceRegion item in _stylePhotos)
                  if (item.note.trim().isNotEmpty) item.note.trim(),
              ],
      floorPlans: List<ShowroomReferenceRegion>.unmodifiable(_floorPlans),
      stylePhotos: List<ShowroomReferenceRegion>.unmodifiable(_stylePhotos),
      industry: _resolvedIndustry,
      industryGroup: _industryGroup ?? '',
      secondaryIndustries: List<String>.unmodifiable(_secondaryIndustries),
      areaRange: _areaUnknown ? '' : (_areaRange ?? ''),
      budgetRange: _budgetUndecided ? '' : (_budgetRange ?? ''),
      startTiming: _startTiming ?? '',
      openTiming: _openTiming ?? '',
      workScope: _workScope ?? '',
      contact: _contact.text.trim(),
      workPlace:
          _workScope == PrepLabels.partialWork ? _workPlace.text.trim() : '',
      finishes: _finishRecord(),
      styleRef: _styleRef,
    );
  }

  ShowroomStyleRef _withRegions(
    ShowroomStyleRef reference,
    List<ShowroomReferenceRegion> regions,
  ) {
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
              for (final TradeCandidate candidate
                  in ref.read(spaceBoardProvider).trades)
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
      _area.text =
          _areaUnknown || picked.area.isEmpty ? '' : _areaNumber(picked.area);
      if (picked.area.isEmpty) _areaUnknown = false;
      if (PrepSurvey.industry.choices.contains(picked.industry)) {
        _industry = picked.industry;
        _industryGroup = null;
        _industryNote.clear();
      } else if (PrepSurvey.groupOf(picked.industry) case final String group) {
        _industry = picked.industry;
        _industryGroup = group;
        _secondaryBrowse ??= group;
        _industryNote.clear();
      } else if (picked.industry.isNotEmpty) {
        _industry = PrepSurvey.industryOther;
        _industryNote.text = picked.industry;
        _industryGroup = null;
      }
      _secondaryIndustries.clear();
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
        final double converted =
            unit == _AreaUnit.squareMeter
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

  void _applyAccountPhone(String? phone) {
    if (_contactEdited || phone == null || phone.trim().isEmpty) return;
    if (_contact.text.trim().isNotEmpty) return;
    final String formatted = _formatKoreanMobile(phone);
    if (formatted.isEmpty) return;
    final String before = _draftSignature();
    _contact.text = formatted;
    if (_openedDraft == before) _openedDraft = _draftSignature();
    setState(() {});
  }

  void _onQuickIndustry(String value) {
    setState(() {
      _industry = value;
      _industryGroup = null;
      _secondaryBrowse = null;
      _secondaryIndustries.clear();
      if (value != PrepSurvey.industryOther) _industryNote.clear();
    });
  }

  void _onIndustryGroup(String value) {
    setState(() {
      _industryGroup = value;
      _secondaryBrowse ??= value;
    });
  }

  void _onPrimaryDetail(String value) {
    setState(() {
      _industry = value;
      _industryNote.clear();
      _secondaryIndustries.remove(value);
    });
  }

  void _toggleSecondary(String value) {
    if (value == _industry) return;
    setState(() {
      if (!_secondaryIndustries.remove(value)) _secondaryIndustries.add(value);
    });
  }

  void _onAreaRange(String value) {
    setState(() {
      _areaRange = _areaRange == value ? null : value;
      if (_areaRange != null) _areaUnknown = false;
    });
  }

  void _onBudgetRange(String value) {
    setState(() {
      _budgetUndecided = false;
      _budgetRange = _budgetRange == value ? null : value;
    });
  }

  void _onBudgetUndecided() {
    setState(() {
      _budgetUndecided = !_budgetUndecided;
      if (_budgetUndecided) {
        _budget.clear();
        _budgetRange = null;
      }
    });
  }

  Future<void> _onSpaceKind(String value) async {
    if (value != PrepSurvey.residential) return;
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
    final double messageFont = MediaQuery.textScalerOf(
      context,
    ).scale(13 * fontScale);
    final double messagePad = subGap * 0.75;
    final double messageSlot = messagePad + messageFont * 1.35 * 2 + messagePad;

    final bool leaveScreen = _saved || (_step == 0 && !_isDirty);
    ref.listen(myPageUserVmProvider, (previous, next) {
      _applyAccountPhone(next?.phone);
    });
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
                          FormStepHeader(
                            steps: PrepSurvey.steps,
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
                                    builder: (
                                      BuildContext context,
                                      Widget? child,
                                    ) {
                                      final double travel =
                                          (1 -
                                              Curves.easeOut.transform(
                                                _stepMotion.value,
                                              )) *
                                          _stepDirection;
                                      return FractionalTranslation(
                                        translation: Offset(travel, 0),
                                        child: child,
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _StepTitle(
                                          title: _stepHeading.$1,
                                          body: _stepHeading.$2,
                                          fontScale: fontScale,
                                        ),
                                        if (_styleRef
                                            case final ShowroomStyleRef
                                                reference) ...[
                                          SizedBox(height: sectionGap),
                                          ShowroomStyleReferenceTile(
                                            reference: reference,
                                            fontScale: fontScale,
                                            onRegionTap: _editReferenceRegion,
                                            onRegionDelete:
                                                _deleteReferenceRegion,
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
                                            industryGroup: _industryGroup,
                                            secondaryBrowse:
                                                _secondaryBrowse ??
                                                _industryGroup,
                                            secondaryIndustries:
                                                _secondaryIndustries,
                                            industryNote: _industryNote,
                                            contact: _contact,
                                            tempPlaceName:
                                                _buildingName.text
                                                        .trim()
                                                        .isEmpty
                                                    ? _tempPlaceName
                                                    : '',
                                            onIndustry: _onQuickIndustry,
                                            onIndustryGroup: _onIndustryGroup,
                                            onPrimaryDetail: _onPrimaryDetail,
                                            onSecondaryBrowse:
                                                (String value) => setState(
                                                  () =>
                                                      _secondaryBrowse = value,
                                                ),
                                            onToggleSecondary: _toggleSecondary,
                                            onPlaceNameChanged:
                                                (_) => setState(() {}),
                                            onContactChanged:
                                                (_) => _contactEdited = true,
                                            onSpaceKind: _onSpaceKind,
                                            onImport:
                                                ref
                                                        .read(
                                                          spaceBoardProvider,
                                                        )
                                                        .trades
                                                        .isEmpty
                                                    ? null
                                                    : _importTrade,
                                            anchors: _anchors,
                                          ),
                                        if (_step == 1)
                                          _NeedsStep(
                                            fontScale: fontScale,
                                            subGap: subGap,
                                            sectionGap: sectionGap,
                                            style: _style,
                                            period: _period,
                                            buildingCondition:
                                                _buildingCondition,
                                            workScope: _workScope,
                                            areaUnknown: _areaUnknown,
                                            areaRange: _areaRange,
                                            areaUnit: _areaUnit,
                                            onAreaUnit: _setAreaUnit,
                                            workPlace: _workPlace,
                                            targetRange: _targetRange,
                                            area: _area,
                                            budget: _budget,
                                            needs: _needs,
                                            styleNote: _styleNote,
                                            onStyle:
                                                (String value) => setState(
                                                  () => _style = value,
                                                ),
                                            onBuildingCondition:
                                                (String value) => setState(
                                                  () =>
                                                      _buildingCondition =
                                                          value,
                                                ),
                                            onWorkScope: _onWorkScope,
                                            onAreaUnknown:
                                                () => setState(() {
                                                  _areaUnknown = !_areaUnknown;
                                                  if (_areaUnknown) {
                                                    _area.clear();
                                                    _areaRange = null;
                                                  }
                                                }),
                                            onAreaRange: _onAreaRange,
                                            onAreaChanged: (String value) {
                                              if (value.trim().isNotEmpty &&
                                                  _areaUnknown) {
                                                setState(
                                                  () => _areaUnknown = false,
                                                );
                                              }
                                            },
                                            budgetUndecided: _budgetUndecided,
                                            budgetRange: _budgetRange,
                                            onBudgetChanged: (String value) {
                                              if (value.trim().isNotEmpty &&
                                                  _budgetUndecided) {
                                                setState(
                                                  () =>
                                                      _budgetUndecided = false,
                                                );
                                              }
                                            },
                                            onBudgetRange: _onBudgetRange,
                                            onBudgetUndecided:
                                                _onBudgetUndecided,
                                            startTiming: _startTiming,
                                            openTiming: _openTiming,
                                            onStartTiming:
                                                (String value) => setState(
                                                  () => _startTiming = value,
                                                ),
                                            onOpenTiming:
                                                (String value) => setState(
                                                  () => _openTiming = value,
                                                ),
                                            onPeriod:
                                                (String value) => setState(() {
                                                  _period = value;
                                                  _targetRange = null;
                                                }),
                                            onPickDate: _pickTargetRange,
                                            onClearDate:
                                                () => setState(
                                                  () => _targetRange = null,
                                                ),
                                            floorPlans: _floorPlans,
                                            stylePhotos: _stylePhotos,
                                            onAddFloorPlan:
                                                () =>
                                                    _addPhoto(floorPlan: true),
                                            onOpenFloorPlan:
                                                (
                                                  ShowroomReferenceRegion
                                                  region,
                                                ) => _openPhoto(
                                                  region,
                                                  floorPlan: true,
                                                ),
                                            onRemoveFloorPlan:
                                                (
                                                  ShowroomReferenceRegion
                                                  region,
                                                ) => setState(
                                                  () => _floorPlans.remove(
                                                    region,
                                                  ),
                                                ),
                                            onAddStylePhoto:
                                                () =>
                                                    _addPhoto(floorPlan: false),
                                            onOpenStylePhoto:
                                                (
                                                  ShowroomReferenceRegion
                                                  region,
                                                ) => _openPhoto(
                                                  region,
                                                  floorPlan: false,
                                                ),
                                            onRemoveStylePhoto:
                                                (
                                                  ShowroomReferenceRegion
                                                  region,
                                                ) => setState(
                                                  () => _stylePhotos.remove(
                                                    region,
                                                  ),
                                                ),
                                            anchors: _anchors,
                                          ),
                                        if (_step == 2)
                                          _DetailStep(
                                            fontScale: fontScale,
                                            subGap: subGap,
                                            choices: _finishChoices,
                                            notes: _finishNotes,
                                            onPick: _pickFinish,
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
                              padding: EdgeInsets.only(
                                top: messagePad,
                                bottom: messagePad,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child:
                                    _error == null
                                        ? const SizedBox.shrink()
                                        : Material(
                                          color: AppColors.error.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: InkWell(
                                            onTap: _revealError,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _error!,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize:
                                                            13 * fontScale,
                                                        height: 1.35,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            AppColors.error,
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ),
                                                  if (_errorAbove != null) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      _errorAbove!
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward,
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
                            label: switch (_step) {
                              0 => '조건설정 넘어가기',
                              1 => '마감 선택 넘어가기',
                              _ => '상담준비 저장',
                            },
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

  bool get _isDirty => _draftSignature() != _openedDraft;

  String _draftSignature() {
    final PrepRecord record = _currentRecord;
    return <String>[
      record.placeName,
      record.address,
      record.detailAddress,
      record.area,
      record.buildingCondition,
      record.style,
      record.budget,
      record.period,
      record.periodStart?.millisecondsSinceEpoch.toString() ?? '',
      record.periodEnd?.millisecondsSinceEpoch.toString() ?? '',
      record.needs,
      record.floorPlanLabels.join('\u0001'),
      record.referenceImageLabels.join('\u0001'),
      _regionSignature(record.floorPlans),
      _regionSignature(record.stylePhotos),
      record.industry,
      record.industryGroup,
      record.secondaryIndustries.join('\u0001'),
      record.areaRange,
      record.budgetRange,
      record.startTiming,
      record.openTiming,
      record.workScope,
      record.contact,
      record.workPlace,
      _finishSignature(record.finishes),
      _styleRefSignature(record.styleRef),
    ].join('\u0002');
  }

  String _regionSignature(List<ShowroomReferenceRegion> regions) {
    return [
      for (final ShowroomReferenceRegion region in regions)
        [
          region.id,
          region.label,
          region.imageUrl,
          region.note,
          region.asIs.toString(),
          region.crop == null
              ? ''
              : '${region.crop!.left},${region.crop!.top},${region.crop!.width},${region.crop!.height}',
          for (final ShowroomReferenceMark mark in region.marks)
            [
              mark.kind.name,
              mark.color.toString(),
              mark.left?.toString() ?? '',
              mark.top?.toString() ?? '',
              mark.width?.toString() ?? '',
              mark.height?.toString() ?? '',
              for (final ShowroomReferencePoint point in mark.points)
                '${point.x},${point.y}',
            ].join(','),
        ].join('|'),
    ].join('\u0001');
  }

  String _finishSignature(Map<String, PrepFinishAnswer> finishes) {
    final List<String> keys = finishes.keys.toList()..sort();
    return [
      for (final String key in keys)
        '$key:${finishes[key]!.choices.join(',')}:${finishes[key]!.note}',
    ].join('\u0001');
  }

  String _styleRefSignature(ShowroomStyleRef? reference) {
    if (reference == null) return '';
    return [
      reference.showroomId,
      reference.title,
      reference.imageUrl,
      reference.aspects.join(','),
      reference.note,
      _regionSignature(reference.regions),
    ].join('|');
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
    if (_recordId.isEmpty)
      _recordId = 'consult-${DateTime.now().microsecondsSinceEpoch}';
    ref.read(spaceBoardProvider).saveConsult(_currentRecord);
  }

  Future<void> _leaveForm() async {
    if (!_isDirty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final String? choice = await showAppDialog<String>(
      context: context,
      title: '지금까지 저장할까요?',
      message: '지금 적은 만큼만 저장해 둘 수 있어요. 비어 있는 항목이 있어도 되고, 상담 신청은 나중에 해도 돼요.',
      actions:
          (BuildContext dialogContext) => [
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

class _SiteStep extends StatelessWidget {
  const _SiteStep({
    required this.fontScale,
    required this.subGap,
    required this.sectionGap,
    required this.address,
    required this.detailAddress,
    required this.buildingName,
    required this.industry,
    required this.industryGroup,
    required this.secondaryBrowse,
    required this.secondaryIndustries,
    required this.industryNote,
    required this.contact,
    required this.tempPlaceName,
    required this.onIndustry,
    required this.onIndustryGroup,
    required this.onPrimaryDetail,
    required this.onSecondaryBrowse,
    required this.onToggleSecondary,
    required this.onPlaceNameChanged,
    required this.onContactChanged,
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
  final String? industryGroup;
  final String? secondaryBrowse;
  final List<String> secondaryIndustries;
  final TextEditingController industryNote;
  final TextEditingController contact;
  final String tempPlaceName;
  final ValueChanged<String> onIndustry;
  final ValueChanged<String> onIndustryGroup;
  final ValueChanged<String> onPrimaryDetail;
  final ValueChanged<String> onSecondaryBrowse;
  final ValueChanged<String> onToggleSecondary;
  final ValueChanged<String> onPlaceNameChanged;
  final ValueChanged<String> onContactChanged;
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: subGap),
        ],
        _FormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label: PrepSurvey.space.title, fontScale: fontScale),
              SizedBox(height: subGap),
              _OptionSegment(
                values: PrepSurvey.space.choices,
                selected: PrepSurvey.commercial,
                fontScale: fontScale,
                onSelected: onSpaceKind,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.space.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
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
              _FieldLabel(
                label: PrepSurvey.address.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              _AddressSearchField(
                address: address.text,
                fontScale: fontScale,
                onTap: onSearchAddress,
              ),
              SizedBox(height: sectionGap),
              _FieldLabel(
                label: PrepSurvey.detailAddress.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: detailAddress,
                hint: PrepSurvey.detailAddress.hint!,
              ),
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.placeName,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(
                label: PrepSurvey.placeName.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.placeName.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: buildingName,
                hint: PrepSurvey.placeName.hint!,
                onChanged: onPlaceNameChanged,
              ),
              if (tempPlaceName.isNotEmpty) ...[
                SizedBox(height: subGap * 0.5),
                Text(
                  '비워 두면 $tempPlaceName으로 저장해요.',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: subGap),
        _FormSection(
          key: anchors.industry,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(
                label: PrepSurvey.industry.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.industry.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.industry.choices,
                selected: industryGroup == null ? industry : null,
                fontScale: fontScale,
                onSelected: onIndustry,
              ),
              if (industry == PrepSurvey.industryOther) ...[
                SizedBox(height: subGap),
                _PrepTextField(
                  controller: industryNote,
                  hint: PrepSurvey.industry.hint!,
                ),
              ],
              SizedBox(height: sectionGap),
              Text(
                '대분류',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.industryGroups,
                selected: industryGroup,
                fontScale: fontScale,
                onSelected: onIndustryGroup,
              ),
              if (industryGroup != null) ...[
                SizedBox(height: sectionGap),
                Text(
                  '세부업종',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: subGap),
                _ChoiceWrap(
                  values: PrepSurvey.detailsOf(industryGroup),
                  selected: industry,
                  fontScale: fontScale,
                  onSelected: onPrimaryDetail,
                ),
              ],
              SizedBox(height: sectionGap),
              Text(
                '보조 업종',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: subGap * 0.5),
              Text(
                '대표 업종 외에 함께 있는 업종을 고를 수 있어요.',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.industryGroups,
                selected: secondaryBrowse,
                fontScale: fontScale,
                onSelected: onSecondaryBrowse,
              ),
              if (PrepSurvey.detailsOf(secondaryBrowse).isNotEmpty) ...[
                SizedBox(height: subGap),
                _ChoiceWrap(
                  values: [
                    for (final String name in PrepSurvey.detailsOf(
                      secondaryBrowse,
                    ))
                      if (name != industry) name,
                  ],
                  picked: secondaryIndustries.toSet(),
                  fontScale: fontScale,
                  onSelected: onToggleSecondary,
                ),
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
              _FieldLabel(
                label: PrepSurvey.contact.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.contact.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: contact,
                hint: PrepSurvey.contact.hint!,
                keyboardType: TextInputType.number,
                inputFormatters: const [_KoreanMobileFormatter()],
                onChanged: onContactChanged,
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
                                  color:
                                      value == selected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
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
    required this.style,
    required this.period,
    required this.buildingCondition,
    required this.workScope,
    required this.areaUnknown,
    required this.areaRange,
    required this.areaUnit,
    required this.onAreaUnit,
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
    required this.onAreaRange,
    required this.onAreaChanged,
    required this.budgetUndecided,
    required this.budgetRange,
    required this.onBudgetChanged,
    required this.onBudgetRange,
    required this.onBudgetUndecided,
    required this.startTiming,
    required this.openTiming,
    required this.onStartTiming,
    required this.onOpenTiming,
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
  final String? style;
  final String? period;
  final String? buildingCondition;
  final String? workScope;
  final bool areaUnknown;
  final String? areaRange;
  final _AreaUnit areaUnit;
  final ValueChanged<_AreaUnit> onAreaUnit;
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
  final ValueChanged<String> onAreaRange;
  final ValueChanged<String> onAreaChanged;
  final bool budgetUndecided;
  final String? budgetRange;
  final ValueChanged<String> onBudgetChanged;
  final ValueChanged<String> onBudgetRange;
  final VoidCallback onBudgetUndecided;
  final String? startTiming;
  final String? openTiming;
  final ValueChanged<String> onStartTiming;
  final ValueChanged<String> onOpenTiming;
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormSection(
          key: anchors.workScope,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(
                label: PrepSurvey.workScope.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.workScope.choices,
                selected: workScope,
                fontScale: fontScale,
                onSelected: onWorkScope,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.workScope.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              if (workScope == PrepLabels.partialWork) ...[
                SizedBox(height: subGap),
                Text(
                  PrepSurvey.partialPlaceHelp,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.4,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: subGap),
                _PrepTextField(
                  controller: workPlace,
                  hint: PrepSurvey.partialPlaceHint,
                  maxLines: 2,
                ),
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
                  _FieldLabel(
                    label: PrepSurvey.area.title,
                    fontScale: fontScale,
                  ),
                  const Spacer(),
                  _AreaUnitSwitch(
                    unit: areaUnit,
                    fontScale: fontScale,
                    onChanged: onAreaUnit,
                  ),
                ],
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: area,
                hint: areaUnit == _AreaUnit.pyeong ? '예: 32' : '예: 106',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const <TextInputFormatter>[
                  _DecimalFormatter(),
                ],
                suffixText: _areaUnitLabel(areaUnit),
                onChanged: onAreaChanged,
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.areaRanges,
                selected: areaRange,
                fontScale: fontScale,
                onSelected: onAreaRange,
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.area.choices,
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
              _FieldLabel(
                label: PrepSurvey.demolition.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.demolition.choices,
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
              _FieldLabel(label: PrepSurvey.style.title, fontScale: fontScale),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.style.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.style.choices,
                selected: style,
                fontScale: fontScale,
                onSelected: onStyle,
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: styleNote,
                hint: PrepSurvey.style.hint!,
              ),
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
              _FieldLabel(label: PrepSurvey.budget.title, fontScale: fontScale),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.budget.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: budget,
                hint: PrepSurvey.budget.hint!,
                keyboardType: TextInputType.number,
                inputFormatters: const <TextInputFormatter>[
                  _GroupedIntFormatter(),
                ],
                suffixText: '원',
                onChanged: onBudgetChanged,
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.budgetRanges,
                selected: budgetRange,
                fontScale: fontScale,
                onSelected: onBudgetRange,
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
              _FieldLabel(label: PrepSurvey.period.title, fontScale: fontScale),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.period.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.period.choices,
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
              SizedBox(height: sectionGap),
              _FieldLabel(
                label: PrepSurvey.startTiming.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.startTiming.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.startTiming.choices,
                selected: startTiming,
                fontScale: fontScale,
                onSelected: onStartTiming,
              ),
              SizedBox(height: sectionGap),
              _FieldLabel(
                label: PrepSurvey.openTiming.title,
                fontScale: fontScale,
              ),
              SizedBox(height: subGap),
              Text(
                PrepSurvey.openTiming.help!,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: subGap),
              _ChoiceWrap(
                values: PrepSurvey.openTiming.choices,
                selected: openTiming,
                fontScale: fontScale,
                onSelected: onOpenTiming,
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
              _FieldLabel(label: PrepSurvey.needs.title, fontScale: fontScale),
              SizedBox(height: subGap),
              _PrepTextField(
                controller: needs,
                hint: PrepSurvey.needs.hint!,
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
      child: Padding(padding: EdgeInsets.all(pad), child: child),
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
        Text(body, style: TextStyle(fontSize: 14 * fontScale, height: 1.4)),
      ],
    );
  }
}

enum _AreaUnit { pyeong, squareMeter }

const double _sqmPerPyeong = 3.305785;

String _areaUnitLabel(_AreaUnit unit) => unit == _AreaUnit.pyeong ? '평' : '㎡';

_AreaUnit _areaUnitOf(String saved) =>
    saved.endsWith('㎡') ? _AreaUnit.squareMeter : _AreaUnit.pyeong;

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
  if ((rounded - rounded.roundToDouble()).abs() < 0.05)
    return rounded.round().toString();
  return rounded.toStringAsFixed(1);
}

class _AreaUnitSwitch extends StatelessWidget {
  const _AreaUnitSwitch({
    required this.unit,
    required this.fontScale,
    required this.onChanged,
  });

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
                    color:
                        item == unit ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      _areaUnitLabel(item),
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w700,
                        color:
                            item == unit
                                ? AppColors.white
                                : AppColors.textSecondary,
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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty ||
        RegExp(r'^\d*\.?\d{0,1}$').hasMatch(newValue.text)) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w700,
              ),
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
    if (digits.length > 1) digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
      digitCursor = digitCursor.clamp(0, 12);
    }
    digitCursor = digitCursor.clamp(0, digits.length);
    final String formatted = _groupDigits(digits);
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
        suffixStyle: TextStyle(
          fontSize: 15 * fontScale,
          color: const Color(0xFF1A1A1A),
        ),
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

class _DetailStep extends StatefulWidget {
  const _DetailStep({
    required this.fontScale,
    required this.subGap,
    required this.choices,
    required this.notes,
    required this.onPick,
  });

  final double fontScale;
  final double subGap;
  final Map<String, List<String>> choices;
  final Map<String, TextEditingController> notes;
  final void Function(PrepQuestion question, String value) onPick;

  @override
  State<_DetailStep> createState() => _DetailStepState();
}

class _DetailStepState extends State<_DetailStep> {
  late final Set<String> _open = <String>{
    for (final PrepQuestion question in PrepSurvey.details)
      if (_hasAnswer(question)) question.id,
  };

  bool _hasAnswer(PrepQuestion question) {
    final bool picked = widget.choices[question.id]?.isNotEmpty ?? false;
    final bool written =
        widget.notes[question.id]?.text.trim().isNotEmpty ?? false;
    return picked || written;
  }

  void _toggle(String id) {
    setState(() {
      if (!_open.add(id)) {
        _open.remove(id);
      }
    });
  }

  String _summary(PrepQuestion question) {
    final List<String> selected =
        widget.choices[question.id] ?? const <String>[];
    final String note = widget.notes[question.id]?.text.trim() ?? '';
    if (selected.isEmpty && note.isEmpty)
      return '${question.options.length}가지가 있어요';
    if (note.isEmpty) return selected.join(', ');
    if (selected.isEmpty) return note;
    return '${selected.join(', ')} · $note';
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = widget.fontScale;
    final double subGap = widget.subGap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OptionalMark(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '항목을 펼치면 선택지가 모두 보여요. 없어도 저장되고, 비용은 저렴·보통·비쌈의 감각만 보여 드려요.',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: subGap),
        for (final PrepQuestion question in PrepSurvey.details) ...[
          _FormSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggle(question.id),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (widget.choices[question.id]?.isNotEmpty ??
                                    false) ...[
                                  const DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Text(
                                    question.title,
                                    style: TextStyle(
                                      fontSize: 16 * fontScale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const _OptionalMark(),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _summary(question),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                height: 1.35,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _open.contains(question.id) ? '접기' : '펼치기',
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(
                              _open.contains(question.id)
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child:
                        _open.contains(question.id)
                            ? Padding(
                              padding: EdgeInsets.only(top: subGap),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final PrepFinishOption option
                                      in question.options) ...[
                                    _FinishOptionCard(
                                      option: option,
                                      selected:
                                          widget.choices[question.id]?.contains(
                                            option.label,
                                          ) ??
                                          false,
                                      fontScale: fontScale,
                                      onTap:
                                          () => widget.onPick(
                                            question,
                                            option.label,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  Text(
                                    '직접 입력',
                                    style: TextStyle(
                                      fontSize: 13 * fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: subGap * 0.5),
                                  _PrepTextField(
                                    controller: widget.notes[question.id]!,
                                    hint: question.hint ?? '',
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox(width: double.infinity),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: subGap),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _OptionalMark extends StatelessWidget {
  const _OptionalMark();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          '선택사항',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _FinishOptionCard extends StatelessWidget {
  const _FinishOptionCard({
    required this.option,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final PrepFinishOption option;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _FinishOptionImage(option: option),
                      if (selected)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (option.description case final String text) ...[
                        const SizedBox(height: 6),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (option.cost case final PrepCostBand cost) ...[
                        const SizedBox(height: 10),
                        _CostBandChip(cost: cost, fontScale: fontScale),
                      ],
                    ],
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

class _FinishOptionImage extends StatelessWidget {
  const _FinishOptionImage({required this.option});

  final PrepFinishOption option;

  @override
  Widget build(BuildContext context) {
    final String? url = option.imageUrl;
    if (url != null && url.isNotEmpty) return AppNetworkImage(url: url);
    return ColoredBox(
      color:
          option.undecided
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.imagePlaceholder,
      child: Center(
        child: Icon(
          option.undecided ? Icons.forum_outlined : Icons.image_outlined,
          size: 28,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CostBandChip extends StatelessWidget {
  const _CostBandChip({required this.cost, required this.fontScale});

  final PrepCostBand cost;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final Color tone = switch (cost) {
      PrepCostBand.low => AppColors.accent,
      PrepCostBand.mid => AppColors.textSecondary,
      PrepCostBand.high => AppColors.primary,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          cost.label,
          style: TextStyle(
            fontSize: 11 * fontScale,
            fontWeight: FontWeight.w700,
            color: tone,
          ),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.fontScale,
    required this.onSelected,
    this.selected,
    this.picked = const <String>{},
  });

  final List<String> values;
  final String? selected;
  final Set<String> picked;
  final double fontScale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String value in values)
          Builder(
            builder: (BuildContext context) {
              final bool on =
                  picked.isEmpty ? selected == value : picked.contains(value);
              return ChoiceChip(
                label: Text(value),
                selected: on,
                onSelected: (_) => onSelected(value),
                labelStyle: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: on ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
                ),
                selectedColor: const Color(0xFF111111),
                backgroundColor: AppColors.background,
                side: BorderSide(
                  color: on ? const Color(0xFF111111) : const Color(0xFFE4E4E4),
                ),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            },
          ),
      ],
    );
  }
}
