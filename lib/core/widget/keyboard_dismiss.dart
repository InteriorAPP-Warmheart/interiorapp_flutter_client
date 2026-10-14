import 'package:flutter/material.dart';

/// 텍스트필드 밖을 누르면 올라온 키보드를 내린다.
class KeyboardDismiss extends StatelessWidget {
  const KeyboardDismiss({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      // 손가락을 떼기 전에 포커스를 빼면, 포커스 중에만 보이는 최근 검색어가
      // 탭이 전달되기 전에 사라진다.
      onPointerUp: _dismissIfOutsideFocus,
      child: child,
    );
  }
}

void _dismissIfOutsideFocus(PointerUpEvent event) {
  final FocusNode? focus = FocusManager.instance.primaryFocus;
  if (focus == null || focus is FocusScopeNode || !focus.hasFocus) return;

  final RenderObject? object = focus.context?.findRenderObject();
  if (object is RenderBox && object.attached && object.hasSize) {
    final Rect field = object.localToGlobal(Offset.zero) & object.size;
    if (field.contains(event.position)) return;
  }

  focus.unfocus();
}
