import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '검색어를 입력하세요',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFocusChanged,
    this.autofocus = false,
    this.widthRatio,
    this.heightRatio,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final ValueChanged<bool>? onFocusChanged;
  final bool autofocus;
  final double? widthRatio; // 화면 너비 대비 비율 (0.0 ~ 1.0)
  final double? heightRatio; // 화면 높이 대비 비율 (0.0 ~ 1.0)

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? TextEditingController();
    final focus = focusNode ?? FocusNode();
    final double fontScale = ResponsiveSize.fontScale(context);
    final screenSize = MediaQuery.of(context).size;

    final width = widthRatio != null ? screenSize.width * widthRatio! : null;
    final height =
        heightRatio != null ? screenSize.height * heightRatio! : null;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: textController,
          builder: (context, value, _) {
            final hasText = value.text.isNotEmpty;
            return TextField(
              controller: textController,
              focusNode: focus,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: AppColors.primary,
              cursorHeight: 20,
              style: TextStyle(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 15 * fontScale,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasText)
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        splashRadius: 12,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        onPressed: () {
                          textController.clear();
                          onClear?.call();
                          onChanged?.call('');
                        },
                      ),
                    // === Search Button ===
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      splashRadius: 12,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      onPressed: () {
                        onSubmitted?.call(textController.text);
                      },
                    ),
                  ],
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                border: InputBorder.none,
              ),
            );
          },
        ),
      ),
    );
  }
}
