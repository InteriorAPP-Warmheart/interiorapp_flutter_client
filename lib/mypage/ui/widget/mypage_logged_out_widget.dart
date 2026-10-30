import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

class MyPageLoggedOutWidget extends StatelessWidget {
  const MyPageLoggedOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);

    final double tabSlot = MediaQuery.paddingOf(context).bottom;

    return Center(
      child: Padding(
        padding: padding.copyWith(bottom: tabSlot),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '로그인이 필요한 서비스입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17 * fontScale,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '로그인하면 저장 콘텐츠, 프로젝트 이력 등\n더 많은 기능을 이용할 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: '로그인 하러가기',
              onPressed: () => context.push('/signin'),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: '회원가입',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/signup'),
            ),
            const SizedBox(height: 44),
            const _FeaturePreviewRow(),
          ],
        ),
      ),
    );
  }
}

class _FeaturePreviewRow extends StatelessWidget {
  const _FeaturePreviewRow();

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    final features = [
      (Icons.bookmark_outline_rounded, '저장 콘텐츠'),
      (Icons.history_rounded, '최근 본 항목'),
      (Icons.home_work_outlined, '프로젝트 이력'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(f.$1, size: 22, color: AppColors.primary),
              ),
              const SizedBox(height: 7),
              Text(
                f.$2,
                style: TextStyle(
                  fontSize: 11 * fontScale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
