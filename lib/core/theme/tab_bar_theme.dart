import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class AppTabBarTheme {
  static double iconSize(BuildContext context) =>
      20 * ResponsiveSize.fontScale(context);

  static TextStyle labelStyle(BuildContext context) => TextStyle(
        fontSize: 12 * ResponsiveSize.fontScale(context),
        fontWeight: FontWeight.w500,
      );

  static double height(BuildContext context) =>
      ResponsiveSize.bottomNavHeight(context);

  static BoxDecoration get decoration => BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
      );

  static Color get selectedColor => Colors.blue;
  static Color get unselectedColor => Colors.grey;

  static double get indicatorWeight => 2.0;
}
