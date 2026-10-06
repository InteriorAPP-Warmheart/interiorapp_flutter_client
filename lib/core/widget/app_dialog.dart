import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 화면 공통 다이얼로그.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    required this.actions,
  });

  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.45,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                actions[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  required List<Widget> Function(BuildContext dialogContext) actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AppDialog(
        title: title,
        message: message,
        actions: actions(dialogContext),
      );
    },
  );
}
