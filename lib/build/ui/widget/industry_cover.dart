import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 업종 표지. 카페만 시험 이미지가 있고, 나머지는 단색이다.
String? industryCoverAsset(String industry) {
  if (industry.contains('카페')) {
    return 'assets/images/app_images/wapll_cafe.png';
  }
  return null;
}

class IndustryCover extends StatelessWidget {
  const IndustryCover({super.key, required this.industry});

  final String industry;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final String? asset = industryCoverAsset(industry);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (asset == null)
          const ColoredBox(color: AppColors.primary)
        else
          Image.asset(asset, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0xCC0B1F38)],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '업종',
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xE6FFFFFF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                industry,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28 * fontScale,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

SliverAppBar industryCoverBar(String industry) {
  return SliverAppBar(
    primary: false,
    automaticallyImplyLeading: false,
    pinned: false,
    toolbarHeight: 0,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.background,
    expandedHeight: 248,
    flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: IndustryCover(industry: industry),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(24),
      child: SizedBox(
        height: 24,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
    ),
  );
}
