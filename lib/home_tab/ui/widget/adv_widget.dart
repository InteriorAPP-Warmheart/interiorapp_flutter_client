// == 광고 위젯 ==
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/util/responsive_size.dart';

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
    this.height = 200.0,
    this.useResponsiveHeight = true,
    this.aspectRatio, // 예: 16/9, 4/3 등
    this.minHeight = 140.0,
    this.maxHeight = 360.0,
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

// 사용 예시를 위한 데모 위젯
class ImageSliderDemo extends StatelessWidget {
  const ImageSliderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 샘플 이미지 URL들 (실제 사용시에는 실제 이미지 URL로 교체)
    final List<String> sampleImages = [
      'https://picsum.photos/400/300?random=1',
      'https://picsum.photos/400/300?random=2',
      'https://picsum.photos/400/300?random=3',
      'https://picsum.photos/400/300?random=4',
      'https://picsum.photos/400/300?random=5',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 슬라이더 데모'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 슬라이더
            const Text(
              '기본 슬라이더',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AdvWidget(
              imageUrls: sampleImages,
              height: 200,
            ),
            
            const SizedBox(height: 32),
            
            // 커스텀 스타일 슬라이더
            const Text(
              '커스텀 스타일 슬라이더',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AdvWidget(
              imageUrls: sampleImages.take(3).toList(),
              height: 250,
              borderRadius: 20,
              indicatorColor: Colors.grey[400]!,
              activeIndicatorColor: Colors.blue[600]!,
              indicatorSize: 10,
              autoPlayInterval: const Duration(seconds: 2),
            ),
            
            const SizedBox(height: 32),
            
            // 인디케이터 없는 슬라이더
            const Text(
              '인디케이터 없는 슬라이더',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AdvWidget(
              imageUrls: sampleImages.take(2).toList(),
              height: 180,
              showIndicators: false,
              autoPlay: false,
            ),
          ],
        ),
      ),
    );
  }
}
