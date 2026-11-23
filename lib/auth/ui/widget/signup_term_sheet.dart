import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';

/// 가입 약관 한 건. 본문은 확정 전 초안이다.
class SignupTerm {
  const SignupTerm({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}

SignupTerm? signupTermFor(String key) {
  return switch (key) {
    'service' => const SignupTerm(
      title: '서비스 이용약관',
      paragraphs: [
        '본문은 확정 전 초안입니다. 약관이 정해지면 이 글을 바꿉니다.',
        '1. 목적\n이 약관은 와플이 제공하는 인테리어 상담, 쇼룸, 시공 진행 서비스를 이용하는 조건과 회사와 회원의 권리, 의무를 정합니다.',
        '2. 계정\n회원은 정확한 정보로 가입하고, 계정과 비밀번호를 직접 관리합니다. 계정을 다른 사람에게 넘기지 않습니다.',
        '3. 서비스 이용\n쇼룸, 상담, 견적, 시공 진행은 서비스 안내에 따라 이용합니다. 회사는 운영상 필요할 때 서비스의 일부를 바꿀 수 있습니다.',
        '4. 금지 행위\n타인의 정보를 도용하거나, 서비스 운영을 방해하거나, 법령에 어긋나는 내용을 올리지 않습니다.',
      ],
    ),
    'age' => const SignupTerm(
      title: '만 14세 이상 확인',
      paragraphs: [
        '본문은 확정 전 초안입니다. 약관이 정해지면 이 글을 바꿉니다.',
        '와플은 만 14세 미만 아동의 개인정보를 받지 않습니다. 가입하는 사람은 만 14세 이상임을 확인합니다.',
      ],
    ),
    'privacyCollection' => const SignupTerm(
      title: '개인정보 수집 이용 동의',
      paragraphs: [
        '본문은 확정 전 초안입니다. 약관이 정해지면 이 글을 바꿉니다.',
        '1. 수집 항목\n닉네임, 연락처, 상담과 시공에 필요한 공간 정보, 서비스 이용 기록.',
        '2. 이용 목적\n회원 식별, 상담과 견적, 시공 진행 안내, 고객 문의 대응.',
        '3. 보유 기간\n회원 탈퇴 시까지. 법령에서 정한 기간이 있으면 그 기간 동안 보관합니다.',
      ],
    ),
    'privacyUse' => const SignupTerm(
      title: '개인정보 처리 방침',
      paragraphs: [
        '본문은 확정 전 초안입니다. 약관이 정해지면 이 글을 바꿉니다.',
        '1. 처리하는 정보\n가입 정보, 상담과 시공 기록, 서비스 이용 중 생기는 기록.',
        '2. 제3자 제공\n시공 진행에 필요한 범위에서, 동의를 받은 뒤 관련 업체에 제공할 수 있습니다.',
        '3. 권리\n회원은 자신의 개인정보 열람, 정정, 삭제를 요청할 수 있습니다.',
      ],
    ),
    'location' => const SignupTerm(
      title: '위치기반 서비스 이용약관',
      paragraphs: [
        '본문은 확정 전 초안입니다. 약관이 정해지면 이 글을 바꿉니다.',
        '1. 목적\n상담 공간과 쇼룸의 위치를 맞추고, 가까운 사례를 보여 주기 위해 위치 정보를 사용합니다.',
        '2. 이용\n위치 정보는 해당 기능에만 쓰고, 동의하지 않아도 그 밖의 서비스는 이용할 수 있습니다.',
      ],
    ),
    'marketing' => const SignupTerm(
      title: '마케팅 알림 수신 동의',
      paragraphs: [
        '본문은 확정 전 초안입니다. 약관이 정해지면 이 글을 바꿉니다.',
        '이벤트, 혜택, 새 쇼룸 소식을 알림으로 보낼 수 있습니다. 동의하지 않아도 가입과 필수 안내는 받을 수 있고, 나중에 수신을 끌 수 있습니다.',
      ],
    ),
    _ => null,
  };
}

Future<void> showSignupTermSheet(BuildContext context, String key) {
  final SignupTerm? term = signupTermFor(key);
  if (term == null) return Future<void>.value();
  final double fontScale = ResponsiveSize.fontScale(context);

  return showAppBottomSheet<void>(
    context: context,
    title: term.title,
    size: AppBottomSheetSize.expanded,
    child: SingleChildScrollView(
      child: Text(
        term.paragraphs.join('\n\n'),
        style: TextStyle(
          fontSize: 14 * fontScale,
          height: 1.55,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  );
}
