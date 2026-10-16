import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_logo.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double barHeight = ResponsiveSize.appBarHeight(context);
    return AppBar(
      toolbarHeight: barHeight,
      centerTitle: false,
      titleSpacing: 16,
      title: AppLogo(height: barHeight * 0.34),
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
        ),
        // 장바구니는 스토어와 함께 나중에 연다. 그때 검색과 알림 사이에 둔다.
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_rounded),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
