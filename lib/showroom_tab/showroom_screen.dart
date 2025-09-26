import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/image_slider_widget.dart';
import 'package:interiorapp_flutter_client/showroom_tab/ui/widget/filter_button.dart';
import 'package:interiorapp_flutter_client/showroom_tab/ui/widget/post_section.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

class ShowroomScreen extends ConsumerStatefulWidget {
  const ShowroomScreen({super.key});

  @override
  ConsumerState<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends ConsumerState<ShowroomScreen> {
  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //광고 Section
              Container(
                color: const Color.fromARGB(255, 233, 233, 233),
                height: 150,
                width: double.infinity,
                child: Center(child: Text('광고', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 20),)),
              ),
              SizedBox(height: sectionGap),
              Padding(
                padding: screenPadding,
                child: Column(
                  children: [
                    // 필터링 Section
                    Row(
                      children: [
                        FilterButton(text: '필터'),
                        SizedBox(width: 8),
                        FilterButton(text: '스타일'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        FilterButton(text: '공간 형태'),
                        SizedBox(width: 8),
                        FilterButton(text: '예산'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        FilterButton(text: '톤앤매너'),
                        SizedBox(width: 8),
                        FilterButton(text: '소재'),
                      ],
                    ),
                    SizedBox(height: sectionGap),

                    //인기 쇼룸 Section
                    PostSection(
                      fontScale: fontScale,
                      ref: ref,
                      sectionTitle: '인기 쇼룸',
                      onPressed: () {},
                      child: ImageSliderWidget().showroomInfo(ref: ref),
                    ),
                    SizedBox(height: sectionGap),

                    //동네 게시물 Section
                    PostSection(
                      fontScale: fontScale,
                      ref: ref,
                      sectionTitle: '동네 게시물',
                      onPressed: () {},
                      child: ImageSliderWidget().showroomInfo(ref: ref),
                    ),
                    SizedBox(height: sectionGap),

                    //추천 시공 Section
                    PostSection(
                      fontScale: fontScale,
                      ref: ref,
                      sectionTitle: '추천 시공',
                      onPressed: () {},
                      child: ImageSliderWidget().recommendBuildInfo(ref: ref),
                    ),
                    SizedBox(height: sectionGap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: SizedBox(
        width: 100,
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {},
          icon: Icon(Icons.add, color: Colors.black, size: 18),
          label: Text(
            '글쓰기',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 253, 252, 252),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // 모서리 둥근 값
            side: BorderSide(color: Colors.white, width: 0), // 테두리 없음
          ),
          extendedIconLabelSpacing: 2,
        ),
      ),
    );
  }
}
