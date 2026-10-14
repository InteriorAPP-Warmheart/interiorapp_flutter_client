import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/mypage/ui/widget/mypage_logged_in_widget.dart';
import 'package:interiorapp_flutter_client/mypage/ui/widget/mypage_logged_out_widget.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  /// 실제 서비스에서는 auth provider 값으로 대체.
  /// 현재는 미리보기용 토글.
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── 세그먼트 토글 (build_screen 스타일) ─────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                12,
                padding.right,
                8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const WidgetStatePropertyAll(
                      Color(0xFFFCFCFC),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(value: false, label: Text('로그인 전')),
                    ButtonSegment(value: true, label: Text('로그인 후')),
                  ],
                  selected: {_isLoggedIn},
                  onSelectionChanged: (Set<bool> next) =>
                      setState(() => _isLoggedIn = next.first),
                ),
              ),
            ),
            // ── 콘텐츠 영역 ──────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _isLoggedIn
                    ? const MyPageLoggedInWidget(key: ValueKey('loggedIn'))
                    : const MyPageLoggedOutWidget(key: ValueKey('loggedOut')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
