import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';

enum SearchResultLayout { gallery, singleThumbnail, storeGrid }

class SearchResultSection extends StatelessWidget {
  const SearchResultSection({
    super.key,
    required this.items,
    this.onTapItem,
    this.layout = SearchResultLayout.gallery,
    this.maxImagesToShow = 3,
    this.gridCrossAxisCount = 2,
    this.gridSpacing = 12,
    this.gridHorizontalPadding = 16,
    this.listTileHorizontalPadding = 16,
    this.searchQuery,
  });

  final List<SearchResultModel> items;
  final void Function(SearchResultModel item)? onTapItem;
  final SearchResultLayout layout;
  final int maxImagesToShow;
  final int gridCrossAxisCount;
  final double gridSpacing;
  final double gridHorizontalPadding;
  final double listTileHorizontalPadding;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    if (layout == SearchResultLayout.storeGrid) {
      return GridView.builder(
        padding: EdgeInsets.only(
          top: 6,
          bottom: 0,
          left: gridHorizontalPadding,
          right: gridHorizontalPadding,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          mainAxisSpacing: gridSpacing,
          crossAxisSpacing: gridSpacing,
          mainAxisExtent: ResponsiveSize.cardHeight(
            context,
            columns: gridCrossAxisCount,
            horizontalGap: gridSpacing,
            horizontalPadding: gridHorizontalPadding,
            aspectRatio: 3 / 4,
          ),
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _StoreGridTile(
            item: item,
            onTap: onTapItem,
            searchQuery: searchQuery,
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SearchResultListTile(
          item: item,
          onTap: onTapItem,
          layout: layout,
          maxImagesToShow: maxImagesToShow,
          horizontalPadding: listTileHorizontalPadding,
          searchQuery: searchQuery,
        );
      },
    );
  }
}

class _SearchResultListTile extends StatelessWidget {
  const _SearchResultListTile({
    required this.item,
    this.onTap,
    required this.layout,
    required this.maxImagesToShow,
    required this.horizontalPadding,
    this.searchQuery,
  });

  final SearchResultModel item;
  final void Function(SearchResultModel item)? onTap;
  final SearchResultLayout layout;
  final int maxImagesToShow;
  final double horizontalPadding;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final TextStyle titleStyle = TextStyle(
      fontSize: 15 * fontScale,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
    final TextStyle bodyStyle = TextStyle(
      fontSize: 13 * fontScale,
      color: AppColors.textSecondary,
    );
    final TextStyle nameStyle = TextStyle(
      fontSize: 12 * fontScale,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );
    final double thumbSize = ResponsiveSize.squareThumbSize(
      context,
      columns: 4,
      horizontalPadding: horizontalPadding,
      min: 64,
      max: 96,
    );
    final int displayedImageCount =
        item.imageUrls?.isEmpty ?? true
            ? 0
            : item.imageUrls!.length.clamp(0, maxImagesToShow);
    final remainingCount = item.imageUrls!.length - displayedImageCount;

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(item),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (layout == SearchResultLayout.gallery) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  // 3 columns with two gaps of 6px each
                  final double gap = 6;
                  final double totalGaps = gap * 2;
                  final double itemWidth =
                      (constraints.maxWidth - totalGaps) / 3;
                  return Row(
                    children: List.generate(3, (i) {
                      final hasImage = i < item.imageUrls!.length;
                      final isLastTile = i == 2; // last visible tile
                      final overlayText =
                          isLastTile && remainingCount > 0
                              ? '+$remainingCount'
                              : null;
                      return Padding(
                        padding: EdgeInsets.only(right: i < 2 ? gap : 0),
                        child: SizedBox(
                          width: itemWidth,
                          height: itemWidth,
                          child:
                              hasImage
                                  ? _ImageTile(
                                    imageUrl: item.imageUrls![i],
                                    overlayText: overlayText,
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: const ColoredBox(
                                      color: AppColors.imagePlaceholder,
                                    ),
                                  ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: thumbSize,
                      height: thumbSize,
                      child:
                          displayedImageCount > 0
                              ? AppNetworkImage(url: item.imageUrls!.first)
                              : Container(
                                color: AppColors.imagePlaceholder,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HighlightText(
                          text: item.title!,
                          searchQuery: searchQuery,
                          style: titleStyle,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        _HighlightText(
                          text: item.contentSnippet!,
                          searchQuery: searchQuery,
                          style: bodyStyle,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _PublisherAvatar(url: item.publisherAvatarUrl),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                item.publisherNickname!,
                                style: nameStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (layout == SearchResultLayout.gallery) ...[
              const SizedBox(height: 6),
              _HighlightText(
                text: item.title!,
                searchQuery: searchQuery,
                style: titleStyle,
                maxLines: 1,
              ),
              const SizedBox(height: 3),
              _HighlightText(
                text: item.contentSnippet!,
                searchQuery: searchQuery,
                style: bodyStyle,
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _PublisherAvatar(url: item.publisherAvatarUrl),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.publisherNickname!,
                      style: nameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PublisherAvatar extends StatelessWidget {
  const _PublisherAvatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      backgroundImage: url == null ? null : NetworkImage(url!),
      child: url == null
          ? const Icon(Icons.person, size: 14, color: AppColors.primary)
          : null,
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.imageUrl, this.overlayText});

  final String imageUrl;
  final String? overlayText;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: imageUrl),
            if (overlayText != null)
              Container(
                color: const Color(0xE60B1F38),
                alignment: Alignment.center,
                child: Text(
                  overlayText!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StoreGridTile extends StatelessWidget {
  const _StoreGridTile({
    required this.item,
    this.onTap,
    this.searchQuery,
  });

  final SearchResultModel item;
  final void Function(SearchResultModel item)? onTap;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child:
                  item.imageUrls?.isNotEmpty ?? false
                      ? AppNetworkImage(url: item.imageUrls!.first)
                      : Container(
                        color: AppColors.imagePlaceholder,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.publisherNickname!,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          _HighlightText(
            text: item.contentSnippet!,
            searchQuery: searchQuery,
            style: TextStyle(
              fontSize: 12 * fontScale,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// 검색어를 하이라이트하는 텍스트 위젯
class _HighlightText extends StatelessWidget {
  const _HighlightText({
    required this.text,
    this.searchQuery,
    this.style,
    this.maxLines,
  });

  final String text;
  final String? searchQuery;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    // 검색어가 없거나 비어있으면 일반 Text 반환
    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final query = searchQuery!.toLowerCase().trim();
    final lowerText = text.toLowerCase();
    
    // 검색어를 단어 단위로 분리
    final queryWords = query.split(' ').where((word) => word.isNotEmpty).toList();
    
    // 검색어가 포함되지 않으면 일반 Text 반환
    bool hasMatch = false;
    for (final word in queryWords) {
      if (lowerText.contains(word)) {
        hasMatch = true;
        break;
      }
    }
    
    if (!hasMatch) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 하이라이트 스타일
    final highlightStyle = style?.copyWith(
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ) ?? const TextStyle(
      backgroundColor: Color(0x1F0B1F38),
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );

    // TextSpan 리스트 생성
    final spans = <TextSpan>[];
    String remainingText = text;
    int currentIndex = 0;

    while (currentIndex < remainingText.length) {
      int? earliestMatchIndex;
      String? matchedWord;

      // 가장 앞에 있는 검색어 찾기
      for (final word in queryWords) {
        final lowerRemaining = remainingText.substring(currentIndex).toLowerCase();
        final wordIndex = lowerRemaining.indexOf(word);
        if (wordIndex != -1) {
          final absoluteIndex = currentIndex + wordIndex;
          if (earliestMatchIndex == null || absoluteIndex < earliestMatchIndex) {
            earliestMatchIndex = absoluteIndex;
            matchedWord = remainingText.substring(
              absoluteIndex,
              absoluteIndex + word.length,
            );
          }
        }
      }

      if (earliestMatchIndex == null) {
        // 더 이상 매칭되는 검색어가 없으면 나머지 텍스트 추가
        if (currentIndex < remainingText.length) {
          spans.add(TextSpan(
            text: remainingText.substring(currentIndex),
            style: style,
          ));
        }
        break;
      }

      // 매칭 전 텍스트 추가
      if (earliestMatchIndex > currentIndex) {
        spans.add(TextSpan(
          text: remainingText.substring(currentIndex, earliestMatchIndex),
          style: style,
        ));
      }

      // 하이라이트된 검색어 추가
      spans.add(TextSpan(
        text: matchedWord,
        style: highlightStyle,
      ));

      currentIndex = earliestMatchIndex + matchedWord!.length;
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

