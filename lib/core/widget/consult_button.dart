import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 홈의 상담받기 버튼을 펼친 모양 그대로 둔 버튼. 남색 둥근 막대에 그림자, 같은 글자를 쓴다.
class ConsultButton extends StatelessWidget {
  const ConsultButton({
    super.key,
    required this.onPressed,
    this.label = '상담받기',
    this.height = 56,
    this.expand = false,
    this.onImage = false,
  });

  final VoidCallback onPressed;
  final String label;
  final double height;

  /// 가로를 다 채운다. 비우면 글자 폭에 맞춘다.
  final bool expand;

  /// 남색 사진 위에 놓일 때. 모양은 같고 흰 바탕에 남색 글자로 뒤집는다.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final Color background = onImage ? AppColors.white : AppColors.primary;
    final Color foreground = onImage ? AppColors.primary : AppColors.white;

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: Material(
        color: background,
        elevation: 2,
        shadowColor: const Color(0x33000000),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: height * 0.36),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.support_agent_outlined,
                  color: foreground,
                  size: height >= 52 ? 22 : 19,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
