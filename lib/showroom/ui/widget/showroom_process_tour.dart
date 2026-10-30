import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 공사 시작이 위, 마감이 아래다. 공정 이름과 번호로 순서가 읽힌다.
class ShowroomProcessTour extends StatelessWidget {
  const ShowroomProcessTour({super.key, required this.frames, this.wrapPhoto});

  final List<ShowroomProcessFrame> frames;
  final Widget Function(int index, ShowroomProcessFrame frame, Widget photo)?
  wrapPhoto;

  @override
  Widget build(BuildContext context) {
    if (frames.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < frames.length; i++) ...[
          _ProcessStep(frame: frames[i], index: i, wrapPhoto: wrapPhoto),
          if (i != frames.length - 1) const _ProcessJoin(),
        ],
      ],
    );
  }
}

class _ProcessJoin extends StatelessWidget {
  const _ProcessJoin();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 28,
      child: Center(
        child: SizedBox(
          width: 1,
          height: 28,
          child: ColoredBox(color: Color(0xFFD5D0C8)),
        ),
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.frame,
    required this.index,
    this.wrapPhoto,
  });

  final ShowroomProcessFrame frame;
  final int index;
  final Widget Function(int index, ShowroomProcessFrame frame, Widget photo)?
  wrapPhoto;

  @override
  Widget build(BuildContext context) {
    final String trade = frame.trade.trim();
    final String caption = frame.caption.trim();
    final String order = '${index + 1}'.padLeft(2, '0');
    final Widget still = Stack(
      fit: StackFit.expand,
      children: [_ProcessStill(url: frame.imageUrl)],
    );
    return Padding(
      padding: ResponsiveSize.textInset(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Color(0xFF8A847A),
                ),
              ),
              if (trade.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trade,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: storyInk,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: wrapPhoto?.call(index, frame, still) ?? still,
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              caption,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.45,
                letterSpacing: -0.2,
                color: storyInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProcessStill extends StatelessWidget {
  const _ProcessStill({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return const ColoredBox(color: AppColors.imagePlaceholder);
    }
    return AppNetworkImage(url: url);
  }
}
