import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/auth/ui/widget/checkbox_section.dart';
import 'package:interiorapp_flutter_client/auth/presentation/provider/signup_provider.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final nicknameController = ref.watch(nicknameControllerProvider);
    final signupForm = ref.watch(signupFormProvider);
    final canSignup = ref.watch(canSignupProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        child: Padding(
          padding: screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'XXX 이용을 위해\n필요해요',
                style: TextStyle(
                  fontSize: 26 * fontScale,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: ResponsiveSize.sectionGap(context)),

              // 닉네임 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '닉네임',
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _generateRandomNickname(ref),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.primary,
                      textStyle: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 4),
                        Text('랜덤 생성'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '나만의 닉네임을 설정하고 싶다면 새로 입력해주세요',
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveSize.subGap(context)),
              TextField(
                controller: nicknameController,
                onChanged:
                    (value) => ref
                        .read(signupFormProvider.notifier)
                        .updateNickname(value),
                decoration: InputDecoration(
                  hintText: '닉네임',
                  hintStyle: TextStyle(
                    fontSize: 15 * fontScale,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  suffixIcon: signupForm.nickname.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '닉네임 지우기',
                          onPressed: () {
                            ref
                                .read(signupFormProvider.notifier)
                                .updateNickname('');
                          },
                          icon: const Icon(Icons.cancel_rounded, size: 20),
                          color: AppColors.textSecondary,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 0.7),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 0.7),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveSize.subGap(context)),

              // 중복 확인 버튼
              OutlinedButton(
                onPressed:
                    signupForm.nickname.isNotEmpty
                        ? () => _checkNicknameDuplicate(ref)
                        : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.textSecondary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                    color: signupForm.nickname.isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '중복 확인',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (signupForm.isNicknameDuplicateChecked) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, color: AppColors.primary, size: 20),
                    ],
                  ],
                ),
              ),
              SizedBox(height: ResponsiveSize.sectionGap(context)),

              // 약관 동의 섹션
              CheckboxSection(),
              SizedBox(height: ResponsiveSize.sectionGap(context)),
              SizedBox(height: ResponsiveSize.sectionGap(context)),
              SizedBox(height: ResponsiveSize.sectionGap(context)),

              AppButton(
                label: '완료',
                onPressed: canSignup ? () => _signup(ref) : null,
              ),
              SizedBox(height: ResponsiveSize.sectionGap(context)),
            ],
          ),
        ),
      ),
    );
  }

  /// 랜덤 닉네임 생성
  void _generateRandomNickname(WidgetRef ref) {
    ref.read(signupFormProvider.notifier).generateRandomNickname();

    // // 스낵바 표시
    // ScaffoldMessenger.of(ref.context).showSnackBar(
    //   SnackBar(
    //     content: Text('새로운 닉네임이 생성되었습니다'),
    //     backgroundColor: Color(0xFF34C759),
    //     duration: Duration(seconds: 1),
    // ),
    // );
  }

  /// 닉네임 중복 확인
  void _checkNicknameDuplicate(WidgetRef ref) {
    // TODO: 실제 API 호출로 중복 확인
    // 임시로 성공 처리
    ref.read(signupFormProvider.notifier).setNicknameDuplicateChecked(true);

    // 스낵바 표시
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('사용 가능한 닉네임입니다'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  /// 회원가입 처리
  void _signup(WidgetRef ref) {
    final formState = ref.read(signupFormProvider);

    // TODO: 실제 회원가입 API 호출
    print('회원가입 시작: ${formState.nickname}');

    // 임시 성공 처리
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('회원가입이 완료되었습니다'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
