import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';

/// 장바구니 자리에 임시로 붙여 둔 공통 레이아웃 확인.
void showLayoutPreview(BuildContext context) {
  showAppDialog(
    context: context,
    title: '공통 레이아웃',
    message: '버튼으로 바텀시트 크기를 확인합니다.',
    actions: (BuildContext dialogContext) {
      return [
        AppButton(
          label: '작은 바텀시트',
          variant: AppButtonVariant.secondary,
          onPressed: () {
            Navigator.of(dialogContext).pop();
            showAppBottomSheet(
              context: context,
              title: '작은 바텀시트',
              message: '화면 높이의 약 40%입니다.',
              size: AppBottomSheetSize.compact,
            );
          },
        ),
        AppButton(
          label: '큰 바텀시트',
          onPressed: () {
            Navigator.of(dialogContext).pop();
            showAppBottomSheet(
              context: context,
              title: '큰 바텀시트',
              message: '화면 높이의 약 85%입니다.',
              size: AppBottomSheetSize.expanded,
            );
          },
        ),
      ];
    },
  );
}
