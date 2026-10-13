import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);

    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: screenPadding.copyWith(top: sectionGap, bottom: sectionGap),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'XXX에 오신 것을\n환영합니다',
                          style: TextStyle(fontSize: 26 * fontScale, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: [
              Padding(
                padding: EdgeInsets.only(bottom: subGap),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/kakao_icon.png',
                      width: 20,
                      height: 20,
                    ),

                    label: Text(
                      '카카오로 계속하기',
                      style: TextStyle(
                        color: const Color(0xD9000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * fontScale,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xFFFEE500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: subGap),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.apple, size: 22),
                    label: const Text('Apple로 로그인'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: TextStyle(fontSize: 16 * fontScale),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: sectionGap),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: 18,
                      height: 18,
                    ),
                    label: Text(
                      'Google로 계속하기',
                      style: TextStyle(
                        color: const Color(0xFF3C4043),
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFDADCE0),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: Text(
                  '테스트용 회원가입 페이지',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
