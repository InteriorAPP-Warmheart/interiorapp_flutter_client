import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

class PostSection extends ConsumerWidget {
    final String sectionTitle;
    final VoidCallback onPressed;
    final Widget child;


  const PostSection({
    super.key,
    required this.sectionTitle,
    required this.onPressed,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double fontScale = ResponsiveSize.fontScale(context);
    
    return Section(
      title: Text(
        sectionTitle,
        style: TextStyle(
          fontSize: 18 * fontScale,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.black,
          ),
        ),
        child: const Text('더보기', style: TextStyle(color: Colors.black)),
      ),
      gap: ResponsiveSize.subGap(context) * 0,
      child: child,
    );
  }
}
