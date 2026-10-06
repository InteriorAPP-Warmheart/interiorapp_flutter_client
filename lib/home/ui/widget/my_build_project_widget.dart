import 'package:flutter/material.dart';

class MyBuildProjectWidget extends StatelessWidget {
  final bool atBottom;
  const MyBuildProjectWidget({super.key, required this.atBottom});

  @override
  Widget build(BuildContext context) {
    double progress = 0.65; // 65%
    return !atBottom
        ? Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final double h = constraints.maxHeight;

              final double horizontalGap = w * 0.04; // 4% of width
              final double verticalPad = h * 0.12; // 12% of height
              final double imageSide = h * 0.76; // 76% of height

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalGap,
                  vertical: verticalPad,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: imageSide,
                      height: imageSide,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(imageSide * 0.2),
                        child: Image.network(
                          'https://picsum.photos/seed/case6/900/600',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: horizontalGap),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + percent
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '뒷간 만들기 대작전',
                                  style: TextStyle(
                                    fontSize: h * 0.18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: w * 0.02),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: h * 0.18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.02),
                          // Progress bar
                          SizedBox(
                            height: h * 0.10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: h * 0.12,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation(Colors.blue),
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.05),
                          // Meta row: schedule | category
                          Row(
                            children: [
                              Text(
                                '오늘 공사 방문 예정이에요!',
                                style: TextStyle(
                                  fontSize: h * 0.12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(
                                height: 12, // 텍스트 높이와 맞춤
                                child: VerticalDivider(
                                  width: 10, // 좌우 여백 포함
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '욕실 리모델링',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: h * 0.12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
        // 스크롤 끝까지 내릴 경우
        : Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.05,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '내 프로젝트 진행률 ${progress * 100}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF656565),
              ),
            ),
          ),
        );
  }
}
