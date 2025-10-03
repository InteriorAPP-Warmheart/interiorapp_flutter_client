import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/signin_signup/presentation/vm/signup_vm.dart';

/// 회원가입 폼 상태 관리 Provider
final signupFormProvider = NotifierProvider<SignupVm, SignupFormState>(
  SignupVm.new,
);

/// 닉네임 TextEditingController Provider
final nicknameControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  
  // 초기 닉네임 설정
  final initialNickname = ref.watch(signupFormProvider.select((state) => state.nickname));
  controller.text = initialNickname;
  
  // Provider가 dispose될 때 controller도 dispose
  ref.onDispose(() {
    controller.dispose();
  });
  
  return controller;
});

/// 약관 동의 상태만 따로 관리하는 Provider (선택적 사용)
final termsAgreementProvider = Provider<TermsAgreementState>((ref) {
  return ref.watch(signupFormProvider.select((state) => state.termsAgreement));
});

/// 회원가입 가능 여부 Provider
final canSignupProvider = Provider<bool>((ref) {
  return ref.watch(signupFormProvider.select((state) => state.canSignup));
});
