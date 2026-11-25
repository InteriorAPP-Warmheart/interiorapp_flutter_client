import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 공간 사진 한 장을 넣고, 바꾸고, 지운다. 지우면 빈 문자열을 넘긴다.
class CoverPhotoField extends StatelessWidget {
  const CoverPhotoField({
    super.key,
    required this.photo,
    required this.onChanged,
  });

  final String photo;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2400,
      );
    } catch (_) {
      messenger?.showSnackBar(const SnackBar(content: Text('사진을 불러오지 못했어요')));
      return;
    }
    if (file == null) return;
    onChanged(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        final double height = (width * 9 / 16).clamp(168.0, 300.0);
        return SizedBox(
          width: double.infinity,
          height: height,
          child: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool empty = photo.trim().isEmpty;

    if (empty) {
      return Semantics(
        button: true,
        label: '공간 사진 추가',
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '공간 사진 추가',
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '목록과 상세의 표지가 돼요 · 1장',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _pick(context),
              child: AppNetworkImage(url: photo),
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x000B1F38), Color(0x990B1F38)],
                    stops: [0.55, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  _PhotoAction(
                    icon: Icons.sync_rounded,
                    label: '바꾸기',
                    fontScale: fontScale,
                    onTap: () => _pick(context),
                  ),
                  const SizedBox(width: 8),
                  _PhotoAction(
                    icon: Icons.delete_outline_rounded,
                    label: '삭제',
                    fontScale: fontScale,
                    onTap: () => onChanged(''),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoAction extends StatelessWidget {
  const _PhotoAction({
    required this.icon,
    required this.label,
    required this.fontScale,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
