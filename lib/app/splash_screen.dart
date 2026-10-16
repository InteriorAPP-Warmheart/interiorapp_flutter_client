import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _visibleDuration = Duration(seconds: 2);

  late final AnimationController _intro;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _navigateTimer = Timer(_visibleDuration, _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double logoHeight = (MediaQuery.sizeOf(context).shortestSide * 0.1)
        .clamp(34.0, 56.0);
    final Animation<double> fade = CurvedAnimation(
      parent: _intro,
      curve: Curves.easeOut,
    );
    final Animation<Offset> rise = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: rise,
                  child: Center(
                    child: AppLogo(onDark: true, height: logoHeight),
                  ),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _intro,
                  curve: const Interval(0.35, 1, curve: Curves.easeOut),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    '간단하고 맛있는 인테리어',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFE6E0D4),
                      fontSize: 15 * ResponsiveSize.fontScale(context),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
