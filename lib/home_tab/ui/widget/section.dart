import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

/// 공통 섹션 래퍼: 제목과 본문 사이 간격을 일관되게 관리
class Section extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  final Widget child;
  final double? gap; // 제목-본문 간 간격 오버라이드

  const Section({super.key, required this.title, required this.child, this.trailing, this.gap});

  @override
  Widget build(BuildContext context) {
    final double resolvedGap = gap ?? ResponsiveSize.subGap(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: title),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: resolvedGap),
        child,
      ],
    );
  }
}


