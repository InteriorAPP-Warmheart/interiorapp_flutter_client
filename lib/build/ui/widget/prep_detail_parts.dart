import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/industry_cover.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 비어 있는 값을 보여 줄 때 쓰는 말.
const String kDetailEmpty = '아직 없어요';

const List<String> _spacePhotos = [
  'assets/images/home/wapll_home_01.png',
  'assets/images/home/wapll_home_02.webp',
  'assets/images/home/wapll_home_03.webp',
];

/// 상담 준비와 입지의 표지 사진. 올린 사진이 먼저고, 없으면 업종 사진,
/// 그것도 없으면 같은 건은 늘 같은 공간 사진을 쓴다.
String prepCoverAsset(String industry, String key, {String photo = ''}) {
  if (photo.trim().isNotEmpty) return photo;
  return industryCoverAsset(industry) ??
      _spacePhotos[key.hashCode.abs() % _spacePhotos.length];
}

/// 상세 맨 위 사진. 이름과 주소를 사진 위에 얹는다.
class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
    required this.imageUrl,
    required this.eyebrow,
    required this.title,
    required this.address,
  });

  final String imageUrl;
  final String eyebrow;
  final String title;
  final String address;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final AppWindow window = AppWindow.of(context);
    final double height =
        window.isExpanded
            ? 272
            : window.isMedium
            ? 236
            : 208;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x330B1F38),
                    Color(0x000B1F38),
                    Color(0xE60B1F38),
                  ],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        eyebrow,
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26 * fontScale,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.white,
                    ),
                  ),
                  if (address.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 꼭 봐야 하는 값 두세 개를 나란히 둔다.
class DetailFacts extends StatelessWidget {
  const DetailFacts({super.key, required this.facts});

  final List<(String, String)> facts;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < facts.length; i++) ...[
              if (i > 0)
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facts[i].$1,
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        facts[i].$2.trim().isEmpty ? '-' : facts[i].$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17 * fontScale,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color:
                              facts[i].$2.trim().isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 제목은 카드 밖, 내용은 흰 카드 안.
class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.onEdit,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17 * fontScale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 36),
                    textStyle: TextStyle(
                      fontSize: 14 * fontScale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('수정'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 0.7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 0.7,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.border,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 이름과 값 한 줄. 이름은 왼쪽 고정 폭, 값은 길면 여러 줄로 내린다.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool empty = value.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104 * fontScale,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14 * fontScale,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              empty ? kDetailEmpty : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.4,
                fontWeight: empty ? FontWeight.w500 : FontWeight.w600,
                color: empty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 맨 위의 큰 숫자. 예산이나 월세처럼 먼저 읽혀야 하는 값.
class DetailHighlight extends StatelessWidget {
  const DetailHighlight({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool empty = value.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            empty ? kDetailEmpty : value,
            style: TextStyle(
              fontSize: (empty ? 17 : 24) * fontScale,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: empty ? AppColors.textSecondary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 사용자가 직접 쓴 긴 글. 따옴표 대신 왼쪽 선으로 구분한다.
class DetailNote extends StatelessWidget {
  const DetailNote({super.key, required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool empty = body.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  empty ? kDetailEmpty : body.trim(),
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                    color:
                        empty ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 여러 개를 고른 값. 이름 아래에 칩으로 늘어놓는다.
class DetailTags extends StatelessWidget {
  const DetailTags({super.key, required this.label, required this.tags});

  final String label;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final String tag in tags)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 카드 안에 한 줄로 두는 조용한 안내.
class DetailQuiet extends StatelessWidget {
  const DetailQuiet({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * fontScale,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
