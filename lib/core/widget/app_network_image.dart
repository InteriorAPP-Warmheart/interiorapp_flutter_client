import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 목록과 카드에서 같은 비율, 같은 로딩·실패 상태로 사진을 보여 준다.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderColor = AppColors.imagePlaceholder,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (context, imageUrl) => ColoredBox(color: placeholderColor),
      errorWidget: (context, imageUrl, error) {
        return ColoredBox(
          color: placeholderColor,
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              size: 28,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
