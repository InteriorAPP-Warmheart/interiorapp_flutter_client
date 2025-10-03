import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/signin_signup/domain/nickname_generator.dart';

/// 약관 동의 상태를 관리하는 모델
class TermsAgreementState {
  final bool allAgreed;
  final bool serviceTermsAgreed;
  final bool ageConfirmationAgreed;
  final bool privacyCollectionAgreed;
  final bool privacyUseAgreed;
  final bool locationServiceAgreed;
  final bool marketingAgreed;

  TermsAgreementState({
    this.allAgreed = false,
    this.serviceTermsAgreed = false,
    this.ageConfirmationAgreed = false,
    this.privacyCollectionAgreed = false,
    this.privacyUseAgreed = false,
    this.locationServiceAgreed = false,
    this.marketingAgreed = false,
  });

  TermsAgreementState copyWith({
    bool? allAgreed,
    bool? serviceTermsAgreed,
    bool? ageConfirmationAgreed,
    bool? privacyCollectionAgreed,
    bool? privacyUseAgreed,
    bool? locationServiceAgreed,
    bool? marketingAgreed,
  }) {
    return TermsAgreementState(
      allAgreed: allAgreed ?? this.allAgreed,
      serviceTermsAgreed: serviceTermsAgreed ?? this.serviceTermsAgreed,
      ageConfirmationAgreed:
          ageConfirmationAgreed ?? this.ageConfirmationAgreed,
      privacyCollectionAgreed:
          privacyCollectionAgreed ?? this.privacyCollectionAgreed,
      privacyUseAgreed: privacyUseAgreed ?? this.privacyUseAgreed,
      locationServiceAgreed:
          locationServiceAgreed ?? this.locationServiceAgreed,
      marketingAgreed: marketingAgreed ?? this.marketingAgreed,
    );
  }

  /// 필수 약관이 모두 동의되었는지 확인
  bool get isRequiredTermsAgreed {
    return serviceTermsAgreed &&
        ageConfirmationAgreed &&
        privacyCollectionAgreed &&
        privacyUseAgreed;
  }
}

/// 회원가입 폼 상태를 관리하는 모델
class SignupFormState {
  final String nickname;
  final bool isNicknameDuplicateChecked;
  final TermsAgreementState termsAgreement;

  SignupFormState({
    this.nickname = '',
    this.isNicknameDuplicateChecked = false,
    TermsAgreementState? termsAgreement,
  }) : termsAgreement = termsAgreement ?? TermsAgreementState();

  SignupFormState copyWith({
    String? nickname,
    bool? isNicknameDuplicateChecked,
    TermsAgreementState? termsAgreement,
  }) {
    return SignupFormState(
      nickname: nickname ?? this.nickname,
      isNicknameDuplicateChecked:
          isNicknameDuplicateChecked ?? this.isNicknameDuplicateChecked,
      termsAgreement: termsAgreement ?? this.termsAgreement,
    );
  }

  /// 회원가입이 가능한지 확인 (닉네임 중복확인 + 필수 약관 동의)
  bool get canSignup {
    return nickname.isNotEmpty &&
        isNicknameDuplicateChecked &&
        termsAgreement.isRequiredTermsAgreed;
  }
}

/// 회원가입 ViewModel
class SignupVm extends Notifier<SignupFormState> {
  @override
  SignupFormState build() {
    // 초기 랜덤 닉네임 생성
    final initialNickname = NicknameGenerator.generateNickname();
    return SignupFormState(nickname: initialNickname);
  }

  /// 닉네임 업데이트
  void updateNickname(String nickname) {
    state = state.copyWith(
      nickname: nickname,
      isNicknameDuplicateChecked: false, // 닉네임 변경시 중복확인 초기화
    );
  }

  /// 닉네임 중복 확인
  void setNicknameDuplicateChecked(bool isChecked) {
    state = state.copyWith(isNicknameDuplicateChecked: isChecked);
  }

  /// 전체 약관 동의 토글
  void toggleAllTermsAgreement() {
    final currentAllAgreed = state.termsAgreement.allAgreed;
    final newAgreement = state.termsAgreement.copyWith(
      allAgreed: !currentAllAgreed,
      serviceTermsAgreed: !currentAllAgreed,
      ageConfirmationAgreed: !currentAllAgreed,
      privacyCollectionAgreed: !currentAllAgreed,
      privacyUseAgreed: !currentAllAgreed,
      locationServiceAgreed: !currentAllAgreed,
      marketingAgreed: !currentAllAgreed,
    );
    state = state.copyWith(termsAgreement: newAgreement);
  }

  /// 개별 약관 동의 토글
  void toggleTermAgreement(String termType) {
    TermsAgreementState newAgreement;

    switch (termType) {
      case 'service':
        newAgreement = state.termsAgreement.copyWith(
          serviceTermsAgreed: !state.termsAgreement.serviceTermsAgreed,
        );
        break;
      case 'age':
        newAgreement = state.termsAgreement.copyWith(
          ageConfirmationAgreed: !state.termsAgreement.ageConfirmationAgreed,
        );
        break;
      case 'privacyCollection':
        newAgreement = state.termsAgreement.copyWith(
          privacyCollectionAgreed:
              !state.termsAgreement.privacyCollectionAgreed,
        );
        break;
      case 'privacyUse':
        newAgreement = state.termsAgreement.copyWith(
          privacyUseAgreed: !state.termsAgreement.privacyUseAgreed,
        );
        break;
      case 'location':
        newAgreement = state.termsAgreement.copyWith(
          locationServiceAgreed: !state.termsAgreement.locationServiceAgreed,
        );
        break;
      case 'marketing':
        newAgreement = state.termsAgreement.copyWith(
          marketingAgreed: !state.termsAgreement.marketingAgreed,
        );
        break;
      default:
        return;
    }

    // 개별 약관 변경 후 전체 동의 상태 업데이트
    final allRequiredAgreed =
        newAgreement.serviceTermsAgreed &&
        newAgreement.ageConfirmationAgreed &&
        newAgreement.privacyCollectionAgreed &&
        newAgreement.privacyUseAgreed;

    final allOptionalAgreed =
        newAgreement.locationServiceAgreed && newAgreement.marketingAgreed;

    final finalAgreement = newAgreement.copyWith(
      allAgreed: allRequiredAgreed && allOptionalAgreed,
    );

    state = state.copyWith(termsAgreement: finalAgreement);
  }

  /// 랜덤 닉네임 생성
  void generateRandomNickname() {
    final randomNickname = NicknameGenerator.generateNickname();
    state = state.copyWith(
      nickname: randomNickname,
      isNicknameDuplicateChecked: false, // 새 닉네임이므로 중복확인 초기화
    );
  }

  /// 폼 초기화
  void resetForm() {
    state = SignupFormState();
  }
}
