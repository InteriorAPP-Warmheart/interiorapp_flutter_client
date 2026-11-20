import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interiorapp_flutter_client/core/widget/app_asset_image.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';

/// 앱 이모티콘. 사진처럼 화면에 맞춰 키우거나 갤러리에서 확대하지 않는다.
bool showroomEmoticonUrl(String url) => url.contains('/app_icons/');

/// 사진 칸이 아니라 글 사이의 이모티콘 하나인지.
bool showroomSoloEmoticon(ShowroomBlock block) {
  if (block.kind != ShowroomBlockKind.images) return false;
  if (block.layout != ShowroomImageLayout.photo) return false;
  final List<String> urls = <String>[
    for (final String url in block.urls)
      if (url.trim().isNotEmpty) url.trim(),
  ];
  return urls.length == 1 && showroomEmoticonUrl(urls.single);
}

/// 본문에서 이모티콘을 그리는 고정 크기.
const double showroomEmoticonSize = 96;

/// [index] 앞에 있는 사진 수. 빈 주소와 이모티콘은 세지 않는다.
int showroomPhotoOffset(List<String> urls, int index) {
  var seen = 0;
  final int end = index < urls.length ? index : urls.length;
  for (var i = 0; i < end; i++) {
    final String url = urls[i].trim();
    if (url.isEmpty || showroomEmoticonUrl(url)) continue;
    seen++;
  }
  return seen;
}

/// 글에 나온 사진 주소. 전후는 전, 후 순서로 넣고, 이모티콘은 빼 둔다.
List<String> showroomReadingImageUrls(List<ShowroomBlock> blocks) {
  final List<String> urls = <String>[];
  for (final ShowroomBlock block in blocks) {
    if (!block.hasContent) continue;
    if (block.kind == ShowroomBlockKind.text) continue;
    if (block.kind == ShowroomBlockKind.process) {
      for (final ShowroomProcessFrame frame in block.frames) {
        final String url = frame.imageUrl.trim();
        if (url.isNotEmpty && !showroomEmoticonUrl(url)) urls.add(url);
      }
      continue;
    }
    if (block.layout == ShowroomImageLayout.beforeAfter) {
      for (final ShowroomBeforeAfterPair pair in block.pairs) {
        final String before = pair.beforeUrl.trim();
        final String after = pair.afterUrl.trim();
        if (before.isNotEmpty && !showroomEmoticonUrl(before)) urls.add(before);
        if (after.isNotEmpty && !showroomEmoticonUrl(after)) urls.add(after);
      }
      continue;
    }
    for (final String url in block.urls) {
      final String trimmed = url.trim();
      if (trimmed.isNotEmpty && !showroomEmoticonUrl(trimmed)) {
        urls.add(trimmed);
      }
    }
  }
  return urls;
}

/// 표지가 본문에 없으면 갤러리 맨 앞에 둔다.
List<String> showroomGalleryWithCover(List<String> body, String cover) {
  final String thumb = cover.trim();
  if (thumb.isEmpty || body.contains(thumb)) return body;
  return <String>[thumb, ...body];
}

/// 글을 가리고 사진만 보여 준다. 아래 레일에서 다른 장으로 건너뛴다.
void openShowroomPhotoGallery(
  BuildContext context, {
  required List<String> urls,
  required int initialIndex,
}) {
  if (urls.isEmpty) return;
  final int index = initialIndex.clamp(0, urls.length - 1);
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ShowroomPhotoGallery(urls: urls, initialIndex: index),
        );
      },
    ),
  );
}

class ShowroomPhotoGallery extends StatefulWidget {
  const ShowroomPhotoGallery({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<ShowroomPhotoGallery> createState() => _ShowroomPhotoGalleryState();
}

class _ShowroomPhotoGalleryState extends State<ShowroomPhotoGallery>
    with SingleTickerProviderStateMixin {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late int _page = widget.initialIndex;
  double _offset = 0;
  double _settleFrom = 0;
  bool _pulling = false;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() {
      if (!mounted || _pulling) return;
      setState(() => _offset = _settleFrom * (1 - _settle.value));
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _pullBy(double dy) {
    _settle.stop();
    setState(() {
      _pulling = true;
      _offset += dy;
    });
  }

  void _endPull(double velocity) {
    if (!_pulling) return;
    setState(() => _pulling = false);
    if (_offset.abs() > 110 || velocity.abs() > 900) {
      Navigator.of(context).pop();
      return;
    }
    _settleFrom = _offset;
    _settle.forward(from: 0);
  }

  void _goTo(int index) {
    if (index == _page || !_pages.hasClients) return;
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.urls.length;
    final double fade = (1 - _offset.abs() / 320).clamp(0.0, 1.0);
    final bool showRail = count > 1;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF12100E).withValues(alpha: fade),
              ),
            ),
            Transform.translate(
              offset: Offset(0, _offset),
              child: PageView.builder(
                controller: _pages,
                itemCount: count,
                physics:
                    _zoomed || _pulling
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() {
                    _page = index;
                    _zoomed = false;
                    _offset = 0;
                    _pulling = false;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return _GalleryPage(
                    url: widget.urls[index],
                    active: index == _page,
                    onZoomChanged: (bool zoomed) {
                      if (index != _page || zoomed == _zoomed) return;
                      setState(() => _zoomed = zoomed);
                    },
                    onPullUpdate: _pullBy,
                    onPullEnd: _endPull,
                  );
                },
              ),
            ),
            if (showRail)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: _zoomed,
                  child: AnimatedOpacity(
                    opacity: _zoomed ? 0 : fade,
                    duration: const Duration(milliseconds: 160),
                    child: _ThumbRail(
                      urls: widget.urls,
                      index: _page,
                      onSelect: _goTo,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x8012100E),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.close, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ThumbRail extends StatefulWidget {
  const _ThumbRail({
    required this.urls,
    required this.index,
    required this.onSelect,
  });

  final List<String> urls;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  State<_ThumbRail> createState() => _ThumbRailState();
}

class _ThumbRailState extends State<_ThumbRail> {
  final ScrollController _scroll = ScrollController();

  static const double _thumb = 56;
  static const double _gap = 8;
  static const double _inset = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _center(false));
  }

  @override
  void didUpdateWidget(covariant _ThumbRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _center(true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _center(bool animate) {
    if (!_scroll.hasClients) return;
    final double viewport = _scroll.position.viewportDimension;
    final double max = _scroll.position.maxScrollExtent;
    final double target = (_inset +
            widget.index * (_thumb + _gap) +
            _thumb / 2 -
            viewport / 2)
        .clamp(0, max);
    if (!animate) {
      _scroll.jumpTo(target);
      return;
    }
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.urls.length;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x0012100E), Color(0xF012100E)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _inset),
                child: Text(
                  '${widget.index + 1} / $count',
                  style: const TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: _thumb,
                child: ListView.separated(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: _inset),
                  itemCount: count,
                  separatorBuilder:
                      (BuildContext context, int index) =>
                          const SizedBox(width: _gap),
                  itemBuilder: (BuildContext context, int index) {
                    final bool selected = index == widget.index;
                    return GestureDetector(
                      onTap: () => widget.onSelect(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: _thumb,
                        height: _thumb,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Opacity(
                            opacity: selected ? 1 : 0.42,
                            child: AppNetworkImage(
                              url: widget.urls[index],
                              fit: BoxFit.cover,
                              placeholderColor: const Color(0xFF2A2622),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryPage extends StatefulWidget {
  const _GalleryPage({
    required this.url,
    required this.active,
    required this.onZoomChanged,
    required this.onPullUpdate,
    required this.onPullEnd,
  });

  final String url;
  final bool active;
  final ValueChanged<bool> onZoomChanged;
  final ValueChanged<double> onPullUpdate;
  final ValueChanged<double> onPullEnd;

  @override
  State<_GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<_GalleryPage> {
  final TransformationController _transform = TransformationController();
  bool _zoomed = false;
  bool _pulling = false;
  double _velocity = 0;
  DateTime _movedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  @override
  void didUpdateWidget(covariant _GalleryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      widget.onZoomChanged(_zoomed);
    }
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    super.dispose();
  }

  void _onTransform() {
    final bool zoomed = _transform.value.getMaxScaleOnAxis() > 1.02;
    if (zoomed == _zoomed) return;
    setState(() => _zoomed = zoomed);
    if (widget.active) widget.onZoomChanged(zoomed);
  }

  void _zoomAt(Offset focal, Size size) {
    if (_zoomed) {
      _transform.value = Matrix4.identity();
      return;
    }
    const double scale = 2.5;
    _transform.value =
        Matrix4.identity()
          ..translateByDouble(focal.dx, focal.dy, 0, 1)
          ..scaleByDouble(scale, scale, 1, 1)
          ..translateByDouble(-focal.dx, -focal.dy, 0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        if (showroomEmoticonUrl(widget.url)) {
          return Center(
            child: AppAssetImage(
              widget.url,
              width: showroomEmoticonSize,
              height: showroomEmoticonSize,
              fit: BoxFit.contain,
            ),
          );
        }
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (PointerDownEvent event) {
            _pulling = false;
            _velocity = 0;
          },
          onPointerMove: (PointerMoveEvent event) {
            if (!widget.active || _zoomed) return;
            if (!_pulling) {
              if (event.delta.dy.abs() < 8) return;
              if (event.delta.dy.abs() < event.delta.dx.abs()) return;
              _pulling = true;
            }
            final DateTime now = DateTime.now();
            final int elapsed = now.difference(_movedAt).inMilliseconds;
            if (elapsed > 0) {
              _velocity = event.delta.dy / elapsed * 1000;
            }
            _movedAt = now;
            widget.onPullUpdate(event.delta.dy);
          },
          onPointerUp: (PointerUpEvent event) {
            if (!_pulling) return;
            _pulling = false;
            widget.onPullEnd(_velocity);
          },
          onPointerCancel: (PointerCancelEvent event) {
            if (!_pulling) return;
            _pulling = false;
            widget.onPullEnd(0);
          },
          child: GestureDetector(
            onDoubleTapDown: (TapDownDetails details) {
              _zoomAt(details.localPosition, size);
            },
            child: InteractiveViewer(
              transformationController: _transform,
              panEnabled: _zoomed,
              minScale: 1,
              maxScale: 4,
              child: SizedBox.fromSize(
                size: size,
                child: AppNetworkImage(
                  url: widget.url,
                  fit: BoxFit.contain,
                  placeholderColor: const Color(0xFF12100E),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
