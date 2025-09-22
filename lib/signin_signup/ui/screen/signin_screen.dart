import 'package:flutter/material.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('하우핏에 오신 것을\n환영합니다', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          
        ],
      ),
      ));
  }
}
