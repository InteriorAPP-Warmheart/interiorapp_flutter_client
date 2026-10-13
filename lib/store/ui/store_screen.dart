import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'StoreScreen',
          style: TextStyle(fontSize: 16 * ResponsiveSize.fontScale(context)),
        ),
      ),
    );
  }
}
