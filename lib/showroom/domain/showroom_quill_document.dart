import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';

/// 본문 사진 영역을 Quill 블록 임베드로 넣을 때 쓰는 타입.
const String kShowroomEmbedType = 'showroom';

Document documentFromShowroomBlocks(List<ShowroomBlock> blocks) {
  final Delta delta = Delta();
  var wrote = false;
  for (final ShowroomBlock block in blocks) {
    if (block.kind == ShowroomBlockKind.text) {
      final List<RichTextParagraph> paragraphs =
          block.paragraphs.isEmpty
              ? const <RichTextParagraph>[RichTextParagraph(id: 'p')]
              : block.paragraphs;
      for (final RichTextParagraph paragraph in paragraphs) {
        for (final RichTextRun run in paragraph.runs) {
          if (run.text.isEmpty) continue;
          delta.insert(run.text, _runAttributes(run));
        }
        delta.insert('\n', _lineAttributes(paragraph));
        wrote = true;
      }
      continue;
    }
    delta.insert(_embedData(block));
    delta.insert('\n');
    wrote = true;
  }
  if (!wrote) delta.insert('\n');
  return Document.fromDelta(delta);
}

List<ShowroomBlock> blocksFromQuillDocument(Document document) {
  final List<ShowroomBlock> blocks = <ShowroomBlock>[];
  final List<RichTextParagraph> paragraphs = <RichTextParagraph>[];
  _LineBuffer line = _LineBuffer();
  var skipEmbedBreak = false;
  var sequence = 0;
  String nextId(String prefix) => '$prefix-${sequence++}';

  void flushLine() {
    paragraphs.add(
      RichTextParagraph(
        id: nextId('p'),
        align: line.align,
        runs:
            line.runs.isEmpty
                ? const <RichTextRun>[RichTextRun(text: '')]
                : List<RichTextRun>.of(line.runs),
      ),
    );
    line = _LineBuffer();
  }

  void flushText() {
    if (line.runs.isNotEmpty) flushLine();
    if (paragraphs.isEmpty) return;
    blocks.add(
      ShowroomBlock.text(
        id: nextId('text'),
        paragraphs: List<RichTextParagraph>.of(paragraphs),
      ),
    );
    paragraphs.clear();
  }

  void takeText(String text, Map<String, dynamic>? attributes) {
    var rest = text;
    while (rest.isNotEmpty) {
      if (skipEmbedBreak && rest.startsWith('\n')) {
        skipEmbedBreak = false;
        rest = rest.substring(1);
        continue;
      }
      final int newline = rest.indexOf('\n');
      if (newline < 0) {
        line.add(rest, attributes);
        return;
      }
      line.add(rest.substring(0, newline), attributes);
      line.align = _alignOf(attributes);
      flushLine();
      rest = rest.substring(newline + 1);
    }
  }

  for (final Operation operation in document.toDelta().toList()) {
    if (!operation.isInsert) continue;
    final Object? data = operation.data;
    if (data is String) {
      takeText(data, _attributeMap(operation));
      continue;
    }
    final ShowroomBlock? image = data is Map ? _blockFromEmbed(data) : null;
    if (image == null) continue;
    flushText();
    blocks.add(image);
    skipEmbedBreak = true;
  }
  flushText();
  if (blocks.isEmpty) {
    blocks.add(
      ShowroomBlock.text(id: nextId('text'), paragraphId: nextId('p')),
    );
  }
  return blocks;
}

/// Quill 제목(header)은 첫 줄을 본문보다 크게 그린다. 크기 버튼과 따로라서 뺀다.
bool stripShowroomHeadings(QuillController controller) {
  final List<int> newlines = <int>[];
  var offset = 0;
  for (final Operation operation in controller.document.toDelta().toList()) {
    final Object? data = operation.data;
    if (operation.isInsert &&
        data is String &&
        operation.attributes?['header'] != null) {
      var from = 0;
      while (true) {
        final int newline = data.indexOf('\n', from);
        if (newline < 0) break;
        newlines.add(offset + newline);
        from = newline + 1;
      }
    }
    offset += data is String ? data.length : 1;
  }
  if (newlines.isEmpty) return false;
  for (final int index in newlines) {
    controller.formatText(
      index,
      1,
      Attribute.clone(Attribute.header, null),
    );
  }
  return true;
}

bool sameShowroomBody(List<ShowroomBlock> left, List<ShowroomBlock> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (!_sameBlock(left[index], right[index])) return false;
  }
  return true;
}

ShowroomBlock? showroomBlockFromEmbed(Embeddable embed) {
  if (embed.type != kShowroomEmbedType) return null;
  final Object? data = embed.data;
  if (data is! String) return null;
  try {
    final Object? decoded = jsonDecode(data);
    if (decoded is! Map) return null;
    return ShowroomBlock.tryParse(decoded);
  } on FormatException {
    return null;
  }
}

void insertShowroomBlock(
  QuillController controller,
  ShowroomBlock block, {
  int? index,
}) {
  final String plain = controller.document.toPlainText();
  final int max = plain.length;
  final int at = (index ?? controller.selection.extentOffset).clamp(0, max);
  final bool lineStart = at == 0 || plain[at - 1] == '\n';
  final bool lineEnd = at >= max || plain[at] == '\n';
  final bool closingLastLine = lineEnd && at >= max - 1;
  final Delta delta = Delta();
  if (!lineStart) delta.insert('\n');
  delta.insert(_embedData(block));
  if (!lineEnd || closingLastLine) delta.insert('\n');
  controller.replaceText(at, 0, delta, TextSelection.collapsed(offset: at));
  final int embedAt = at + (lineStart ? 0 : 1);
  final int caret = (embedAt + 2).clamp(0, controller.document.length);
  controller.updateSelection(
    TextSelection.collapsed(offset: caret),
    ChangeSource.local,
  );
}

void replaceShowroomEmbed(
  QuillController controller,
  int offset,
  ShowroomBlock block,
) {
  controller.replaceText(
    offset,
    1,
    BlockEmbed(kShowroomEmbedType, jsonEncode(block.toJson())),
    TextSelection.collapsed(offset: offset + 1),
    ignoreFocus: true,
  );
}

void deleteShowroomEmbed(QuillController controller, int offset) {
  final int length = controller.document.length;
  final int safe = offset.clamp(0, length);
  controller.replaceText(
    safe,
    1,
    '',
    TextSelection.collapsed(offset: safe.clamp(0, length - 1)),
    ignoreFocus: true,
  );
}

Map<String, dynamic> _embedData(ShowroomBlock block) {
  return BlockEmbed(kShowroomEmbedType, jsonEncode(block.toJson())).toJson();
}

Map<String, dynamic>? _runAttributes(RichTextRun run) {
  final Map<String, dynamic> attributes = <String, dynamic>{};
  if (run.bold) attributes['bold'] = true;
  switch (run.size) {
    case RichTextSize.small:
      attributes['size'] = 'small';
    case RichTextSize.large:
      attributes['size'] = 'large';
    case RichTextSize.medium:
      break;
  }
  if (attributes.isEmpty) return null;
  return attributes;
}

Map<String, dynamic>? _lineAttributes(RichTextParagraph paragraph) {
  if (paragraph.align == RichTextAlign.left) return null;
  return <String, dynamic>{'align': paragraph.align.name};
}

Map<String, dynamic>? _attributeMap(Operation operation) {
  final Map<String, dynamic>? attributes = operation.attributes;
  if (attributes == null || attributes.isEmpty) return null;
  return attributes;
}

RichTextAlign _alignOf(Map<String, dynamic>? attributes) {
  return switch (attributes?['align']) {
    'center' => RichTextAlign.center,
    'right' => RichTextAlign.right,
    _ => RichTextAlign.left,
  };
}

RichTextSize _sizeOf(Object? raw) {
  return switch (raw) {
    'small' => RichTextSize.small,
    'large' || 'huge' => RichTextSize.large,
    _ => RichTextSize.medium,
  };
}

ShowroomBlock? _blockFromEmbed(Map<dynamic, dynamic> data) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(data);
  final Object? payload = json[kShowroomEmbedType];
  if (payload is! String) return null;
  try {
    final Object? decoded = jsonDecode(payload);
    if (decoded is! Map) return null;
    return ShowroomBlock.tryParse(decoded);
  } on FormatException {
    return null;
  }
}

bool _sameBlock(ShowroomBlock left, ShowroomBlock right) {
  if (left.kind != right.kind) return false;
  if (left.kind == ShowroomBlockKind.images) {
    if (left.id != right.id || left.layout != right.layout) return false;
    if (left.urls.length != right.urls.length) return false;
    for (var index = 0; index < left.urls.length; index++) {
      if (left.urls[index] != right.urls[index]) return false;
    }
    if (left.pairs.length != right.pairs.length) return false;
    for (var index = 0; index < left.pairs.length; index++) {
      final ShowroomBeforeAfterPair a = left.pairs[index];
      final ShowroomBeforeAfterPair b = right.pairs[index];
      if (a.id != b.id ||
          a.beforeUrl != b.beforeUrl ||
          a.afterUrl != b.afterUrl ||
          a.caption != b.caption) {
        return false;
      }
    }
    return true;
  }
  if (left.kind == ShowroomBlockKind.process) {
    if (left.id != right.id || left.frames.length != right.frames.length) {
      return false;
    }
    for (var index = 0; index < left.frames.length; index++) {
      final ShowroomProcessFrame a = left.frames[index];
      final ShowroomProcessFrame b = right.frames[index];
      if (a.id != b.id ||
          a.trade != b.trade ||
          a.imageUrl != b.imageUrl ||
          a.caption != b.caption) {
        return false;
      }
    }
    return true;
  }
  if (left.paragraphs.length != right.paragraphs.length) return false;
  for (var index = 0; index < left.paragraphs.length; index++) {
    final RichTextParagraph a = left.paragraphs[index];
    final RichTextParagraph b = right.paragraphs[index];
    if (a.align != b.align || a.runs.length != b.runs.length) return false;
    for (var run = 0; run < a.runs.length; run++) {
      if (a.runs[run].text != b.runs[run].text ||
          a.runs[run].size != b.runs[run].size ||
          a.runs[run].bold != b.runs[run].bold) {
        return false;
      }
    }
  }
  return true;
}

class _LineBuffer {
  final List<RichTextRun> runs = <RichTextRun>[];
  RichTextAlign align = RichTextAlign.left;

  void add(String text, Map<String, dynamic>? attributes) {
    if (text.isEmpty) return;
    final RichTextRun run = RichTextRun(
      text: text,
      size: _sizeOf(attributes?['size']),
      bold: attributes?['bold'] == true,
    );
    if (runs.isNotEmpty && runs.last.sameStyle(run)) {
      final RichTextRun last = runs.last;
      runs[runs.length - 1] = last.copyWith(text: last.text + run.text);
      return;
    }
    runs.add(run);
  }
}
