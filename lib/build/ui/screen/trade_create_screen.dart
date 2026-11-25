import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/kakao_address_search_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/cover_photo_field.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/form_parts.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/form_step_header.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/trade_detail_screen.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

/// 입지 선정에서 저장해 두는 곳. 성공 여부를 묻거나 점수를 만들지 않는다.
class TradeCreateScreen extends ConsumerStatefulWidget {
  const TradeCreateScreen({super.key, this.initial});

  final TradeCandidate? initial;

  @override
  ConsumerState<TradeCreateScreen> createState() => _TradeCreateScreenState();
}

class _TradeCreateScreenState extends ConsumerState<TradeCreateScreen> {
  static const List<String> _steps = ['위치', '주변 환경', '비용·메모'];

  final TextEditingController _name = TextEditingController();
  final TextEditingController _industryNote = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _detailAddress = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _nearbyTrades = TextEditingController();
  final TextEditingController _deposit = TextEditingController();
  final TextEditingController _rent = TextEditingController();
  final TextEditingController _maintenance = TextEditingController();
  final TextEditingController _premium = TextEditingController();
  final TextEditingController _reason = TextEditingController();

  int _step = 0;
  bool _saved = false;
  String _id = '';
  String? _industry;
  bool _areaUnknown = false;
  String? _access;
  String? _transit;
  String? _parking;
  String? _sameIndustry;
  String? _timeBand;
  String? _visitor;
  bool _rentUnknown = false;
  List<String> _interiorNotes = [];
  String _coverPhoto = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    final TradeCandidate? initial = widget.initial;
    if (initial == null) return;
    _id = initial.id;
    _name.text = initial.name;
    _address.text = initial.address;
    _detailAddress.text = initial.detailAddress;
    _areaUnknown = initial.area == PrepLabels.areaUnknown;
    _area.text = _areaUnknown ? '' : initial.area;
    _landmark.text = initial.landmark;
    _nearbyTrades.text = initial.nearbyTrades;
    _deposit.text = initial.deposit;
    _rent.text = initial.rent;
    _maintenance.text = initial.maintenance;
    _premium.text = initial.premium;
    _reason.text = initial.reason;
    _access = initial.access;
    _transit = initial.transit;
    _parking = initial.parking;
    _sameIndustry = initial.sameIndustry;
    _timeBand = initial.timeBand;
    _visitor = initial.visitor;
    _rentUnknown = initial.rentUnknown;
    _interiorNotes = [...initial.interiorNotes];
    _coverPhoto = initial.coverPhoto;
    if (TradeChoices.industries.contains(initial.industry)) {
      _industry = initial.industry;
    } else if (initial.industry.isNotEmpty) {
      _industry = TradeChoices.industryOther;
      _industryNote.text = initial.industry;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _industryNote.dispose();
    _address.dispose();
    _detailAddress.dispose();
    _area.dispose();
    _landmark.dispose();
    _nearbyTrades.dispose();
    _deposit.dispose();
    _rent.dispose();
    _maintenance.dispose();
    _premium.dispose();
    _reason.dispose();
    super.dispose();
  }

  String get _industryValue {
    if (_industry == TradeChoices.industryOther)
      return _industryNote.text.trim();
    return _industry ?? '';
  }

  TradeCandidate get _current {
    return TradeCandidate(
      id: _id,
      name: _name.text.trim(),
      industry: _industryValue,
      address: _address.text.trim(),
      detailAddress: _detailAddress.text.trim(),
      area: _areaUnknown ? PrepLabels.areaUnknown : _area.text.trim(),
      access: _access ?? '',
      transit: _transit ?? '',
      parking: _parking ?? '',
      landmark: _landmark.text.trim(),
      sameIndustry: _sameIndustry ?? '',
      nearbyTrades: _nearbyTrades.text.trim(),
      timeBand: _timeBand ?? '',
      visitor: _visitor ?? '',
      deposit: _rentUnknown ? '' : _deposit.text.trim(),
      rent: _rentUnknown ? '' : _rent.text.trim(),
      maintenance: _rentUnknown ? '' : _maintenance.text.trim(),
      premium: _rentUnknown ? '' : _premium.text.trim(),
      rentUnknown: _rentUnknown,
      reason: _reason.text.trim(),
      interiorNotes: _interiorNotes,
      coverPhoto: _coverPhoto,
    );
  }

  String? _validate() {
    if (_step == 0) {
      if (_name.text.trim().isEmpty) return '입지 이름을 적어 주세요';
      if (_industry == null) return '업종을 골라 주세요';
      if (_industry == TradeChoices.industryOther &&
          _industryNote.text.trim().isEmpty) {
        return '업종을 적어 주세요';
      }
      if (_address.text.trim().isEmpty) return '주소를 검색해 주세요';
    }
    if (_step == 1) {
      if (_access == null) return '길이 어떤지 골라 주세요';
      if (_transit == null) return '어떻게 오는지 골라 주세요';
      if (_parking == null) return '주차를 골라 주세요';
      if (_sameIndustry == null) return '같은 업종이 얼마나 있는지 골라 주세요';
      if (_timeBand == null) return '붐비는 시간대를 골라 주세요';
      if (_visitor == null) return '주로 누가 오는지 골라 주세요';
    }
    return null;
  }

  void _back() {
    if (_saved) {
      Navigator.of(context).pop();
      return;
    }
    if (_step > 0) {
      setState(() {
        _step -= 1;
        _error = null;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  void _next() {
    final String? error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (_step >= _steps.length - 1) {
      if (_id.isEmpty) _id = 'trade-${DateTime.now().microsecondsSinceEpoch}';
      ref.read(spaceBoardProvider).saveTrade(_current);
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

  Future<void> _searchAddress() async {
    final String? picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const KakaoAddressSearchScreen()),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    setState(() => _address.text = picked);
  }

  void _toggleNote(String value) {
    setState(() {
      if (_interiorNotes.contains(value)) {
        _interiorNotes = [..._interiorNotes]..remove(value);
      } else {
        _interiorNotes = [..._interiorNotes, value];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: _saved || _step == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || _saved) return;
        setState(() {
          _step -= 1;
          _error = null;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            _saved
                ? '저장한 입지'
                : widget.initial == null
                ? '입지 추가'
                : '입지 수정',
          ),
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
                    ? TradeDetailView(
                      candidate: _current,
                      onEdit:
                          () => setState(() {
                            _saved = false;
                            _step = 0;
                            _error = null;
                          }),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormStepHeader(
                          steps: _steps,
                          index: _step,
                          fontScale: fontScale,
                        ),
                        SizedBox(height: sectionGap),
                        Expanded(
                          child: ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              bottom: keyboardInset + sectionGap,
                            ),
                            children: [
                              if (_step == 0) ..._placeStep(subGap),
                              if (_step == 1) ..._aroundStep(subGap),
                              if (_step == 2) ..._memoStep(subGap),
                            ],
                          ),
                        ),
                        if (_error != null) ...[
                          SizedBox(height: subGap),
                          _ErrorLine(text: _error!, fontScale: fontScale),
                        ],
                        SizedBox(height: subGap * 0.75),
                        AppButton(
                          label: _step < _steps.length - 1 ? '다음' : '입지 저장',
                          onPressed: _next,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  List<Widget> _placeStep(double subGap) {
    final double gap = subGap * 1.25;
    return [
      const FormIntro(
        title: '어디를 보고 있나요',
        body: '사진과 주소, 용도만 남겨 두면 주변을 함께 볼 수 있어요.',
      ),
      SizedBox(height: gap * 1.4),
      FormCard(
        title: '공간 사진',
        optional: true,
        child: CoverPhotoField(
          photo: _coverPhoto,
          onChanged: (String value) => setState(() => _coverPhoto = value),
        ),
      ),
      SizedBox(height: gap),
      FormCard(
        title: '이름과 용도',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormItem(
              label: '입지 이름',
              child: FormTextInput(
                controller: _name,
                hint: '예: 합정역 1층, 성수 오피스 3층',
              ),
            ),
            SizedBox(height: gap),
            FormItem(
              label: '업종',
              child: FormChoiceChips(
                values: TradeChoices.industries,
                isSelected: (String value) => value == _industry,
                onTap: (String value) => setState(() => _industry = value),
              ),
            ),
            if (_industry == TradeChoices.industryOther) ...[
              SizedBox(height: subGap),
              FormTextInput(controller: _industryNote, hint: '예: 복지시설, 창고'),
            ],
          ],
        ),
      ),
      SizedBox(height: gap),
      FormCard(
        title: '위치',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormAddressInput(address: _address.text, onTap: _searchAddress),
            SizedBox(height: subGap),
            FormTextInput(controller: _detailAddress, hint: '층·호수 (예: 1층)'),
          ],
        ),
      ),
      SizedBox(height: gap),
      FormCard(
        title: '대략 평수',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormTextInput(
              controller: _area,
              hint: _areaUnknown ? '잘 몰라도 괜찮아요' : '예: 20',
              suffixText: '평',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (String value) {
                if (value.trim().isNotEmpty && _areaUnknown) {
                  setState(() => _areaUnknown = false);
                }
              },
            ),
            SizedBox(height: subGap),
            FormChoiceChips(
              values: const [PrepLabels.areaUnknown],
              isSelected: (_) => _areaUnknown,
              onTap:
                  (_) => setState(() {
                    _areaUnknown = !_areaUnknown;
                    if (_areaUnknown) _area.clear();
                  }),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _aroundStep(double subGap) {
    final double gap = subGap * 1.25;
    return [
      const FormIntro(
        title: '주변에서 보이는 것만',
        body: '눈으로 본 것만 고르면 돼요. 모르면 "잘 모르겠어요"를 골라 주세요.',
      ),
      SizedBox(height: gap * 1.4),
      FormCard(
        title: '길과 이동',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _choice('길은 어떤가요', TradeChoices.access, _access, (String v) {
              _access = v;
            }),
            SizedBox(height: gap),
            _choice('어떻게 오나요', TradeChoices.transit, _transit, (String v) {
              _transit = v;
            }),
            SizedBox(height: gap),
            _choice('주차', TradeChoices.parking, _parking, (String v) {
              _parking = v;
            }),
          ],
        ),
      ),
      SizedBox(height: gap),
      FormCard(
        title: '주변 가게',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _choice(
              '같은 업종이 보이나요',
              TradeChoices.sameIndustry,
              _sameIndustry,
              (String v) => _sameIndustry = v,
            ),
            SizedBox(height: gap),
            FormItem(
              label: '주변에 많은 업종',
              optional: true,
              child: FormTextInput(
                controller: _nearbyTrades,
                hint: '예: 카페, 편의점',
              ),
            ),
            SizedBox(height: gap),
            FormItem(
              label: '눈에 띄는 주변',
              optional: true,
              child: FormTextInput(
                controller: _landmark,
                hint: '예: 지하철역, 오피스, 학교',
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: gap),
      FormCard(
        title: '사람',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _choice(
              '붐비는 시간',
              TradeChoices.timeBand,
              _timeBand,
              (String v) => _timeBand = v,
            ),
            SizedBox(height: gap),
            _choice(
              '주로 누가 지나나요',
              TradeChoices.visitor,
              _visitor,
              (String v) => _visitor = v,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _memoStep(double subGap) {
    final double gap = subGap * 1.25;
    return [
      const FormIntro(title: '아는 비용과 메모', body: '이미 들은 조건만 적어요. 모르면 비워 둬도 돼요.'),
      SizedBox(height: gap * 1.4),
      FormCard(
        title: '임대 조건',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormToggleRow(
              label: '아직 몰라요',
              value: _rentUnknown,
              onChanged: (bool value) => setState(() => _rentUnknown = value),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child:
                  _rentUnknown
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                        padding: EdgeInsets.only(top: gap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: FormItem(
                                    label: '보증금',
                                    child: FormTextInput(
                                      controller: _deposit,
                                      hint: '5,000만 원',
                                    ),
                                  ),
                                ),
                                SizedBox(width: subGap),
                                Expanded(
                                  child: FormItem(
                                    label: '월세',
                                    child: FormTextInput(
                                      controller: _rent,
                                      hint: '250만 원',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: gap),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: FormItem(
                                    label: '관리비',
                                    child: FormTextInput(
                                      controller: _maintenance,
                                      hint: '20만 원',
                                    ),
                                  ),
                                ),
                                SizedBox(width: subGap),
                                Expanded(
                                  child: FormItem(
                                    label: '권리금',
                                    child: FormTextInput(
                                      controller: _premium,
                                      hint: '없음',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
      SizedBox(height: gap),
      FormCard(
        title: '메모',
        optional: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormItem(
              label: '이곳을 보는 이유',
              child: FormTextInput(
                controller: _reason,
                hint: '예: 코너라 간판이 보일 것 같아요',
                maxLines: 4,
              ),
            ),
            SizedBox(height: gap),
            FormItem(
              label: '인테리어에서 먼저 볼 점',
              help: '여러 개 골라도 돼요.',
              child: FormChoiceChips(
                values: TradeChoices.interiorNotes,
                isSelected: _interiorNotes.contains,
                onTap: _toggleNote,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _choice(
    String label,
    List<String> values,
    String? selected,
    ValueChanged<String> onSelected,
  ) {
    return FormItem(
      label: label,
      child: FormChoiceChips(
        values: values,
        isSelected: (String value) => value == selected,
        onTap: (String value) => setState(() => onSelected(value)),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.text, required this.fontScale});

  final String text;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 18, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
