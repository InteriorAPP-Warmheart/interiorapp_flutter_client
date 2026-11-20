// == 광고 위젯 ==
import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 홈 상단 슬라이드 한 장. 설명이 있으면 사진 아래에 올린다.
class AdvSlide {
  const AdvSlide({required this.imageUrl, this.title = '', this.body = ''});

  final String imageUrl;
  final String title;
  final String body;

  bool get hasCaption => title.isNotEmpty || body.isNotEmpty;
}

class AdvWidget extends StatefulWidget {
  final List<AdvSlide> slides;
  final double height; // 수동 지정 높이 (useResponsiveHeight=false일 때 사용)
  final bool useResponsiveHeight; // 화면 너비/비율 기반으로 높이 자동 계산
  final double? aspectRatio; // null이면 내부 브레이크포인트로 결정
  final double minHeight; // 응답형 계산 높이 하한
  final double maxHeight; // 응답형 계산 높이 상한
  final double borderRadius;
  final bool showIndicators;
  final Color indicatorColor;
  final Color activeIndicatorColor;
  final double indicatorSize;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final ValueChanged<AdvSlide>? onTap;

  const AdvWidget({
    super.key,
    required this.slides,
    this.height = 280.0,
    this.useResponsiveHeight = true,
    this.aspectRatio, // 예: 16/9, 4/3 등
    this.minHeight = 160.0,
    this.maxHeight = 420.0,
    this.borderRadius = 12.0,
    this.showIndicators = true,
    this.indicatorColor = Colors.white54,
    this.activeIndicatorColor = Colors.white,
    this.indicatorSize = 8.0,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.autoPlay = true,
    this.onTap,
  });

  @override
  State<AdvWidget> createState() => _ImageSliderWidgetState();
}

class _ImageSliderWidgetState extends State<AdvWidget> {
  int _currentIndex = 0;
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
  }

  @override
  void didUpdateWidget(covariant AdvWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int count = widget.slides.length;
    if (count == oldWidget.slides.length) return;
    final int next = count == 0 ? 0 : _currentIndex.clamp(0, count - 1);
    _currentIndex = next;
    if (count == 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.slides.length != count) return;
      _carouselController.jumpToPage(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;

        final double effectiveHeight = ResponsiveSize.bannerHeight(
          context,
          maxWidth: maxWidth,
          aspectRatio: widget.aspectRatio,
          minHeight: widget.minHeight,
          maxHeight: widget.maxHeight,
          useResponsiveHeight: widget.useResponsiveHeight,
          fixedHeight: widget.height,
        );

        if (widget.slides.isEmpty) {
          return SizedBox(width: double.infinity, height: effectiveHeight);
        }

        return SizedBox(
          width: double.infinity,
          height: effectiveHeight,
          child: Stack(
            children: [
              // 이미지 슬라이더
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: widget.slides.length,
                itemBuilder: (context, index, realIndex) {
                  final AdvSlide slide = widget.slides[index];
                  return GestureDetector(
                    onTap:
                        widget.onTap == null
                            ? null
                            : () => widget.onTap!(slide),
                    child: Container(
                      width: double.infinity,
                      height: effectiveHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(url: slide.imageUrl),
                            if (slide.hasCaption) _SlideCaption(slide: slide),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: effectiveHeight,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: widget.slides.length > 1,
                  autoPlay: widget.autoPlay && widget.slides.length > 1,
                  autoPlayInterval: widget.autoPlayInterval,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),

              // 인디케이터 (우측 상단 오버레이)
              if (widget.showIndicators && widget.slides.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          widget.slides.asMap().entries.map((entry) {
                            return Container(
                              width: widget.indicatorSize,
                              height: widget.indicatorSize,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 3.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentIndex == entry.key
                                        ? widget.activeIndicatorColor
                                        : widget.indicatorColor,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SlideCaption extends StatelessWidget {
  const _SlideCaption({required this.slide});

  final AdvSlide slide;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 108,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[Color(0xC4000000), Color(0x00000000)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (slide.title.isNotEmpty)
                Text(
                  slide.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                    color: AppColors.white,
                  ),
                ),
              if (slide.body.isNotEmpty) ...[
                if (slide.title.isNotEmpty) const SizedBox(height: 4),
                Text(
                  slide.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: const Color(0xF2FFFFFF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
