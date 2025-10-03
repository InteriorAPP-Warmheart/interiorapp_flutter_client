import 'package:flutter/material.dart';
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
  });

  final List<SearchResultModel> items;
  final void Function(SearchResultModel item)? onTapItem;
  final SearchResultLayout layout;
  final int maxImagesToShow;
  final int gridCrossAxisCount;
  final double gridSpacing;
  final double gridHorizontalPadding;
  final double listTileHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    if (layout == SearchResultLayout.storeGrid) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 6,
          horizontal: gridHorizontalPadding,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          mainAxisSpacing: gridSpacing,
          crossAxisSpacing: gridSpacing,
          childAspectRatio: 0.68,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _StoreGridTile(item: item, onTap: onTapItem);
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
  });

  final SearchResultModel item;
  final void Function(SearchResultModel item)? onTap;
  final SearchResultLayout layout;
  final int maxImagesToShow;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      color: Colors.grey.shade200,
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
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child:
                          displayedImageCount > 0
                              ? Image.network(
                                item.imageUrls!.first,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                              : Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title!,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.contentSnippet!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage:
                                  item.publisherAvatarUrl == null
                                      ? null
                                      : NetworkImage(item.publisherAvatarUrl!),
                              child:
                                  item.publisherAvatarUrl == null
                                      ? const Icon(Icons.person, size: 14)
                                      : null,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                item.publisherNickname!,
                                style: theme.textTheme.labelMedium,
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
              Text(
                item.title!,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                item.contentSnippet!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage:
                        item.publisherAvatarUrl == null
                            ? null
                            : NetworkImage(item.publisherAvatarUrl!),
                    child:
                        item.publisherAvatarUrl == null
                            ? const Icon(Icons.person, size: 14)
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.publisherNickname!,
                      style: theme.textTheme.labelMedium,
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

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.imageUrl, this.overlayText});

  final String imageUrl;
  final String? overlayText;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
            ),
            if (overlayText != null)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: Text(
                  overlayText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
  const _StoreGridTile({required this.item, this.onTap});

  final SearchResultModel item;
  final void Function(SearchResultModel item)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child:
                  item.imageUrls?.isNotEmpty ?? false
                      ? Image.network(
                        item.imageUrls!.first,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.publisherNickname!, // brand
            style: theme.textTheme.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.contentSnippet!, // description
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

