import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 시공 전 사진 위로 시공 후가 쓸리듯 넘어갔다가, 다시 전으로 돌아온다.
class ShowroomWipeCompare extends StatefulWidget {
  const ShowroomWipeCompare({
    super.key,
    required this.beforeUrl,
    required this.afterUrl,
  });

  final String beforeUrl;
  final String afterUrl;

  @override
  State<ShowroomWipeCompare> createState() => _ShowroomWipeCompareState();
}

class _ShowroomWipeCompareState extends State<ShowroomWipeCompare>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wipe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );
  bool _after = false;

  @override
  void didUpdateWidget(covariant ShowroomWipeCompare oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool canSwitch =
        widget.beforeUrl.isNotEmpty && widget.afterUrl.isNotEmpty;
    final bool urlsChanged =
        oldWidget.beforeUrl != widget.beforeUrl ||
        oldWidget.afterUrl != widget.afterUrl;
    if (urlsChanged || !canSwitch) {
      _after = false;
      _wipe.value = 0;
    }
  }

  @override
  void dispose() {
    _wipe.dispose();
    super.dispose();
  }

  void _setAfter(bool after) {
    if (_after == after) return;
    setState(() => _after = after);
    if (after) {
      _wipe.forward();
    } else {
      _wipe.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSwitch =
        widget.beforeUrl.isNotEmpty && widget.afterUrl.isNotEmpty;
    final bool after = canSwitch ? _after : widget.afterUrl.isNotEmpty;
    final String still = after ? widget.afterUrl : widget.beforeUrl;
    return Padding(
      padding: ResponsiveSize.textInset(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child:
                  canSwitch
                      ? AnimatedBuilder(
                        animation: _wipe,
                        builder: (BuildContext context, Widget? child) {
                          final double reveal = Curves.easeInOutCubic.transform(
                            _wipe.value,
                          );
                          final bool showingAfter = reveal >= 0.5;
                          return LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              final double edge =
                                  (1 - reveal) * constraints.maxWidth;
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  _Photo(url: widget.afterUrl),
                                  ClipRect(
                                    clipper: _LeftFractionClipper(1 - reveal),
                                    child: _Photo(url: widget.beforeUrl),
                                  ),
                                  const _PhotoShade(),
                                  if (reveal > 0.02 && reveal < 0.98)
                                    Positioned(
                                      left: edge - 1,
                                      top: 0,
                                      bottom: 0,
                                      width: 2,
                                      child: const ColoredBox(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ShowroomCompareBadge(
                                    label: showingAfter ? '시공 후' : '시공 전',
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                      : Stack(
                        fit: StackFit.expand,
                        children: [
                          _Photo(url: still),
                          const _PhotoShade(),
                          ShowroomCompareBadge(label: after ? '시공 후' : '시공 전'),
                        ],
                      ),
            ),
          ),
          if (canSwitch) ...[
            const SizedBox(height: 12),
            ShowroomBeforeAfterToggle(after: _after, onChanged: _setAfter),
          ],
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const ColoredBox(color: AppColors.imagePlaceholder);
    return AppNetworkImage(url: url);
  }
}

class _PhotoShade extends StatelessWidget {
  const _PhotoShade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xCC000000)],
          stops: [0.62, 1],
        ),
      ),
    );
  }
}

class ShowroomCompareBadge extends StatelessWidget {
  const ShowroomCompareBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 14,
      bottom: 14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x8C000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// 시공 전후를 고르는 두 칸. 선택된 칸이 트랙 안에서 이동한다.
class ShowroomBeforeAfterToggle extends StatelessWidget {
  const ShowroomBeforeAfterToggle({
    super.key,
    required this.after,
    required this.onChanged,
  });

  final bool after;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F1EC),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE7E1D8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double half = constraints.maxWidth / 2;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: after ? half : 0,
                        top: 0,
                        bottom: 0,
                        width: half,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _ToggleSide(
                            label: '시공 전',
                            selected: !after,
                            onTap: () => onChanged(false),
                          ),
                          _ToggleSide(
                            label: '시공 후',
                            selected: after,
                            onTap: () => onChanged(true),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleSide extends StatelessWidget {
  const _ToggleSide({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: -0.2,
              color: selected ? storyInk : const Color(0xFF8A847A),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftFractionClipper extends CustomClipper<Rect> {
  const _LeftFractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width * fraction.clamp(0.0, 1.0),
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant _LeftFractionClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
