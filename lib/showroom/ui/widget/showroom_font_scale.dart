import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 쇼룸 글자에 [ResponsiveSize.fontScale]을 올린다.
///
/// 다른 화면은 글자 크기에 배율을 직접 곱한다. 쇼룸은 글자 크기가 고정이라
/// 시스템 글자 배율에 그 배율을 한 번 더 곱한다. 이미 적용된 하위 트리는 그대로 둔다.
class ShowroomFontScale extends StatelessWidget {
  const ShowroomFontScale({super.key, required this.child});

  final Widget child;

  static bool applied(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShowroomFontMark>() !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    if (applied(context)) return child;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double factor = ResponsiveSize.fontScale(context);
    return _ShowroomFontMark(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scaler.scale(1) * factor),
        ),
        child: child,
      ),
    );
  }
}

class _ShowroomFontMark extends InheritedWidget {
  const _ShowroomFontMark({required super.child});

  @override
  bool updateShouldNotify(covariant _ShowroomFontMark oldWidget) => false;
}
