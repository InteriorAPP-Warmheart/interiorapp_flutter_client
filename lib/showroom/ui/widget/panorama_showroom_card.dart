import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';

/// 카드 안 사진 높이. 글 영역과 나누기 위해 사진만의 비율로 잡는다.
double showroomCardImageHeight(BuildContext context, {bool compact = false}) {
  final double contentWidth =
      MediaQuery.sizeOf(context).width -
      ResponsiveSize.responsivePadding(context).horizontal;
  return contentWidth * (compact ? 0.72 : 0.9);
}

/// 동네 게시물. 게시판에 폴라로이드를 붙여 둔 배치.
class HotShowroomCardList extends ConsumerStatefulWidget {
  const HotShowroomCardList({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<HotShowroomCardList> createState() =>
      _HotShowroomCardListState();
}

class _HotShowroomCardListState extends ConsumerState<HotShowroomCardList> {
  static const List<double> _tilts = [-0.07, 0.055, -0.04];
  static const List<double> _drops = [10, 0, 14];

  List<String> _order = <String>[];

  List<HotShowroomModel> _arranged(List<HotShowroomModel> items) {
    final Map<String, HotShowroomModel> byId = {
      for (final HotShowroomModel item in items) item.id: item,
    };
    if (_order.isEmpty) {
      _order = items.map((HotShowroomModel item) => item.id).toList();
    } else {
      _order = [
        for (final String id in _order)
          if (byId.containsKey(id)) id,
      ];
      for (final HotShowroomModel item in items) {
        if (!_order.contains(item.id)) {
          _order.add(item.id);
        }
      }
    }
    return [for (final String id in _order) byId[id]!];
  }

  void _swapWithFeatured(String id) {
    final int index = _order.indexOf(id);
    if (index <= 0) return;
    setState(() {
      final String top = _order[0];
      _order[0] = id;
      _order[index] = top;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<HotShowroomModel> items = ref.watch(hotShowroomSliderVm);
    if (items.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('표시할 항목이 없어요')),
      );
    }

    final List<HotShowroomModel> arranged = _arranged(items);
    final HotShowroomModel? featured = widget.compact ? null : arranged.first;
    final List<HotShowroomModel> rest =
        widget.compact ? arranged.take(3).toList() : arranged.skip(1).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4CFA8), Color(0xFFC9AE84)],
        ),
        border: Border.all(color: const Color(0xFFB89A6C)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 28, 8, 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double boardWidth = constraints.maxWidth;
            final List<Widget> rows = [];

            if (featured != null) {
              final double featuredWidth = boardWidth * 0.92;
              rows.add(
                Align(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Transform.rotate(
                      key: ValueKey<String>(featured.id),
                      angle: -0.03,
                      child: SizedBox(
                        width: featuredWidth,
                        child: _postCard(
                          ref,
                          featured,
                          imageHeight: featuredWidth * 0.78,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            for (var start = 0; start < rest.length; start += 3) {
              final int end = start + 3 > rest.length ? rest.length : start + 3;
              final List<HotShowroomModel> rowItems = rest.sublist(start, end);
              final double slot = boardWidth / 3;
              if (rows.isNotEmpty) {
                rows.add(SizedBox(height: start == 0 ? 20 : 8));
              }
              rows.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < rowItems.length; i++)
                      SizedBox(
                        width: slot,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: _drops[i],
                            left: 3,
                            right: 3,
                          ),
                          child: Transform.rotate(
                            angle: _tilts[i],
                            child: _postCard(
                              ref,
                              rowItems[i],
                              imageHeight: slot * 0.82,
                              dense: true,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            );
          },
        ),
      ),
    );
  }

  Widget _postCard(
    WidgetRef ref,
    HotShowroomModel item, {
    required double imageHeight,
    bool dense = false,
  }) {
    return ShowroomPostCard(
      imageUrl: item.thumbnailUrl,
      title: item.title,
      themeName: item.themeName,
      userName: item.userName,
      userProfileUrl: item.userProfileUrl,
      likeCount: item.likeCount,
      favoriteStatus: item.favoriteStatus,
      imageHeight: imageHeight,
      dense: dense,
      onSelect:
          !widget.compact && dense ? () => _swapWithFeatured(item.id) : null,
      onFavorite:
          dense
              ? null
              : () {
                ref
                    .read(hotShowroomSliderVm.notifier)
                    .toggleFavoriteByIndex(item.id);
              },
    );
  }
}

/// 스티커 사진처럼 흰 프레임이 사진을 감싼 쇼룸 카드.
class ShowroomPostCard extends StatelessWidget {
  const ShowroomPostCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.themeName,
    required this.userName,
    required this.userProfileUrl,
    required this.likeCount,
    required this.favoriteStatus,
    required this.imageHeight,
    this.onFavorite,
    this.onSelect,
    this.dense = false,
  });

  final String imageUrl;
  final String title;
  final String themeName;
  final String userName;
  final String userProfileUrl;
  final int likeCount;
  final bool favoriteStatus;
  final double imageHeight;
  final VoidCallback? onFavorite;
  final VoidCallback? onSelect;
  final bool dense;

  static const TextStyle _titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle _metaStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Color(0xFF333333),
  );

  static const TextStyle _styleLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Color(0xFF6B6B6B),
  );

  @override
  Widget build(BuildContext context) {
    final String likeLabel = likeCount > 999 ? '999+' : likeCount.toString();
    final double titleHeight = dense ? 16 : 22;
    final double metaHeight = dense ? 20 : 28;
    final TextStyle titleStyle =
        dense ? _titleStyle.copyWith(fontSize: 11) : _titleStyle;
    final TextStyle metaStyle =
        dense ? _metaStyle.copyWith(fontSize: 9) : _metaStyle;
    final TextStyle styleLabel =
        dense ? _styleLabel.copyWith(fontSize: 9) : _styleLabel;

    final Widget polaroid = Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                dense ? 6 : 10,
                dense ? 6 : 10,
                dense ? 6 : 10,
                dense ? 8 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(url: imageUrl),
                        Positioned(
                          top: dense ? 4 : 8,
                          right: dense ? 4 : 8,
                          child: _HeartButton(
                            favorite: favoriteStatus,
                            dense: dense,
                            onPressed: onFavorite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: dense ? 6 : 12),
                  SizedBox(
                    height: titleHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                  ),
                  SizedBox(height: dense ? 4 : 8),
                  if (dense) ...[
                    SizedBox(
                      height: 18,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userProfileUrl),
                            radius: 7,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$userName · $likeLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: metaStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        themeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styleLabel,
                      ),
                    ),
                  ] else
                    SizedBox(
                      height: metaHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userProfileUrl),
                            radius: 11,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$userName  ·  좋아요 $likeLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: metaStyle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 112),
                            child: Text(
                              themeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: styleLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: dense ? -7 : -9,
            left: 0,
            right: 0,
            child: Center(
              child: _MaskingTape(
                width: dense ? 36 : 68,
                tilt: dense ? 0.08 : -0.06,
              ),
            ),
          ),
        ],
      ),
    );
    if (onSelect == null) return polaroid;
    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: polaroid,
    );
  }
}

class _MaskingTape extends StatelessWidget {
  const _MaskingTape({required this.width, required this.tilt});

  final double width;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: Container(
        width: width,
        height: width < 50 ? 12 : 16,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCCF8E7C4), Color(0x99E7D3A4), Color(0xCCF6E4BE)],
          ),
          border: Border.all(color: const Color(0x33A89060)),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({
    required this.favorite,
    required this.dense,
    this.onPressed,
  });

  final bool favorite;
  final bool dense;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Icon(
        favorite ? Icons.favorite : Icons.favorite_border,
        color: favorite ? const Color(0xFFFF4D6A) : Colors.white,
        size: dense ? 18 : 24,
        shadows: const [
          Shadow(color: Color(0x99000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
