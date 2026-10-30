import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';

/// 쇼룸 본문에 붙이는 이모티콘. 시스템 키보드가 아니라 글쓰기 도구에서만 고른다.
const List<String> showroomEmojiCatalog = <String>[
  '✨',
  '☕️',
  '🍽️',
  '🪴',
  '💡',
  '🪵',
  '🪟',
  '🪑',
  '🪞',
  '🏠',
  '🤍',
  '🌿',
  '⭐',
  '📐',
  '🛠️',
  '🕯️',
];

enum ShowroomBlockKind { text, images, process }

enum ShowroomImageLayout { photo, slider, gallery, beforeAfter }

/// 시공 전·후 한 쌍.
class ShowroomBeforeAfterPair {
  const ShowroomBeforeAfterPair({
    required this.id,
    this.beforeUrl = '',
    this.afterUrl = '',
    this.caption = '',
  });

  final String id;
  final String beforeUrl;
  final String afterUrl;
  final String caption;

  bool get hasImage => beforeUrl.isNotEmpty || afterUrl.isNotEmpty;

  ShowroomBeforeAfterPair copyWith({
    String? beforeUrl,
    String? afterUrl,
    String? caption,
  }) {
    return ShowroomBeforeAfterPair(
      id: id,
      beforeUrl: beforeUrl ?? this.beforeUrl,
      afterUrl: afterUrl ?? this.afterUrl,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'beforeUrl': beforeUrl,
      'afterUrl': afterUrl,
      'caption': caption,
    };
  }

  static ShowroomBeforeAfterPair? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final String? id = json['id'] as String?;
    if (id == null || id.isEmpty) return null;
    return ShowroomBeforeAfterPair(
      id: id,
      beforeUrl: json['beforeUrl'] as String? ?? '',
      afterUrl: json['afterUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
    );
  }
}

/// 글 사이에 넣은 사진 영역. [focusId]는 영역 뒤에서 이어서 쓸 글 칸이다.
class ShowroomAreaInsert {
  const ShowroomAreaInsert({required this.blocks, required this.focusId});

  final List<ShowroomBlock> blocks;
  final String focusId;
}

/// 커서가 있는 글 사이에 사진 위젯을 넣는다. 뒤쪽 글은 위젯 아래로 이어진다.
ShowroomAreaInsert insertShowroomArea({
  required List<ShowroomBlock> blocks,
  required String Function() nextId,
  String? blockId,
  String? paragraphId,
  int? caret,
  ShowroomImageLayout layout = ShowroomImageLayout.slider,
  String imageUrl = '',
  List<String> imageUrls = const <String>[],
}) {
  final List<String> urls = <String>[
    for (final String url in imageUrls)
      if (url.isNotEmpty) url,
    if (imageUrl.isNotEmpty) imageUrl,
  ];
  final ShowroomBlock image =
      layout == ShowroomImageLayout.beforeAfter
          ? ShowroomBlock.images(
            id: nextId(),
            layout: layout,
            pairs: <ShowroomBeforeAfterPair>[
              ShowroomBeforeAfterPair(id: nextId()),
            ],
          )
          : ShowroomBlock.images(id: nextId(), layout: layout, urls: urls);
  final List<ShowroomBlock> next = <ShowroomBlock>[...blocks];
  var index = -1;
  if (blockId != null) {
    index = next.indexWhere(
      (ShowroomBlock block) =>
          block.id == blockId && block.kind == ShowroomBlockKind.text,
    );
  }
  if (index < 0) {
    for (var cursor = next.length - 1; cursor >= 0; cursor--) {
      if (next[cursor].kind != ShowroomBlockKind.text) continue;
      index = cursor;
      break;
    }
  }
  if (index < 0) {
    final String leadingId = nextId();
    final String trailingId = nextId();
    return ShowroomAreaInsert(
      blocks: <ShowroomBlock>[
        ShowroomBlock.text(id: leadingId),
        image,
        ShowroomBlock.text(id: trailingId),
      ],
      focusId: trailingId,
    );
  }
  final ShowroomBlock block = next[index];
  final List<RichTextParagraph> paragraphs =
      block.paragraphs.isEmpty
          ? <RichTextParagraph>[RichTextParagraph(id: nextId())]
          : block.paragraphs;
  final String targetId =
      paragraphId != null &&
              paragraphs.any(
                (RichTextParagraph paragraph) => paragraph.id == paragraphId,
              )
          ? paragraphId
          : paragraphs.last.id;
  final int targetCaret =
      paragraphId == null
          ? paragraphs.last.text.length
          : caret ?? paragraphs.last.text.length;
  final ({List<RichTextParagraph> head, List<RichTextParagraph> tail}) cut =
      splitRichParagraphs(
        paragraphs: paragraphs,
        paragraphId: targetId,
        caret: targetCaret,
        nextId: nextId,
      );
  if (cut.head.isEmpty) {
    next.insert(index, image);
    return ShowroomAreaInsert(blocks: next, focusId: block.id);
  }
  final String tailId = nextId();
  next[index] = block.copyWith(paragraphs: cut.head);
  next.insert(index + 1, image);
  next.insert(index + 2, ShowroomBlock.text(id: tailId, paragraphs: cut.tail));
  return ShowroomAreaInsert(blocks: next, focusId: tailId);
}

/// 본문 한 칸. 글, 사진, 현장 기록이며, 배열에서의 위치가 화면 순서다.
class ShowroomBlock {
  const ShowroomBlock._({
    required this.id,
    required this.kind,
    this.paragraphs = const <RichTextParagraph>[],
    this.layout = ShowroomImageLayout.slider,
    this.urls = const <String>[],
    this.pairs = const <ShowroomBeforeAfterPair>[],
    this.frames = const <ShowroomProcessFrame>[],
  });

  factory ShowroomBlock.text({
    required String id,
    String text = '',
    String paragraphId = 'p0',
    RichTextAlign align = RichTextAlign.left,
    RichTextSize size = RichTextSize.medium,
    bool bold = false,
    List<RichTextParagraph>? paragraphs,
  }) {
    return ShowroomBlock._(
      id: id,
      kind: ShowroomBlockKind.text,
      paragraphs:
          paragraphs ??
          <RichTextParagraph>[
            RichTextParagraph(
              id: paragraphId,
              align: align,
              runs: <RichTextRun>[
                RichTextRun(text: text, size: size, bold: bold),
              ],
            ),
          ],
    );
  }

  factory ShowroomBlock.images({
    required String id,
    ShowroomImageLayout layout = ShowroomImageLayout.slider,
    List<String> urls = const <String>[],
    List<ShowroomBeforeAfterPair> pairs = const <ShowroomBeforeAfterPair>[],
  }) {
    return ShowroomBlock._(
      id: id,
      kind: ShowroomBlockKind.images,
      layout: layout,
      urls: urls,
      pairs: pairs,
    );
  }

  factory ShowroomBlock.process({
    required String id,
    List<ShowroomProcessFrame> frames = const <ShowroomProcessFrame>[],
  }) {
    return ShowroomBlock._(
      id: id,
      kind: ShowroomBlockKind.process,
      frames: frames,
    );
  }

  final String id;
  final ShowroomBlockKind kind;
  final List<RichTextParagraph> paragraphs;
  final ShowroomImageLayout layout;
  final List<String> urls;
  final List<ShowroomBeforeAfterPair> pairs;
  final List<ShowroomProcessFrame> frames;

  String get text => paragraphs
      .map((RichTextParagraph paragraph) => paragraph.text)
      .join('\n');

  bool get hasContent {
    if (kind == ShowroomBlockKind.text) return text.trim().isNotEmpty;
    if (kind == ShowroomBlockKind.process) {
      return frames.any(
        (ShowroomProcessFrame frame) =>
            frame.imageUrl.trim().isNotEmpty ||
            frame.trade.trim().isNotEmpty ||
            frame.caption.trim().isNotEmpty,
      );
    }
    if (urls.any((String url) => url.isNotEmpty)) return true;
    return pairs.any((ShowroomBeforeAfterPair pair) => pair.hasImage);
  }

  bool containsUrl(String url) {
    if (url.isEmpty) return false;
    if (urls.contains(url)) return true;
    if (pairs.any(
      (ShowroomBeforeAfterPair pair) =>
          pair.beforeUrl == url || pair.afterUrl == url,
    )) {
      return true;
    }
    return frames.any((ShowroomProcessFrame frame) => frame.imageUrl == url);
  }

  ShowroomBlock copyWith({
    List<RichTextParagraph>? paragraphs,
    ShowroomImageLayout? layout,
    List<String>? urls,
    List<ShowroomBeforeAfterPair>? pairs,
    List<ShowroomProcessFrame>? frames,
  }) {
    return ShowroomBlock._(
      id: id,
      kind: kind,
      paragraphs: paragraphs ?? this.paragraphs,
      layout: layout ?? this.layout,
      urls: urls ?? this.urls,
      pairs: pairs ?? this.pairs,
      frames: frames ?? this.frames,
    );
  }

  /// 배치를 바꿀 때 이미 올린 사진 순서는 유지한다.
  ShowroomBlock withLayout(ShowroomImageLayout next, String pairId) {
    if (kind != ShowroomBlockKind.images || next == layout) return this;
    if (next == ShowroomImageLayout.beforeAfter) {
      final List<String> flat =
          urls.where((String url) => url.isNotEmpty).toList();
      final List<ShowroomBeforeAfterPair> nextPairs =
          <ShowroomBeforeAfterPair>[];
      for (var index = 0; index < flat.length; index += 2) {
        nextPairs.add(
          ShowroomBeforeAfterPair(
            id: '$pairId-${nextPairs.length}',
            beforeUrl: flat[index],
            afterUrl: index + 1 < flat.length ? flat[index + 1] : '',
          ),
        );
      }
      if (nextPairs.isEmpty) {
        nextPairs.add(ShowroomBeforeAfterPair(id: pairId));
      }
      return copyWith(layout: next, urls: const <String>[], pairs: nextPairs);
    }
    final List<String> flat = <String>[
      for (final ShowroomBeforeAfterPair pair in pairs) ...<String>[
        if (pair.beforeUrl.isNotEmpty) pair.beforeUrl,
        if (pair.afterUrl.isNotEmpty) pair.afterUrl,
      ],
      ...urls.where((String url) => url.isNotEmpty),
    ];
    return copyWith(
      layout: next,
      urls: flat,
      pairs: const <ShowroomBeforeAfterPair>[],
    );
  }

  ShowroomBlock added(String url, String pairId) {
    if (layout != ShowroomImageLayout.beforeAfter) {
      return copyWith(urls: <String>[...urls, url]);
    }
    final int empty = pairs.indexWhere(
      (ShowroomBeforeAfterPair pair) =>
          pair.beforeUrl.isEmpty || pair.afterUrl.isEmpty,
    );
    if (empty < 0) {
      return copyWith(
        pairs: <ShowroomBeforeAfterPair>[
          ...pairs,
          ShowroomBeforeAfterPair(id: pairId, beforeUrl: url),
        ],
      );
    }
    final ShowroomBeforeAfterPair pair = pairs[empty];
    final ShowroomBeforeAfterPair filled =
        pair.beforeUrl.isEmpty
            ? pair.copyWith(beforeUrl: url)
            : pair.copyWith(afterUrl: url);
    return copyWith(
      pairs: <ShowroomBeforeAfterPair>[
        for (var index = 0; index < pairs.length; index++)
          if (index == empty) filled else pairs[index],
      ],
    );
  }

  Map<String, dynamic> toJson() {
    if (kind == ShowroomBlockKind.text) {
      return <String, dynamic>{
        'id': id,
        'type': 'text',
        'text': text,
        'paragraphs': <Map<String, dynamic>>[
          for (final RichTextParagraph paragraph in paragraphs)
            paragraph.toJson(),
        ],
      };
    }
    if (kind == ShowroomBlockKind.process) {
      return <String, dynamic>{
        'id': id,
        'type': 'process',
        'frames': <Map<String, String>>[
          for (final ShowroomProcessFrame frame in frames)
            <String, String>{
              'id': frame.id,
              'trade': frame.trade,
              'imageUrl': frame.imageUrl,
              'caption': frame.caption,
            },
        ],
      };
    }
    return <String, dynamic>{
      'id': id,
      'type': 'images',
      'layout': layout.name,
      'urls': urls,
      'pairs': <Map<String, dynamic>>[
        for (final ShowroomBeforeAfterPair pair in pairs) pair.toJson(),
      ],
    };
  }

  static ShowroomBlock? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final String? id = json['id'] as String?;
    if (id == null || id.isEmpty) return null;
    final String? type = json['type'] as String?;
    if (type == 'text') {
      final List<RichTextParagraph> paragraphs = <RichTextParagraph>[
        for (var index = 0; index < _list(json['paragraphs']).length; index++)
          if (RichTextParagraph.tryParse(
                _list(json['paragraphs'])[index],
                fallbackId: '$id-p$index',
              )
              case final paragraph?)
            paragraph,
      ];
      if (paragraphs.isNotEmpty) {
        return ShowroomBlock.text(id: id, paragraphs: paragraphs);
      }
      return ShowroomBlock.text(
        id: id,
        paragraphId: '$id-p0',
        text: json['text'] as String? ?? '',
        align:
            RichTextAlign.values.asNameMap()[json['align']] ??
            RichTextAlign.left,
        size:
            RichTextSize.values.asNameMap()[json['size']] ??
            RichTextSize.medium,
        bold: json['bold'] == true,
      );
    }
    if (type == 'process') {
      return ShowroomBlock.process(
        id: id,
        frames: <ShowroomProcessFrame>[
          for (final Object? item in _list(json['frames']))
            if (item is Map)
              ShowroomProcessFrame(
                id: item['id'] as String? ?? '',
                trade: item['trade'] as String? ?? '',
                imageUrl: item['imageUrl'] as String? ?? '',
                caption: item['caption'] as String? ?? '',
              ),
        ],
      );
    }
    if (type == 'images') {
      final List<ShowroomBeforeAfterPair> pairs = <ShowroomBeforeAfterPair>[
        for (final Object? item in _list(json['pairs']))
          if (ShowroomBeforeAfterPair.tryParse(item) case final pair?) pair,
      ];
      return ShowroomBlock.images(
        id: id,
        layout: _layout(json['layout']),
        urls: _strings(json['urls']),
        pairs: pairs,
      );
    }
    return null;
  }
}

/// 서버에 저장하는 본문. `blocks` 순서가 글의 순서다.
class ShowroomBodyDocument {
  const ShowroomBodyDocument(this.blocks);

  static const int version = 1;

  final List<ShowroomBlock> blocks;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'blocks': <Map<String, dynamic>>[
        for (final ShowroomBlock block in blocks) block.toJson(),
      ],
    };
  }

  factory ShowroomBodyDocument.fromJson(Map<String, dynamic> json) {
    return ShowroomBodyDocument(<ShowroomBlock>[
      for (final Object? item in _list(json['blocks']))
        if (ShowroomBlock.tryParse(item) case final block?) block,
    ]);
  }
}

ShowroomImageLayout _layout(Object? raw) {
  return ShowroomImageLayout.values.asNameMap()[raw] ??
      ShowroomImageLayout.slider;
}

List<String> _strings(Object? raw) {
  if (raw is! List) return const <String>[];
  return <String>[
    for (final Object? item in raw)
      if (item is String && item.isNotEmpty) item,
  ];
}

List<Object?> _list(Object? raw) {
  if (raw is List) return raw;
  return const <Object?>[];
}
