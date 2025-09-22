import 'package:flutter/material.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'XXX에 오신 것을\n환영합니다',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  // === login buttons ===
                  // Google (권장: Outlined 스타일)
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 330, bottom: 15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/kakao_icon.png',
                      width: 20,
                      height: 20,
                    ),

                    label: const Text(
                      '카카오로 계속하기',
                      style: TextStyle(
                        color: Color(0xD9000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                padding: EdgeInsets.only(bottom: 15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
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
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: 18,
                      height: 18,
                    ),
                    label: const Text(
                      'Google로 계속하기',
                      style: TextStyle(
                        color: Color(0xFF3C4043),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Color(0xFFDADCE0), width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
