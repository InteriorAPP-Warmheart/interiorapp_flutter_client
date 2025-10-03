import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/signin_signup/ui/widget/checkbox_section.dart';
import 'package:interiorapp_flutter_client/signin_signup/presentation/provider/signup_provider.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);
    final nicknameController = ref.watch(nicknameControllerProvider);
    final signupForm = ref.watch(signupFormProvider);
    final canSignup = ref.watch(canSignupProvider);

    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: SingleChildScrollView(
        child: Padding(
          padding: screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'XXX 이용을 위해\n필요해요',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: ResponsiveSize.sectionGap(context)),

              // 닉네임 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '닉네임',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: () => _generateRandomNickname(ref),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Color(0xFF007AFF),
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFD6D6D6),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFD6D6D6), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    // borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
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
                  foregroundColor: Color(0xFF000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 48),
                  side: BorderSide(color: Color(0xFFD6D6D6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '중복 확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (signupForm.isNicknameDuplicateChecked) ...[
                      SizedBox(width: 8),
                      Icon(Icons.check, color: Color(0xFF007AFF), size: 20),
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

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canSignup ? () => _signup(ref) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canSignup ? Color(0xFF007AFF) : Color(0xFFE5E5E5),
                    foregroundColor:
                        canSignup ? Colors.white : Color(0xFF999999),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '완료',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
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
        backgroundColor: Color(0xFF007AFF),
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
        backgroundColor: Color(0xFF34C759),
      ),
    );
  }
}
