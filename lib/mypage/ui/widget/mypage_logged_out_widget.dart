import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class MyPageLoggedOutWidget extends StatelessWidget {
  const MyPageLoggedOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 영역
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFECECEC)),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 38,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '로그인이 필요한 서비스입니다.',
              style: TextStyle(
                fontSize: 17 * fontScale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '로그인하면 저장 콘텐츠, 프로젝트 이력 등\n더 많은 기능을 이용할 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.6,
                color: const Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(height: 32),
            // 로그인 버튼 (다크)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.push('/signin'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      '로그인 하러가기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 회원가입 버튼 (아웃라인)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.push('/signup'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFECECEC), width: 1.5),
                    ),
                    child: Text(
                      '회원가입',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 44),
            // 기능 미리보기 힌트
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
                  color: const Color(0xFFF6F3EE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFECECEC)),
                ),
                child: Icon(f.$1, size: 22, color: const Color(0xFF8A8A8A)),
              ),
              const SizedBox(height: 7),
              Text(
                f.$2,
                style: TextStyle(
                  fontSize: 11 * fontScale,
                  color: const Color(0xFF8A8A8A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
