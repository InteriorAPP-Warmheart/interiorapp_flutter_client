import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 번들에 없는 에셋 이미지. 빌드와 실행은 이어 가고, 칸에는 없음 아이콘을 둔다.
class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = false,
    this.excludeFromSemantics = false,
    this.semanticLabel,
    this.placeholderColor = AppColors.imagePlaceholder,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;
  final bool excludeFromSemantics;
  final String? semanticLabel;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
      excludeFromSemantics: excludeFromSemantics,
      semanticLabel: semanticLabel,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        final Widget placeholder = MissingAssetPlaceholder(
          color: placeholderColor,
        );
        if (excludeFromSemantics) {
          return ExcludeSemantics(child: placeholder);
        }
        return placeholder;
      },
    );
  }
}

/// 사진을 읽지 못했을 때 칸을 채우는 없음 표시.
class MissingAssetPlaceholder extends StatelessWidget {
  const MissingAssetPlaceholder({
    super.key,
    this.color = AppColors.imagePlaceholder,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: _iconSize(constraints),
              color: AppColors.textSecondary,
              semanticLabel: '이미지 없음',
            ),
          );
        },
      ),
    );
  }
}

double _iconSize(BoxConstraints constraints) {
  final double width = constraints.maxWidth;
  final double height = constraints.maxHeight;
  final double side;
  if (width.isFinite && height.isFinite) {
    side = width < height ? width : height;
  } else if (width.isFinite) {
    side = width;
  } else if (height.isFinite) {
    side = height;
  } else {
    return 24;
  }
  if (side <= 0) return 12;
  final double scaled = side * 0.45;
  if (scaled < 12) return 12;
  if (scaled > 28) return 28;
  return scaled;
}
