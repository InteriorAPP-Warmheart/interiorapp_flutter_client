import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Center(child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('로그인이 필요한 서비스입니다.'),
          TextButton(onPressed: () {
            context.push('/signin');
          }, child: Text('로그인 하러가기'))
        ],
      ),
      ),
    );
  }
}
