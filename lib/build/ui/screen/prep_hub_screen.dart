import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/prep_detail_parts.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 새 공간 준비. 스크롤 없이 입지 선정과 상담 준비를 같은 높이로 나누고,
/// 영역마다 큰 카드를 옆으로 넘긴다. 상담 신청은 저장한 상담 준비 안에서 한다.
class PrepHubScreen extends ConsumerWidget {
  const PrepHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final bool wide = AppWindow.of(context).isExpanded;
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    void startConsult() => context.push(SpaceRoutes.prepCreate);
    void addSite() => context.push(SpaceRoutes.tradeCreate);

    final Widget consults = _CardSection(
      title: '상담 준비',
      count: board.consults.isEmpty ? null : '${board.consults.length}',
      cards: [
        for (var i = 0; i < board.consults.length; i++)
          _PrepCard.consult(
            board.consults[i],
            onTap:
                () => context.push(
                  SpaceRoutes.prepRecord,
                  extra: board.consults[i],
                ),
          ),
        if (board.consults.isEmpty)
          _StartCard(
            imageUrl: 'assets/images/home/prep_document.jpg',
            title: '상담 준비 시작',
            caption: '필요한 내용을 미리 적어 두면 상담이 빨라져요',
            onTap: startConsult,
          ),
      ],
    );

    final Widget sites = _CardSection(
      title: '입지 선정',
      count:
          board.trades.isEmpty
              ? null
              : '${board.trades.length}/${SpaceBoard.maxTrades}',
      cards: [
        for (var i = 0; i < board.trades.length; i++)
          _PrepCard.site(
            board.trades[i],
            onTap:
                () => context.push(SpaceRoutes.trade, extra: board.trades[i]),
          ),
        if (board.trades.isEmpty)
          _StartCard(
            imageUrl: 'assets/images/home/prep_trade.jpg',
            title: '입지 추가',
            caption: '보고 있는 곳을 2곳까지 비교해요',
            onTap: addSite,
          ),
      ],
      action:
          board.trades.isEmpty || board.trades.length >= SpaceBoard.maxTrades
              ? null
              : _HeaderAction(label: '입지 추가', onTap: addSite),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('새 공간 준비')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, subGap, 0, subGap),
          child: Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: padding.left,
                    right: wide ? 0 : padding.right,
                  ),
                  child: sites,
                ),
              ),
              SizedBox(width: sectionGap, height: sectionGap),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: wide ? 0 : padding.left,
                    right: padding.right,
                  ),
                  child: consults,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 제목 + 옆으로 넘기는 큰 카드 + 페이지 표시.
class _CardSection extends StatefulWidget {
  const _CardSection({
    required this.title,
    required this.count,
    required this.cards,
    this.action,
  });

  final String title;
  final String? count;
  final List<Widget> cards;
  final Widget? action;

  @override
  State<_CardSection> createState() => _CardSectionState();
}

class _CardSectionState extends State<_CardSection> {
  final PageController _controller = PageController(viewportFraction: 0.86);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    final List<Widget> cards = widget.cards;
    final bool single = cards.length == 1;
    final int current = _index.clamp(0, cards.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 19 * fontScale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.count!,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              if (widget.action != null) widget.action!,
            ],
          ),
        ),
        SizedBox(height: subGap),
        Expanded(
          child:
              single
                  ? cards.first
                  : PageView.builder(
                    controller: _controller,
                    padEnds: false,
                    itemCount: cards.length,
                    onPageChanged:
                        (int index) => setState(() => _index = index),
                    itemBuilder:
                        (_, int index) => Padding(
                          padding: EdgeInsets.only(
                            right: index == cards.length - 1 ? 0 : 12,
                          ),
                          child: cards[index],
                        ),
                  ),
        ),
        SizedBox(height: subGap),
        SizedBox(
          height: 6,
          child:
              single
                  ? null
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == current ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                i == current
                                    ? AppColors.primary
                                    : AppColors.border,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ],
                  ),
        ),
      ],
    );
  }
}

/// 저장해 둔 한 건. 진행 중인 공간 카드처럼 위는 사진과 이름, 아래는 한 줄 정보.
class _PrepCard extends StatelessWidget {
  const _PrepCard({
    required this.imageUrl,
    required this.title,
    required this.place,
    required this.infoLabel,
    required this.info,
    required this.onTap,
  });

  factory _PrepCard.consult(PrepRecord record, {required VoidCallback onTap}) {
    return _PrepCard(
      imageUrl: prepCoverAsset(
        record.industryLine,
        record.id,
        photo: record.coverPhoto,
      ),
      title: record.placeName.trim().isEmpty ? '이름 없는 상담 준비' : record.placeName,
      place: _district(record.address),
      infoLabel: '공사',
      info: _join([record.industry, record.workScope]),
      onTap: onTap,
    );
  }

  factory _PrepCard.site(
    TradeCandidate candidate, {
    required VoidCallback onTap,
  }) {
    final String area =
        candidate.area.isEmpty || candidate.area == PrepLabels.areaUnknown
            ? ''
            : '${candidate.area}평';
    return _PrepCard(
      imageUrl: prepCoverAsset(
        candidate.industry,
        candidate.id,
        photo: candidate.coverPhoto,
      ),
      title: candidate.name.trim().isEmpty ? '이름 없는 입지' : candidate.name,
      place: _district(candidate.address),
      infoLabel: '용도',
      info: _join([candidate.industry, area]),
      onTap: onTap,
    );
  }

  final String imageUrl;
  final String title;
  final String place;
  final String infoLabel;
  final String info;
  final VoidCallback onTap;

  /// 주소는 앞의 두 마디(예: 서울 마포구)만 쓴다.
  static String _district(String address) =>
      address.trim().split(RegExp(r'\s+')).take(2).join(' ');

  static String _join(List<String> values) => values
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .join(' · ');

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x000B1F38), Color(0xCC0B1F38)],
                          stops: [0.4, 1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 22 * fontScale,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (place.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xF2FFFFFF),
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                child: Row(
                  children: [
                    Text(
                      infoLabel,
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        info.isEmpty ? '아직 적지 않았어요' : info,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color:
                              info.isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 새로 시작하는 카드. 사진 위에 더하기, 이름, 한 줄만 둔다.
class _StartCard extends StatelessWidget {
  const _StartCard({
    required this.imageUrl,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x660B1F38), Color(0xE60B1F38)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22 * fontScale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xE6FFFFFF),
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

/// 입지 추가. 연한 둥근 막대로, 카드보다 눈에 띄지 않게 둔다.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
