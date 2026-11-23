import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_font_scale.dart';

class PostSection extends StatelessWidget {
  final String sectionTitle;
  final Widget child;

  const PostSection({
    super.key,
    required this.sectionTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double fontScale =
        ShowroomFontScale.applied(context)
            ? 1
            : ResponsiveSize.fontScale(context);
    final Widget title = Text(
      sectionTitle,
      style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold),
    );

    return Section(
      title: title,
      gap: ResponsiveSize.subGap(context),
      child: child,
    );
  }
}
