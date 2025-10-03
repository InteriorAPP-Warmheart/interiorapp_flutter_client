import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/signin_signup/presentation/provider/signup_provider.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

class CheckboxSection extends ConsumerWidget {
  const CheckboxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAgreement = ref.watch(termsAgreementProvider);
    
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
        SizedBox(height: ResponsiveSize.subGap(context)),
        
        // 개별 약관들
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.serviceTermsAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('service'),
          title: '서비스 이용약관 동의',
          isRequired: true,
        ),
        SizedBox(height: ResponsiveSize.subGap(context)),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.ageConfirmationAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('age'),
          title: '만 14세 이상 확인',
          isRequired: true,
        ),
        SizedBox(height: ResponsiveSize.subGap(context)),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.privacyCollectionAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('privacyCollection'),
          title: '개인정보 수집 이용 동의',
          isRequired: true,
        ),
        SizedBox(height: ResponsiveSize.subGap(context)),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.privacyUseAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('privacyUse'),
          title: '개인정보 처리 방침 동의',
          isRequired: true,
        ),
        SizedBox(height: ResponsiveSize.subGap(context)),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.locationServiceAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('location'),
          title: '위치기반 서비스 이용약관 동의',
          isRequired: false,
        ),
        SizedBox(height: ResponsiveSize.subGap(context)),
        
        _buildCheckboxRow(
          context: context,
          value: termsAgreement.marketingAgreed,
          onChanged: () => ref.read(signupFormProvider.notifier).toggleTermAgreement('marketing'),
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
    required String title,
    bool isRequired = false,
    bool isTitle = false,
    bool showRequired = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Expanded(
          child: Row(
            children: [
              if (isTitle)
                GestureDetector(
                  onTap: onChanged,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    // TODO: 약관 내용 보기 페이지로 이동
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF000000),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
              if (showRequired) ...[
                SizedBox(width: 4),
                Text(
                  isRequired ? '(필수)' : '(선택)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
