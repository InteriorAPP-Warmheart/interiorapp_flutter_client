import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 프로필 사진. 화면 너비의 5:4로 두고, 변경은 사진 위의 버튼으로만 한다.
class ProfilePhotoCover extends StatelessWidget {
  const ProfilePhotoCover({
    super.key,
    required this.photoUrl,
    this.onChangePhoto,
    this.changeButtonBottom = 16,
  });

  final String? photoUrl;
  final VoidCallback? onChangePhoto;
  final double changeButtonBottom;

  static double heightFor(double width) {
    return (width * 5 / 4).clamp(340, 480);
  }

  @override
  Widget build(BuildContext context) {
    final String? url = photoUrl != null && photoUrl!.isNotEmpty ? photoUrl : null;
    final double fontScale = ResponsiveSize.fontScale(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height =
            constraints.hasBoundedHeight
                ? constraints.maxHeight
                : heightFor(constraints.maxWidth);
        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url == null)
                const ColoredBox(color: AppColors.primary)
              else
                AppNetworkImage(url: url),
              if (url == null)
                const Align(
                  alignment: Alignment(0, -0.12),
                  child: Icon(
                    Icons.person_rounded,
                    size: 88,
                    color: Color(0x66FFFFFF),
                  ),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x00000000), Color(0x660B1F38)],
                  ),
                ),
              ),
              if (onChangePhoto != null)
                Positioned(
                  right: 16,
                  bottom: changeButtonBottom,
                  child: _PhotoChangeButton(
                    fontScale: fontScale,
                    onPressed: onChangePhoto!,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoChangeButton extends StatelessWidget {
  const _PhotoChangeButton({required this.fontScale, required this.onPressed});

  final double fontScale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC0B1F38),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 16,
                color: AppColors.white,
              ),
              const SizedBox(width: 6),
              Text(
                '사진 변경',
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
