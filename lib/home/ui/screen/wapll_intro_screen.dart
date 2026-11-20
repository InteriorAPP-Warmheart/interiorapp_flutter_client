import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_logo.dart';

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
  int? _picked;
  bool _driving = false;
  int _drive = 0;

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

  /// 탭 줄에 가장 가까운 섹션. 줄 위로 지나간 칸이 있으면 그중 마지막을 고른다.
  int _sectionAtLine() {
    final double line =
        MediaQuery.paddingOf(context).top +
        ResponsiveSize.appBarHeight(context) +
        42;
    int passed = 0;
    int nearest = 0;
    double nearestGap = double.infinity;
    for (int i = 0; i < _keys.length; i++) {
      final BuildContext? target = _keys[i].currentContext;
      if (target == null) continue;
      final RenderObject? object = target.findRenderObject();
      if (object is! RenderBox || !object.hasSize) continue;
      final double gap = object.localToGlobal(Offset.zero).dy - line;
      if (gap <= 12) passed = i;
      final double distance = gap.abs();
      if (distance < nearestGap) {
        nearestGap = distance;
        nearest = i;
      }
    }
    final bool atEnd =
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 1;
    return atEnd ? nearest : passed;
  }

  void _syncSection() {
    if (!_scroll.hasClients || _driving || _picked != null) return;
    final int next = _sectionAtLine();
    if (next != _section) setState(() => _section = next);
  }

  void _releaseDrive() {
    _driving = false;
    _drive++;
    _picked = null;
    _syncSection();
  }

  void _goSection(int index) {
    setState(() {
      _section = index;
      _picked = index;
    });
    final BuildContext? target = _keys[index].currentContext;
    if (target == null || !_scroll.hasClients) return;
    final RenderObject? object = target.findRenderObject();
    if (object is! RenderBox || !object.hasSize) return;
    final int ticket = ++_drive;
    _driving = true;
    _scroll.position
        .ensureVisible(
          object,
          alignment: 0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (!mounted || ticket != _drive) return;
          _driving = false;
        });
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: inset.left),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    for (int index = 0; index < _sections.length; index++)
                      _NavTab(
                        label: _sections[index],
                        selected: index == _section,
                        fontScale: fontScale,
                        onTap: () => _goSection(index),
                      ),
                  ],
                ),
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
      body: NotificationListener<ScrollStartNotification>(
        onNotification: (ScrollStartNotification notice) {
          if (notice.dragDetails != null) _releaseDrive();
          return false;
        },
        child: ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(inset.left, 8, inset.right, 28),
          children: [
            _Hero(key: _keys[0], fontScale: fontScale),
            SizedBox(height: gap),
            _Cost(key: _keys[1], fontScale: fontScale),
            SizedBox(height: gap),
            _Direct(key: _keys[2], fontScale: fontScale),
            SizedBox(height: gap),
            _AppFlow(key: _keys[3], fontScale: fontScale, scroll: _scroll),
            SizedBox(height: gap),
            _Community(key: _keys[4], fontScale: fontScale),
            SizedBox(height: gap),
            _Close(key: _keys[5], fontScale: fontScale),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: 14 * fontScale,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IntrinsicWidth(
              child: Column(
                children: <Widget>[
                  Text(label, maxLines: 1, softWrap: false, style: style),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: selected ? AppColors.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      ],
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
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: _PlainColumn(
                        title: '도급 공사',
                        lines: <String>[
                          '믿을 수 없는 견적',
                          '전부 맡겨 둔 비용',
                          '계속 추가되는 비용',
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _MarkedColumn(
                        title: '직영 공사',
                        lines: <String>['항목이 보이는 견적', '자재·인력을 선택', '필요한 만큼만'],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
  const _AppFlow({super.key, required this.fontScale, required this.scroll});

  final double fontScale;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(fontScale: fontScale, title: '상담부터 현장까지 한곳'),
        const SizedBox(height: 12),
        _Panel(child: _AppStage(fontScale: fontScale, scroll: scroll)),
      ],
    );
  }
}

const List<(String, String, IconData)> _appSteps = <(String, String, IconData)>[
  ('상담', '필요한 이야기', Icons.chat_bubble_outline),
  ('진행', '현장의 흐름', Icons.timeline_outlined),
  ('견적', '보이는 항목', Icons.receipt_long_outlined),
  ('자료', '남는 기록', Icons.folder_outlined),
];

class _AppStage extends StatefulWidget {
  const _AppStage({required this.fontScale, required this.scroll});

  final double fontScale;
  final ScrollController scroll;

  @override
  State<_AppStage> createState() => _AppStageState();
}

class _AppStageState extends State<_AppStage> {
  String? _photo;
  double _open = 0;

  @override
  void initState() {
    super.initState();
    widget.scroll.addListener(_onScroll);
    _loadPhoto();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant _AppStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scroll != widget.scroll) {
      oldWidget.scroll.removeListener(_onScroll);
      widget.scroll.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scroll.removeListener(_onScroll);
    super.dispose();
  }

  /// 구간 중심이 화면 아래에서 읽기 높이로 올라오면 0에서 1.
  /// 다시 올리면 같은 비율로 줄어 앱 안으로 들어간다.
  double _reveal() {
    final RenderObject? object = context.findRenderObject();
    if (object is! RenderBox || !object.hasSize || !object.attached) {
      return _open;
    }
    final double top = object.localToGlobal(Offset.zero).dy;
    final double center = top + object.size.height / 2;
    final double screen = MediaQuery.sizeOf(context).height;
    final double viewTop =
        MediaQuery.paddingOf(context).top +
        ResponsiveSize.appBarHeight(context) +
        42;
    final double viewHeight = screen - viewTop;
    final double start = viewTop + viewHeight * 0.92;
    final double end = viewTop + viewHeight * 0.4;
    return ((start - center) / (start - end)).clamp(0.0, 1.0);
  }

  void _onScroll() {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_open != 1) setState(() => _open = 1);
      return;
    }
    final double next = _reveal();
    if ((next - _open).abs() < 0.008) return;
    setState(() => _open = next);
  }

  /// `assets/images/home/intro_app.png`를 두면 이 한 화면이 그 사진으로 바뀐다.
  Future<void> _loadPhoto() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );
    final RegExp file = RegExp(
      r'^assets/images/home/intro_app\.(png|webp|jpe?g)$',
    );
    final List<String> hits =
        manifest.listAssets().where(file.hasMatch).toList()..sort();
    if (!mounted) return;
    setState(() => _photo = hits.isEmpty ? null : hits.first);
  }

  @override
  Widget build(BuildContext context) {
    const double phoneWidth = 104;
    const double designCard = 124;
    const double baseBite = 14;
    const double pairGap = 8;
    final double phoneHeight = phoneWidth * 19.5 / 9;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double phone = phoneWidth < width ? phoneWidth : width;
        final TextScaler scaler = MediaQuery.textScalerOf(context);
        final TextStyle theme = DefaultTextStyle.of(context).style;
        final (double textW, double textH) = _cardText(
          scaler,
          title: theme.copyWith(
            fontSize: 12 * widget.fontScale,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.2,
          ),
          body: theme.copyWith(
            fontSize: 10 * widget.fontScale,
            fontWeight: FontWeight.w400,
            height: 1.15,
          ),
        );
        final double fitted = 7 + 20 + 6 + textW + 7 + _PointPainter.tip + 1;
        final double maxPair = ((width - pairGap) / 2).clamp(0.0, width);
        final double wanted = designCard > fitted ? designCard : fitted;
        final double cardWidth = wanted < maxPair ? wanted : maxPair;
        final double side = (width - phone) / 2;
        final double rawInset = side + baseBite - cardWidth;
        final double inset = rawInset < 0 ? 0 : rawInset;
        final double gap = (width - 2 * inset - 2 * cardWidth).clamp(
          0.0,
          width,
        );
        final double shift = gap / 2 < 14 ? gap / 2 : 14;
        final double cardH = (textH > 20 ? textH : 20) + 8;
        final double block = 6 + cardH + 8 + cardH + 6;
        final double stage = block > phoneHeight ? block : phoneHeight;
        Widget pair(int left, int right) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: cardWidth, child: _card(left, shift)),
                const Spacer(),
                SizedBox(width: cardWidth, child: _card(right, shift)),
              ],
            ),
          );
        }

        return SizedBox(
          width: width,
          height: stage,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: phone,
                  child: _PhoneFrame(
                    child:
                        _photo == null
                            ? const _SplashGlass()
                            : Image.asset(_photo!, fit: BoxFit.cover),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  children: <Widget>[
                    pair(0, 1),
                    const SizedBox(height: 8),
                    pair(2, 3),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 카드 문구가 한 줄에 들어가는 너비와, 두 줄의 높이.
  (double, double) _cardText(
    TextScaler scaler, {
    required TextStyle title,
    required TextStyle body,
  }) {
    double width = 0;
    double height = 0;
    for (final (String label, String caption, IconData _) in _appSteps) {
      final (double titleW, double titleH) = _line(label, title, scaler);
      final (double bodyW, double bodyH) = _line(caption, body, scaler);
      if (titleW > width) width = titleW;
      if (bodyW > width) width = bodyW;
      final double lines = titleH + bodyH;
      if (lines > height) height = lines;
    }
    return (width, height);
  }

  (double, double) _line(String value, TextStyle style, TextScaler scaler) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final (double, double) measured = (painter.width, painter.height);
    painter.dispose();
    return measured;
  }

  Widget _card(int index, double shift) {
    final (String title, String body, IconData icon) = _appSteps[index];
    final bool onLeft = index.isEven;
    return _PopCard(
      open: _open,
      index: index,
      from: Offset(onLeft ? shift : -shift, 10),
      title: title,
      body: body,
      icon: icon,
      fontScale: widget.fontScale,
      towardPhone: onLeft ? Alignment.centerRight : Alignment.centerLeft,
      pointRight: onLeft,
    );
  }
}

class _PopCard extends StatelessWidget {
  const _PopCard({
    required this.open,
    required this.index,
    required this.from,
    required this.title,
    required this.body,
    required this.icon,
    required this.fontScale,
    required this.towardPhone,
    required this.pointRight,
  });

  final double open;
  final int index;
  final Offset from;
  final String title;
  final String body;
  final IconData icon;
  final double fontScale;
  final Alignment towardPhone;
  final bool pointRight;

  double get _local {
    const double span = 0.62;
    final double start = index.isEven ? 0 : 0.08;
    final double row = index >= 2 ? 0.12 : 0;
    return ((open - start - row) / span).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final double eased = Curves.easeOutCubic.transform(_local);
    return Opacity(
      opacity: eased,
      child: Transform.translate(
        offset: from * (1 - eased),
        child: Transform.scale(
          scale: 0.72 + 0.28 * eased,
          alignment: towardPhone,
          child: CustomPaint(
            painter: _PointPainter(pointRight: pointRight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pointRight ? 7 : 7 + _PointPainter.tip,
                4,
                pointRight ? 7 + _PointPainter.tip : 7,
                4,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 11, color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10 * fontScale,
                            height: 1.15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 바깥쪽은 둥글고, 화면과 맞닿는 변만 한 점으로 모은다.
class _PointPainter extends CustomPainter {
  const _PointPainter({required this.pointRight});

  final bool pointRight;

  static const double tip = 9;
  static const double radius = 11;

  Path _path(Size size) {
    const double edge = 0.5;
    final double left = edge;
    final double top = edge;
    final double right = size.width - edge;
    final double bottom = size.height - edge;
    final Path path = Path();
    if (pointRight) {
      path.moveTo(left + radius, top);
      path.lineTo(right - tip, top);
      path.lineTo(right, (top + bottom) / 2);
      path.lineTo(right - tip, bottom);
      path.lineTo(left + radius, bottom);
      path.arcToPoint(
        Offset(left, bottom - radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(left, top + radius);
      path.arcToPoint(
        Offset(left + radius, top),
        radius: const Radius.circular(radius),
      );
    } else {
      path.moveTo(left + tip, top);
      path.lineTo(right - radius, top);
      path.arcToPoint(
        Offset(right, top + radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(right, bottom - radius);
      path.arcToPoint(
        Offset(right - radius, bottom),
        radius: const Radius.circular(radius),
      );
      path.lineTo(left + tip, bottom);
      path.lineTo(left, (top + bottom) / 2);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _path(size);
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0x140B1F38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(path, Paint()..color = AppColors.surface);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _PointPainter oldDelegate) {
    return oldDelegate.pointRight != pointRight;
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double radius = width * 0.18;
          final double bezel = (width * 0.04).clamp(2.0, 4.0);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D21),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Padding(
              padding: EdgeInsets.all(bezel),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (radius - bezel).clamp(0, radius),
                ),
                child: SizedBox.expand(child: child),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SplashGlass extends StatelessWidget {
  const _SplashGlass();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final bool showLine = width >= 96;
        return ColoredBox(
          color: AppColors.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 5),
                AppLogo(onDark: true, height: width * 0.16),
                const Spacer(flex: 4),
                if (showLine)
                  Text(
                    '간단하고 맛있는 인테리어',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFE6E0D4),
                      fontSize: width * 0.075,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                SizedBox(height: showLine ? width * 0.14 : 0),
              ],
            ),
          ),
        );
      },
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
                child: _Cell(icon: Icons.photo_outlined, label: '끝난 공간'),
              ),
              _Arrow(),
              Expanded(
                child: _Cell(icon: Icons.grid_view_rounded, label: '쇼룸'),
              ),
              _Arrow(),
              Expanded(
                child: _Cell(icon: Icons.person_outline, label: '다음 사람'),
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

class _PlainColumn extends StatelessWidget {
  const _PlainColumn({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        for (final String line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _MarkedColumn extends StatelessWidget {
  const _MarkedColumn({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            for (final String line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
          fontWeight: FontWeight.w600,
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
