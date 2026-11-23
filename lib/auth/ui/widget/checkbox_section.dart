import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/auth/presentation/provider/signup_provider.dart';
import 'package:interiorapp_flutter_client/auth/ui/widget/signup_term_sheet.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class CheckboxSection extends ConsumerWidget {
  const CheckboxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAgreement = ref.watch(termsAgreementProvider);
    final double rowGap = ResponsiveSize.subGap(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체 동의
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.allAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleAllTermsAgreement(),
          title: '약관 전체 동의',
          isTitle: true,
          showRequired: false,
        ),
        SizedBox(height: rowGap),
        
        // 개별 약관들
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.serviceTermsAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('service'),
          onOpen: () => showSignupTermSheet(context, 'service'),
          title: '서비스 이용약관 동의',
          isRequired: true,
        ),
        SizedBox(height: rowGap),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.ageConfirmationAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('age'),
          onOpen: () => showSignupTermSheet(context, 'age'),
          title: '만 14세 이상 확인',
          isRequired: true,
        ),
        SizedBox(height: rowGap),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.privacyCollectionAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('privacyCollection'),
          onOpen: () => showSignupTermSheet(context, 'privacyCollection'),
          title: '개인정보 수집 이용 동의',
          isRequired: true,
        ),
        SizedBox(height: rowGap),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.privacyUseAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('privacyUse'),
          onOpen: () => showSignupTermSheet(context, 'privacyUse'),
          title: '개인정보 처리 방침 동의',
          isRequired: true,
        ),
        SizedBox(height: rowGap),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.locationServiceAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('location'),
          onOpen: () => showSignupTermSheet(context, 'location'),
          title: '위치기반 서비스 이용약관 동의',
          isRequired: false,
        ),
        SizedBox(height: rowGap),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.marketingAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('marketing'),
          onOpen: () => showSignupTermSheet(context, 'marketing'),
          title: '마케팅 알림 수신 동의',
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required BuildContext context,
    required bool value,
    required VoidCallback onChanged,
    VoidCallback? onOpen,
    required String title,
    bool isRequired = false,
    bool isTitle = false,
    bool showRequired = true,
  }) {
    final double fontScale = ResponsiveSize.fontScale(context);

    final TextStyle titleStyle = TextStyle(
      fontSize: (isTitle ? 16 : 15) * fontScale,
      fontWeight: isTitle ? FontWeight.w700 : FontWeight.w500,
      letterSpacing: isTitle ? -0.2 : 0,
      color: AppColors.textPrimary,
      decoration: isTitle ? TextDecoration.none : TextDecoration.underline,
      decorationColor: AppColors.border,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? newValue) => onChanged(),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
          activeColor: AppColors.primary,
          checkColor: AppColors.white,
          side: const BorderSide(color: AppColors.textPrimary, width: 1.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isTitle ? onChanged : onOpen,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: title, style: titleStyle),
                    if (showRequired)
                      TextSpan(
                        text: ' ${isRequired ? '(필수)' : '(선택)'}',
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w500,
                          color:
                              isRequired
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
