import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key, this.embedded = false});

  /// 탭 안에서는 셸 앱바를 쓰고, 단독 라우트일 때만 자체 앱바를 둔다.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);

    return Scaffold(
      appBar:
          embedded
              ? null
              : AppBar(
                toolbarHeight: ResponsiveSize.appBarHeight(context),
                title: const Text('마이'),
              ),
      body: Center(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '로그인이 필요한 서비스입니다.',
                style: TextStyle(fontSize: 16 * fontScale),
              ),
              SizedBox(height: ResponsiveSize.subGap(context)),
              TextButton(
                onPressed: () {
                  context.push('/signin');
                },
                child: Text(
                  '로그인 하러가기',
                  style: TextStyle(fontSize: 16 * fontScale),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
