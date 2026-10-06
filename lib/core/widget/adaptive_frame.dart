import 'dart:ui' show DisplayFeature, DisplayFeatureState;

import 'package:flutter/material.dart';

/// 폰, 태블릿, 폴더블에 맞춰 화면을 배치한다.
///
/// 접힘선이 화면을 나누면 더 넓은 쪽(가로 접힘이면 위쪽)에 내용을 둔다.
/// 접힘선 없이 화면만 넓으면 본문을 가로로 무한히 늘리지 않고 가운데에 둔다.
class AdaptiveFrame extends StatelessWidget {
  const AdaptiveFrame({super.key, required this.child});

  final Widget child;

  /// 태블릿에서 한 줄 문장과 카드가 너무 길어지지 않는 상한.
  static const double expandedContentWidth = 840;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final Rect screen = Offset.zero & media.size;
    final List<Rect> panes = _panes(screen, _avoidBounds(media.displayFeatures));
    Rect pane = _pickPane(panes);

    final bool split =
        pane.width < screen.width - 1 || pane.height < screen.height - 1;
    if (!split && screen.width >= expandedContentWidth) {
      final double left = (screen.width - expandedContentWidth) / 2;
      pane = Rect.fromLTWH(left, 0, expandedContentWidth, screen.height);
    }

    final MediaQueryData childMedia = media
        .removeDisplayFeatures(pane)
        .copyWith(size: pane.size);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: pane.left,
          top: pane.top,
          right: screen.width - pane.right,
          bottom: screen.height - pane.bottom,
        ),
        child: MediaQuery(data: childMedia, child: child),
      ),
    );
  }
}

List<Rect> _avoidBounds(List<DisplayFeature> features) {
  return features
      .where(
        (DisplayFeature feature) =>
            feature.bounds.shortestSide > 0 ||
            feature.state == DisplayFeatureState.postureHalfOpened,
      )
      .map((DisplayFeature feature) => feature.bounds)
      .toList();
}

/// 접힘선으로 나뉜 영역. 나누지 않으면 화면 전체 하나.
List<Rect> _panes(Rect screen, List<Rect> avoidBounds) {
  List<Rect> panes = <Rect>[screen];
  for (final Rect bounds in avoidBounds) {
    final List<Rect> next = <Rect>[];
    for (final Rect pane in panes) {
      final bool splitsVertically =
          pane.top >= bounds.top && pane.bottom <= bounds.bottom;
      final bool splitsHorizontally =
          pane.left >= bounds.left && pane.right <= bounds.right;

      if (splitsVertically && pane.left < bounds.left && pane.right > bounds.right) {
        next.add(Rect.fromLTWH(pane.left, pane.top, bounds.left - pane.left, pane.height));
        next.add(
          Rect.fromLTWH(bounds.right, pane.top, pane.right - bounds.right, pane.height),
        );
      } else if (splitsHorizontally && pane.top < bounds.top && pane.bottom > bounds.bottom) {
        next.add(Rect.fromLTWH(pane.left, pane.top, pane.width, bounds.top - pane.top));
        next.add(
          Rect.fromLTWH(pane.left, bounds.bottom, pane.width, pane.bottom - bounds.bottom),
        );
      } else {
        next.add(pane);
      }
    }
    panes = next.where((Rect pane) => pane.width > 0 && pane.height > 0).toList();
    if (panes.isEmpty) return <Rect>[screen];
  }
  return panes;
}

Rect _pickPane(List<Rect> panes) {
  if (panes.length <= 1) return panes.first;

  final bool sideBySide = panes.every(
    (Rect pane) => (pane.top - panes.first.top).abs() < 1,
  );
  if (sideBySide) {
    return panes.reduce((Rect a, Rect b) => a.width >= b.width ? a : b);
  }
  return panes.reduce((Rect a, Rect b) => a.top <= b.top ? a : b);
}
