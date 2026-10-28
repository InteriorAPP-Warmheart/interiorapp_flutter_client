import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';

/// 원본 파일 이름과 내려받기 자리.
void showOriginalFileSheet(BuildContext context, {required String fileName}) {
  final double fontScale = ResponsiveSize.fontScale(context);
  showAppBottomSheet<void>(
    context: context,
    title: '원본 내려받기',
    size: AppBottomSheetSize.compact,
    message: fileName,
    child: Align(
      alignment: Alignment.topLeft,
      child: Text(
        '앱에서 본 내용과 같은 파일을 그대로 받아요.',
        style: TextStyle(
          fontSize: 15 * fontScale,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  );
}
