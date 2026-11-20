import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

const String _mascot =
    'assets/mascot/showroom/wapll_mascot_assets/03_look_front.png';
const String _mascotHappy =
    'assets/mascot/showroom/wapll_mascot_assets/05_happy_sit_loop.png';

const List<String> _sections = <String>['소개', '비용', '직영', '앱', '커뮤니티', '시작'];

/// 첫 배너에서 여는 와플 소개. 모달이 아니라 스크롤하는 전체 화면이다.
class WapllIntroScreen extends StatefulWidget {
  const WapllIntroScreen({super.key});

  @override
  State<WapllIntroScreen> createState() => _WapllIntroScreenState();
}

class _WapllIntroScreenState extends State<WapllIntroScreen> {
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _keys = List<GlobalKey>.generate(
    _sections.length,
    (_) => GlobalKey(),
  );
  int _section = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncSection);
  }

  @override
  void dispose() {
    _scroll.removeListener(_syncSection);
    _scroll.dispose();
    super.dispose();
  }

  void _syncSection() {
    final double line =
        MediaQuery.paddingOf(context).top +
        ResponsiveSize.appBarHeight(context) +
        42;
    int next = 0;
    for (int i = 0; i < _keys.length; i++) {
      final BuildContext? target = _keys[i].currentContext;
      if (target == null) continue;
      final RenderObject? object = target.findRenderObject();
      if (object is! RenderBox || !object.hasSize) continue;
      if (object.localToGlobal(Offset.zero).dy - line <= 8) next = i;
    }
    if (next != _section) setState(() => _section = next);
  }

  void _goSection(int index) {
    final BuildContext? target = _keys[index].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  void _consult() => context.push(SpaceRoutes.prepCreate);

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final double gap = ResponsiveSize.sectionGap(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: ResponsiveSize.appBarHeight(context),
        title: const Text('와플'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: inset.left),
                itemCount: _sections.length,
                separatorBuilder: (_, _) => const SizedBox(width: 18),
                itemBuilder: (BuildContext context, int index) {
                  final bool selected = index == _section;
                  return GestureDetector(
                    onTap: () => _goSection(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _sections[index],
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color:
                                selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          width: 28,
                          color:
                              selected ? AppColors.primary : Colors.transparent,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(inset.left, 12, inset.right, 12),
            child: AppButton(label: '견적 상담하기', onPressed: _consult),
          ),
        ),
      ),
      body: ListView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(inset.left, 8, inset.right, 28),
        children: [
          _Hero(key: _keys[0], fontScale: fontScale),
          SizedBox(height: gap),
          _Cost(key: _keys[1], fontScale: fontScale),
          SizedBox(height: gap),
          _Direct(key: _keys[2], fontScale: fontScale),
          SizedBox(height: gap),
          _AppFlow(key: _keys[3], fontScale: fontScale),
          SizedBox(height: gap),
          _Community(key: _keys[4], fontScale: fontScale),
          SizedBox(height: gap),
          _Close(key: _keys[5], fontScale: fontScale),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({super.key, required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '인테리어의 새로운 기준, 와플',
                      style: TextStyle(
                        fontSize: 18 * fontScale,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '투명한 가격, 정직한 시공.',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(_mascot, width: 72, height: 72, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const <Widget>[
              Expanded(
                child: _Cell(
                  icon: Icons.receipt_long_outlined,
                  label: '투명한 가격',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _Cell(
                  icon: Icons.architecture_outlined,
                  label: '정직한 시공',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _Cell(icon: Icons.savings_outlined, label: '합리적인 제안'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cost extends StatelessWidget {
  const _Cost({super.key, required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(fontScale: fontScale, title: '공사비는 이렇게 나뉩니다'),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            children: [
              const Row(
                children: <Widget>[
                  Expanded(
                    child: _Cell(icon: Icons.layers_outlined, label: '자재비'),
                  ),
                  _Plus(),
                  Expanded(
                    child: _Cell(
                      icon: Icons.engineering_outlined,
                      label: '인건비',
                    ),
                  ),
                  _Plus(),
                  Expanded(
                    child: _Cell(icon: Icons.receipt_outlined, label: '경비'),
                  ),
                ],
              ),
              const _Down(),
              const _SumBar(label: '실제 공사 비용'),
              const _Down(),
              Row(
                children: [
                  Expanded(child: _ProfitBar(fontScale: fontScale)),
                  const SizedBox(width: 8),
                  Image.asset(
                    _mascotHappy,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '부가세와 별도·추가 공사는 견적에서 따로 안내합니다.',
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Compare(fontScale: fontScale),
      ],
    );
  }
}

class _Compare extends StatelessWidget {
  const _Compare({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '견적을 공개하는 방식',
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _QuoteColumn(title: '일반적인 견적', child: _Lump())),
              SizedBox(width: 8),
              Expanded(
                child: _QuoteColumn(title: '와플의 견적', child: _StackedQuote()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '모든 업체가 그렇다는 뜻은 아닙니다.',
            style: TextStyle(
              fontSize: 12 * fontScale,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Direct extends StatelessWidget {
  const _Direct({super.key, required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(fontScale: fontScale, title: '맡겨 둔 공사, 고르는 공사'),
        const SizedBox(height: 12),
        const _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _SideLabel(label: '도급 공사')),
                  SizedBox(width: 8),
                  Expanded(child: _SideLabel(label: '직영 공사', emphasis: true)),
                ],
              ),
              _IssuePair(problem: '믿을 수 없는 견적', advantage: '항목이 보이는 견적'),
              _IssuePair(problem: '전부 맡겨 둔 비용', advantage: '자재·인력을 선택'),
              _IssuePair(problem: '계속 추가되는 비용', advantage: '필요한 만큼만'),
              SizedBox(height: 8),
              _Assist(
                icon: Icons.verified_user_outlined,
                title: '감리',
                body: '믿을 만한 감리가 공사를 돕습니다',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppFlow extends StatelessWidget {
  const _AppFlow({super.key, required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(fontScale: fontScale, title: '상담부터 현장까지 한곳'),
        const SizedBox(height: 12),
        _Panel(child: _Timeline(fontScale: fontScale)),
      ],
    );
  }
}

class _Community extends StatelessWidget {
  const _Community({super.key, required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(fontScale: fontScale, title: '경험이 다음 사람에게'),
        const SizedBox(height: 12),
        const _Panel(
          child: Row(
            children: <Widget>[
              Expanded(
                child: _Cell(icon: Icons.compare_outlined, label: '시공 전후'),
              ),
              _Arrow(),
              Expanded(
                child: _Cell(icon: Icons.inventory_2_outlined, label: '자재 정보'),
              ),
              _Arrow(),
              Expanded(
                child: _Cell(icon: Icons.apartment_outlined, label: '다른 공간'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Close extends StatelessWidget {
  const _Close({super.key, required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '더 좋은 공간을 만드는\n새로운 방법.',
                      style: TextStyle(
                        fontSize: 18 * fontScale,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '이제 와플과 시작하세요.',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(_mascot, width: 72, height: 72, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Chip(label: '투명한 견적'),
              _Chip(label: '합리적인 시공'),
              _Chip(label: '이어지는 경험'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.fontScale, required this.title});

  final double fontScale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18 * fontScale,
        height: 1.35,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      child: Text(
        '+',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      child: Icon(
        Icons.arrow_forward_ios,
        size: 11,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _Down extends StatelessWidget {
  const _Down();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Icon(
        Icons.arrow_downward,
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SumBar extends StatelessWidget {
  const _SumBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProfitBar extends StatelessWidget {
  const _ProfitBar({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '10%',
            style: TextStyle(
              fontSize: 28 * fontScale,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '기업 이윤\n공사 비용 합계에 산정',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteColumn extends StatelessWidget {
  const _QuoteColumn({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Lump extends StatelessWidget {
  const _Lump();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 146,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '총액',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StackedQuote extends StatelessWidget {
  const _StackedQuote();

  static const List<(String, bool)> _rows = <(String, bool)>[
    ('자재비', false),
    ('인건비', false),
    ('경비', false),
    ('이윤 10%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _rows[i].$2 ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _rows[i].$1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _rows[i].$2 ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SideLabel extends StatelessWidget {
  const _SideLabel({required this.label, this.emphasis = false});

  final String label;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: emphasis ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _IssuePair extends StatelessWidget {
  const _IssuePair({required this.problem, required this.advantage});

  final String problem;
  final String advantage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: _Issue(label: problem)),
          const SizedBox(width: 8),
          Expanded(child: _Issue(label: advantage, good: true)),
        ],
      ),
    );
  }
}

class _Issue extends StatelessWidget {
  const _Issue({required this.label, this.good = false});

  final String label;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: good ? Border.all(color: AppColors.primary) : null,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            good ? Icons.check : Icons.close,
            size: 14,
            color: good ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: good ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Assist extends StatelessWidget {
  const _Assist({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary,
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

class _Timeline extends StatelessWidget {
  const _Timeline({required this.fontScale});

  final double fontScale;

  static const List<(String, String)> _nodes = <(String, String)>[
    ('1', '상담'),
    ('2', '진행'),
    ('3', '견적'),
    ('4', '자료'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: Stack(
        children: [
          const Positioned(
            top: 17,
            left: 20,
            right: 20,
            child: ColoredBox(
              color: AppColors.border,
              child: SizedBox(height: 2),
            ),
          ),
          Row(
            children: [
              for (final (String index, String label) in _nodes)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          index,
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DCE3)),
      ),
      child: child,
    );
  }
}
