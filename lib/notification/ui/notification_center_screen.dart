import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: ResponsiveSize.appBarHeight(context),
        title: const Text('알림'),
      ),
      body: Center(
        child: Text(
          '알림이 없습니다.',
          style: TextStyle(fontSize: 16 * ResponsiveSize.fontScale(context)),
        ),
      ),
    );
  }
}
