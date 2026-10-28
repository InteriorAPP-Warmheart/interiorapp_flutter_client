import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 잠금 해제처럼 밀어 끝을 넘기면 [onCompleted]를 부른다.
/// 거절되면 손잡이가 처음으로 돌아온다.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onCompleted,
  });

  final String label;
  final Future<bool> Function() onCompleted;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with SingleTickerProviderStateMixin {
  static const double _thumb = 48;
  static const double _inset = 4;

  double _offset = 0;
  bool _waiting = false;
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  Future<void> _finish(double max) async {
    if (_waiting) return;
    if (_offset < max * 0.85) {
      _return();
      return;
    }
    _waiting = true;
    setState(() => _offset = max);
    final bool accepted = await widget.onCompleted();
    if (!mounted) return;
    _waiting = false;
    if (!accepted) _return();
  }

  void _return() {
    final double from = _offset;
    void tick() {
      if (!mounted) return;
      setState(() => _offset = from * (1 - _back.value));
    }

    _back.addListener(tick);
    _back.forward(from: 0).whenComplete(() {
      _back.removeListener(tick);
      if (mounted) setState(() => _offset = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double max = (constraints.maxWidth - _thumb - _inset * 2).clamp(
          0,
          double.infinity,
        );
        final double left = _inset + _offset.clamp(0, max);
        return SizedBox(
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: _thumb),
                  child: Opacity(
                    opacity: (1 - (_offset / (max == 0 ? 1 : max))).clamp(0, 1),
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: left,
                  top: _inset,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      if (_waiting) return;
                      setState(() {
                        _offset = (_offset + details.delta.dx).clamp(0, max);
                      });
                    },
                    onHorizontalDragEnd: (_) => _finish(max),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: _thumb,
                        height: _thumb,
                        child: Icon(
                          Icons.keyboard_double_arrow_right,
                          color: AppColors.white,
                          size: 22 * fontScale,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
