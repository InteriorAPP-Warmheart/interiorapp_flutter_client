import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  if (RenderFocusKeepRegion.containsGlobal(event.position)) return;

  focus.unfocus();
}

/// 에디터 밖에 붙어 있는 도구막대처럼, 눌러도 포커스를 유지할 영역.
class FocusKeepRegion extends SingleChildRenderObjectWidget {
  const FocusKeepRegion({super.key, required super.child});

  @override
  RenderFocusKeepRegion createRenderObject(BuildContext context) {
    return RenderFocusKeepRegion();
  }
}

class RenderFocusKeepRegion extends RenderProxyBox {
  static final Set<RenderFocusKeepRegion> _live = <RenderFocusKeepRegion>{};

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _live.add(this);
  }

  @override
  void detach() {
    _live.remove(this);
    super.detach();
  }

  static bool containsGlobal(Offset global) {
    for (final RenderFocusKeepRegion region in _live) {
      if (!region.attached || !region.hasSize) continue;
      final Rect rect = region.localToGlobal(Offset.zero) & region.size;
      if (rect.contains(global)) return true;
    }
    return false;
  }
}
