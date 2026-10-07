import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'FavoriteScreen',
          style: TextStyle(fontSize: 16 * ResponsiveSize.fontScale(context)),
        ),
      ),
    );
  }
}