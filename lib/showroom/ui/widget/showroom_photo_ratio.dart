import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 사진 원본의 가로/세로로 칸을 잡는다. 읽기 전에는 [fallback]을 쓴다.
class ShowroomPhotoRatio extends StatefulWidget {
  const ShowroomPhotoRatio({
    super.key,
    required this.url,
    required this.builder,
    this.fallback = 3 / 2,
  });

  final String url;
  final double fallback;
  final Widget Function(BuildContext context, double aspectRatio) builder;

  @override
  State<ShowroomPhotoRatio> createState() => _ShowroomPhotoRatioState();
}

class _ShowroomPhotoRatioState extends State<ShowroomPhotoRatio> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  late double _ratio = widget.fallback;

  @override
  void initState() {
    super.initState();
    _listen(widget.url);
  }

  @override
  void didUpdateWidget(covariant ShowroomPhotoRatio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) return;
    _stop();
    _ratio = widget.fallback;
    _listen(widget.url);
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _listen(String url) {
    if (url.isEmpty) return;
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        final int width = info.image.width;
        final int height = info.image.height;
        if (width <= 0 || height <= 0) return;
        final double next = width / height;
        if ((_ratio - next).abs() < 0.01) return;
        if (synchronousCall || !mounted) {
          _ratio = next;
          return;
        }
        setState(() => _ratio = next);
      },
      onError: (Object exception, StackTrace? stackTrace) {},
    );
    final ImageStream stream = _provider(
      url,
    ).resolve(const ImageConfiguration());
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _stop() {
    final ImageStreamListener? listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _ratio);
  }
}

ImageProvider<Object> _provider(String url) {
  if (url.startsWith('assets/')) return AssetImage(url);
  if (url.startsWith('/') || url.startsWith('file://')) {
    final String path =
        url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    return FileImage(File(path));
  }
  return CachedNetworkImageProvider(url);
}
