import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/mypage/ui/widget/mypage_logged_in_widget.dart';
import 'package:interiorapp_flutter_client/mypage/ui/widget/mypage_logged_out_widget.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  /// true → 로그인 후 화면 / false → 로그인 전 화면 (미리보기용 토글)
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            // ── 세그먼트 버튼 ────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                14,
                padding.right,
                12,
              ),
              child: _SegmentControl(
                isLoggedIn: _isLoggedIn,
                onChanged: (v) => setState(() => _isLoggedIn = v),
              ),
            ),
            // ── 콘텐츠 영역 ──────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
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

// ─────────────────────────────────────────────────────────────────────────────
// 세그먼트 컨트롤
// ─────────────────────────────────────────────────────────────────────────────

class _SegmentControl extends StatelessWidget {
  final bool isLoggedIn;
  final ValueChanged<bool> onChanged;

  const _SegmentControl({required this.isLoggedIn, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _SegmentTab(
            label: '로그인 전',
            isSelected: !isLoggedIn,
            onTap: () => onChanged(false),
          ),
          _SegmentTab(
            label: '로그인 후',
            isSelected: isLoggedIn,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? Colors.black87 : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}
