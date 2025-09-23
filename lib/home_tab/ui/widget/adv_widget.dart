// == 광고 위젯 ==
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

class AdvWidget extends StatefulWidget {
  final List<String> imageUrls;
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

  const AdvWidget({
    super.key,
    required this.imageUrls,
    this.height = 280.0,
    this.useResponsiveHeight = true,
    this.aspectRatio, // 예: 16/9, 4/3 등
    this.minHeight = 280.0,
    this.maxHeight = 280.0,
    this.borderRadius = 12.0,
    this.showIndicators = true,
    this.indicatorColor = Colors.white54,
    this.activeIndicatorColor = Colors.white,
    this.indicatorSize = 8.0,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.autoPlay = true,
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth.isFinite
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

        return SizedBox(
          width: double.infinity,
          height: effectiveHeight,
          child: Stack(
            children: [
              // 이미지 슬라이더
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    width: double.infinity,
                    height: effectiveHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: effectiveHeight,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: widget.imageUrls.length > 1,
                  autoPlay: widget.autoPlay && widget.imageUrls.length > 1,
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
              if (widget.showIndicators && widget.imageUrls.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.imageUrls.asMap().entries.map((entry) {
                        return Container(
                          width: widget.indicatorSize,
                          height: widget.indicatorSize,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == entry.key
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
