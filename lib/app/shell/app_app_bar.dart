import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_logo.dart';
import 'package:interiorapp_flutter_client/core/widget/confirm_glow.dart';
import 'package:interiorapp_flutter_client/notification/presentation/notice_inbox_provider.dart';

class AppAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double barHeight = ResponsiveSize.appBarHeight(context);
    final NoticeUnread unread = ref.watch(noticeUnreadProvider);
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
          icon: _BellShake(
            active: unread.confirm > 0,
            child: Badge(
              isLabelVisible: unread.total > 0,
              backgroundColor:
                  unread.confirm > 0 ? AppColors.error : AppColors.primary,
              textColor: AppColors.white,
              label: Text(
                unread.total > 9 ? '9+' : '${unread.total}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: unread.confirm > 0 ? AppColors.error : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _BellShake extends StatelessWidget {
  const _BellShake({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConfirmPulse(
      active: active,
      builder: (BuildContext context, double t) {
        final double swing = t < 0.62 ? t / 0.62 : 1;
        final double angle =
            t < 0.62 ? math.sin(swing * math.pi * 6) * 0.42 * (1 - swing) : 0;
        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter: ConfirmHaloPainter(confirmGlowAmount(t)),
                ),
              ),
              Transform.rotate(angle: angle, child: child),
            ],
          ),
        );
      },
    );
  }
}
