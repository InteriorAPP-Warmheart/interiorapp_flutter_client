import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_assets.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_controller.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_figure.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_motion.dart';

/// 쇼룸 게시글 앱바 위의 마스코트.
///
/// 들어오고 3초 뒤에 떨어져 가운데 앉는다. 어느 동작이든 누르면 놀라서
/// 진행 방향의 반대로 도망가고, 끝에서 다시 앉는다.
class ShowroomMascot extends StatefulWidget {
  const ShowroomMascot({super.key, this.reservedRight = 0});

  /// 오른쪽에서 비워 둘 폭. 수정 버튼이 있을 때 그 칸까지 가지 않게 쓴다.
  final double reservedRight;

  @override
  State<ShowroomMascot> createState() => _ShowroomMascotState();
}

class _ShowroomMascotState extends State<ShowroomMascot>
    with SingleTickerProviderStateMixin {
  late final ShowroomMascotController _controller = ShowroomMascotController(
    vsync: this,
  );
  int? _cachedPx;
  bool _entranceQueued = false;

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ShowroomMascotLayout _measure(BuildContext context, double width) {
    final MediaQueryData media = MediaQuery.of(context);
    return showroomMascotLayout(
      width: width,
      topInset: media.padding.top,
      toolbarHeight: ResponsiveSize.appBarHeight(context),
      textScale: media.textScaler.scale(1),
      safeLeft: media.padding.left,
      safeRight: media.padding.right,
      reservedRight: widget.reservedRight,
    );
  }

  List<ShowroomMascotSpan> _hinges(BuildContext context) {
    return MediaQuery.of(context).displayFeatures
        .where(
          (DisplayFeature feature) =>
              feature.type == DisplayFeatureType.hinge ||
              feature.type == DisplayFeatureType.fold,
        )
        .where(
          (DisplayFeature feature) =>
              feature.bounds.width < feature.bounds.height,
        )
        .map(
          (DisplayFeature feature) =>
              ShowroomMascotSpan(feature.bounds.left, feature.bounds.right),
        )
        .toList();
  }

  void _precache(BuildContext context, double size) {
    final int px = showroomMascotCachePx(
      size,
      MediaQuery.devicePixelRatioOf(context),
    );
    if (_cachedPx == px) return;
    _cachedPx = px;
    for (final String path in showroomMascotAssetPaths) {
      precacheImage(
        ResizeImage.resizeIfNeeded(px, px, AssetImage(path)),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final ShowroomMascotLayout layout = _measure(
          context,
          constraints.maxWidth,
        );
        _precache(context, layout.figure);
        _controller.syncLayout(
          layout: layout,
          blocked: _hinges(context),
          animationsEnabled: !MediaQuery.disableAnimationsOf(context),
        );
        if (_controller.entranceReady && !_entranceQueued) {
          _entranceQueued = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _entranceQueued = false;
            if (mounted) _controller.beginFall();
          });
        }
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final ShowroomMascotPose? current = _controller.pose;
            if (current == null) {
              return SizedBox(
                height: layout.overlayHeight,
                width: double.infinity,
              );
            }
            final bool runLeft =
                current == ShowroomMascotPose.running && !_controller.faceRight;
            return SizedBox(
              height: layout.overlayHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Positioned(
                    left: _controller.x,
                    top: _controller.y,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _controller.tap,
                      child: Semantics(
                        button: true,
                        label: '마스코트',
                        child: RepaintBoundary(
                          child: Transform.flip(
                            flipX: runLeft,
                            child: ShowroomMascotFigure(
                              pose: current,
                              cycle: _controller.cycle,
                              size: layout.figure,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
