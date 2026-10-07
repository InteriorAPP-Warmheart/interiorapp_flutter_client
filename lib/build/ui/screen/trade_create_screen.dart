import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/kakao_address_search_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/trade_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

/// 상권 분석 전에 남겨 두는 후보지. 성공 여부를 묻거나 점수를 만들지 않는다.
class TradeCreateScreen extends StatefulWidget {
  const TradeCreateScreen({super.key, this.initial});

  final TradeCandidate? initial;

  @override
  State<TradeCreateScreen> createState() => _TradeCreateScreenState();
}

class _TradeCreateScreenState extends State<TradeCreateScreen> {
  static const List<String> _steps = ['자리', '주변', '메모'];

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
    if (_industry == TradeChoices.industryOther) return _industryNote.text.trim();
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
    );
  }

  String? _validate() {
    if (_step == 0) {
      if (_name.text.trim().isEmpty) return '후보지 이름을 적어 주세요';
      if (_industry == null) return '업종을 골라 주세요';
      if (_industry == TradeChoices.industryOther && _industryNote.text.trim().isEmpty) {
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

  void _next() {
    final String? error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (_step >= _steps.length - 1) {
      if (_id.isEmpty) _id = 'trade-${DateTime.now().microsecondsSinceEpoch}';
      SpaceBoard.instance.saveTrade(_current);
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
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('상권 후보지')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding.left, subGap, padding.right, subGap),
          child: _saved
              ? TradeDetailView(
                  candidate: _current,
                  onEdit: () => setState(() {
                    _saved = false;
                    _error = null;
                  }),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _steps[_step],
                      style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: subGap),
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(bottom: keyboardInset),
                        children: [
                          if (_step == 0) _placeStep(fontScale, subGap, sectionGap),
                          if (_step == 1) _aroundStep(fontScale, subGap, sectionGap),
                          if (_step == 2) _memoStep(fontScale, subGap, sectionGap),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      Text(_error!, style: TextStyle(fontSize: 13 * fontScale, color: const Color(0xFFB42318))),
                      SizedBox(height: subGap),
                    ],
                    AppButton(label: _step == _steps.length - 1 ? '후보지 저장' : '다음', onPressed: _next),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _placeStep(double fontScale, double subGap, double sectionGap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Lead(
          title: '어떤 자리를 볼까요',
          body: '주소와 업종을 남겨 두면 나중에 이 자리를 기준으로 상권을 볼 수 있어요. 지금은 잘된다, 안된다를 정하지 않아요.',
          fontScale: fontScale,
        ),
        SizedBox(height: sectionGap),
        _Label(label: '후보지 이름', fontScale: fontScale),
        SizedBox(height: subGap),
        _Field(controller: _name, hint: '예: 합정 식당 자리'),
        SizedBox(height: sectionGap),
        _Label(label: '업종', fontScale: fontScale),
        SizedBox(height: subGap),
        _Chips(
          values: TradeChoices.industries,
          selected: _industry == null ? const [] : [_industry!],
          fontScale: fontScale,
          onTap: (String value) => setState(() => _industry = value),
        ),
        if (_industry == TradeChoices.industryOther) ...[
          SizedBox(height: subGap),
          _Field(controller: _industryNote, hint: '예: 복지시설, 창고'),
        ],
        SizedBox(height: sectionGap),
        _Label(label: '주소', fontScale: fontScale),
        SizedBox(height: subGap),
        _AddressBox(address: _address.text, fontScale: fontScale, onTap: _searchAddress),
        SizedBox(height: sectionGap),
        _Label(label: '층·호수', fontScale: fontScale),
        SizedBox(height: subGap),
        _Field(controller: _detailAddress, hint: '예: 1층'),
        SizedBox(height: sectionGap),
        _Label(label: '대략 평수', fontScale: fontScale),
        SizedBox(height: subGap),
        _Field(
          controller: _area,
          hint: '예: 20',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (String value) {
            if (value.trim().isNotEmpty && _areaUnknown) setState(() => _areaUnknown = false);
          },
        ),
        SizedBox(height: subGap),
        _Chips(
          values: const [PrepLabels.areaUnknown],
          selected: _areaUnknown ? const [PrepLabels.areaUnknown] : const [],
          fontScale: fontScale,
          onTap: (_) => setState(() {
            _areaUnknown = !_areaUnknown;
            if (_areaUnknown) _area.clear();
          }),
        ),
      ],
    );
  }

  Widget _aroundStep(double fontScale, double subGap, double sectionGap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Lead(
          title: '주변에서 보이는 것만',
          body: '정확한 유동인구나 매출은 나중에 붙어요. 지금 눈으로 본 것과 모르는 것을 구분해 두면 돼요.',
          fontScale: fontScale,
        ),
        SizedBox(height: sectionGap),
        _choice('길은 어떤가요', TradeChoices.access, _access, (String value) => _access = value, fontScale, subGap),
        SizedBox(height: sectionGap),
        _choice('어떻게 오나요', TradeChoices.transit, _transit, (String value) => _transit = value, fontScale, subGap),
        SizedBox(height: sectionGap),
        _choice('주차', TradeChoices.parking, _parking, (String value) => _parking = value, fontScale, subGap),
        SizedBox(height: sectionGap),
        _Label(label: '눈에 띄는 주변', fontScale: fontScale),
        SizedBox(height: subGap),
        _Field(controller: _landmark, hint: '예: 지하철역, 오피스, 학교'),
        SizedBox(height: sectionGap),
        _choice(
          '같은 업종이 보이나요',
          TradeChoices.sameIndustry,
          _sameIndustry,
          (String value) => _sameIndustry = value,
          fontScale,
          subGap,
        ),
        SizedBox(height: sectionGap),
        _Label(label: '주변에 많은 업종', fontScale: fontScale),
        SizedBox(height: subGap),
        _Field(controller: _nearbyTrades, hint: '예: 카페, 편의점'),
        SizedBox(height: sectionGap),
        _choice('붐비는 시간', TradeChoices.timeBand, _timeBand, (String value) => _timeBand = value, fontScale, subGap),
        SizedBox(height: sectionGap),
        _choice('주로 누가 지나나요', TradeChoices.visitor, _visitor, (String value) => _visitor = value, fontScale, subGap),
        const SizedBox(height: 88),
      ],
    );
  }

  Widget _memoStep(double fontScale, double subGap, double sectionGap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Lead(
          title: '아는 비용과 메모',
          body: '임대료를 확정값처럼 추정하지 않아요. 이미 들은 조건만 적고, 모르면 그렇게 골라도 돼요.',
          fontScale: fontScale,
        ),
        SizedBox(height: sectionGap),
        _Chips(
          values: const ['임대 조건은 아직 몰라요'],
          selected: _rentUnknown ? const ['임대 조건은 아직 몰라요'] : const [],
          fontScale: fontScale,
          onTap: (_) => setState(() => _rentUnknown = !_rentUnknown),
        ),
        if (!_rentUnknown) ...[
          SizedBox(height: sectionGap),
          _Label(label: '보증금', fontScale: fontScale),
          SizedBox(height: subGap),
          _Field(controller: _deposit, hint: '예: 5,000만 원'),
          SizedBox(height: sectionGap),
          _Label(label: '월세', fontScale: fontScale),
          SizedBox(height: subGap),
          _Field(controller: _rent, hint: '예: 250만 원'),
          SizedBox(height: sectionGap),
          _Label(label: '관리비', fontScale: fontScale),
          SizedBox(height: subGap),
          _Field(controller: _maintenance, hint: '예: 20만 원'),
          SizedBox(height: sectionGap),
          _Label(label: '권리금', fontScale: fontScale),
          SizedBox(height: subGap),
          _Field(controller: _premium, hint: '예: 없음'),
        ],
        SizedBox(height: sectionGap),
        _Label(label: '이 자리를 보는 이유', fontScale: fontScale),
        SizedBox(height: subGap),
        _Field(controller: _reason, hint: '예: 코너라 간판이 보일 것 같아요', maxLines: 3),
        SizedBox(height: sectionGap),
        _Label(label: '인테리어에서 먼저 볼 점', fontScale: fontScale),
        SizedBox(height: subGap),
        Text(
          '이 자리라면 공간에서 뭘 먼저 볼지 골라 두세요. 없어도 돼요.',
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: subGap),
        _Chips(
          values: TradeChoices.interiorNotes,
          selected: _interiorNotes,
          fontScale: fontScale,
          onTap: _toggleNote,
        ),
        const SizedBox(height: 88),
      ],
    );
  }

  Widget _choice(
    String label,
    List<String> values,
    String? selected,
    ValueChanged<String> onSelected,
    double fontScale,
    double subGap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: label, fontScale: fontScale),
        SizedBox(height: subGap),
        _Chips(
          values: values,
          selected: selected == null ? const [] : [selected],
          fontScale: fontScale,
          onTap: (String value) => setState(() => onSelected(value)),
        ),
      ],
    );
  }
}

class _Lead extends StatelessWidget {
  const _Lead({required this.title, required this.body, required this.fontScale});

  final String title;
  final String body;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 22 * fontScale, fontWeight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 8),
        Text(body, style: TextStyle(fontSize: 14 * fontScale, height: 1.45, color: const Color(0xFF1A1A1A))),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, required this.fontScale});

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w700));
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
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

class _AddressBox extends StatelessWidget {
  const _AddressBox({required this.address, required this.fontScale, required this.onTap});

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
              const Icon(Icons.search, color: Color(0xFF1A1A1A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.values,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final List<String> values;
  final List<String> selected;
  final double fontScale;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String value in values)
          ChoiceChip(
            label: Text(value),
            selected: selected.contains(value),
            onSelected: (_) => onTap(value),
            labelStyle: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w600,
              color: selected.contains(value) ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
            ),
            selectedColor: const Color(0xFF111111),
            backgroundColor: const Color(0xFFFFFFFF),
            side: BorderSide(
              color: selected.contains(value) ? const Color(0xFF111111) : const Color(0xFFE4E4E4),
            ),
            showCheckmark: false,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
          ),
      ],
    );
  }
}
