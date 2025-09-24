import 'package:flutter/material.dart';

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
  final double? widthRatio;  // 화면 너비 대비 비율 (0.0 ~ 1.0)
  final double? heightRatio; // 화면 높이 대비 비율 (0.0 ~ 1.0)

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? TextEditingController();
    final focus = focusNode ?? FocusNode();
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    final width = widthRatio != null ? screenSize.width * widthRatio! : null;
    final height = heightRatio != null ? screenSize.height * heightRatio! : null;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
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
            cursorColor: Colors.black,
            cursorHeight: 20,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: Color(0xFFD6D6D6),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasText)
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.black45),
                      splashRadius: 16,
                      onPressed: () {
                        textController.clear();
                        onClear?.call();
                        onChanged?.call('');
                      },
                    ),
                  // === Search Button ===
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black45),
                    splashRadius: 16,
                    onPressed: () {
                      onSubmitted?.call(textController.text);
                    },
                  ),
                ],
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
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
