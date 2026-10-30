/// 글 에디터 문서. 화면과 분리된 문단, 글자 스타일, 편집 규칙이다.
enum RichTextAlign { left, center, right }

enum RichTextSize { small, medium, large }

/// 한 문단 안의 글자 스타일. 크기와 굵기는 구간마다 따로 둔다.
class RichTextRun {
  const RichTextRun({
    required this.text,
    this.size = RichTextSize.medium,
    this.bold = false,
  });

  final String text;
  final RichTextSize size;
  final bool bold;

  bool sameStyle(RichTextRun other) => size == other.size && bold == other.bold;

  RichTextRun copyWith({String? text, RichTextSize? size, bool? bold}) {
    return RichTextRun(
      text: text ?? this.text,
      size: size ?? this.size,
      bold: bold ?? this.bold,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'size': size.name, 'bold': bold};
  }

  static RichTextRun? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    return RichTextRun(
      text: json['text'] as String? ?? '',
      size: _size(json['size']),
      bold: json['bold'] == true,
    );
  }
}

/// 정렬은 문단 단위다. 줄바꿈마다 문단이 나뉜다.
class RichTextParagraph {
  const RichTextParagraph({
    required this.id,
    this.align = RichTextAlign.left,
    this.runs = const <RichTextRun>[RichTextRun(text: '')],
  });

  final String id;
  final RichTextAlign align;
  final List<RichTextRun> runs;

  String get text => runs.map((RichTextRun run) => run.text).join();

  RichTextParagraph copyWith({RichTextAlign? align, List<RichTextRun>? runs}) {
    return RichTextParagraph(
      id: id,
      align: align ?? this.align,
      runs: runs ?? this.runs,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'align': align.name,
      'runs': <Map<String, dynamic>>[
        for (final RichTextRun run in runs) run.toJson(),
      ],
    };
  }

  static RichTextParagraph? tryParse(
    Object? raw, {
    required String fallbackId,
  }) {
    if (raw is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final String id =
        (json['id'] as String?)?.trim().isNotEmpty == true
            ? json['id'] as String
            : fallbackId;
    final List<RichTextRun> runs = <RichTextRun>[
      for (final Object? item in _list(json['runs']))
        if (RichTextRun.tryParse(item) case final run?) run,
    ];
    return RichTextParagraph(
      id: id,
      align: _align(json['align']),
      runs: runs.isEmpty ? const <RichTextRun>[RichTextRun(text: '')] : runs,
    );
  }
}

class RichTextAlignEdit {
  const RichTextAlignEdit({
    required this.paragraphs,
    required this.focusId,
    required this.caret,
  });

  final List<RichTextParagraph> paragraphs;
  final String focusId;
  final int caret;
}

bool sameRichParagraphs(
  List<RichTextParagraph> left,
  List<RichTextParagraph> right,
) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    final RichTextParagraph a = left[index];
    final RichTextParagraph b = right[index];
    if (a.id != b.id || a.align != b.align || a.runs.length != b.runs.length) {
      return false;
    }
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

RichTextAlign _align(Object? raw) {
  return RichTextAlign.values.asNameMap()[raw] ?? RichTextAlign.left;
}

RichTextSize _size(Object? raw) {
  return RichTextSize.values.asNameMap()[raw] ?? RichTextSize.medium;
}

List<Object?> _list(Object? raw) {
  if (raw is List) return raw;
  return const <Object?>[];
}

class _Mark {
  const _Mark(this.unit, this.size, this.bold);

  final String unit;
  final RichTextSize size;
  final bool bold;
}

List<_Mark> _explode(RichTextParagraph paragraph) {
  final List<_Mark> marks = <_Mark>[];
  for (final RichTextRun run in paragraph.runs) {
    for (var index = 0; index < run.text.length; index++) {
      marks.add(
        _Mark(run.text.substring(index, index + 1), run.size, run.bold),
      );
    }
  }
  return marks;
}

List<RichTextRun> _coalesce(
  List<_Mark> marks, {
  RichTextSize emptySize = RichTextSize.medium,
  bool emptyBold = false,
}) {
  final List<RichTextRun> runs = <RichTextRun>[];
  for (final _Mark mark in marks) {
    final RichTextRun run = RichTextRun(
      text: mark.unit,
      size: mark.size,
      bold: mark.bold,
    );
    if (runs.isNotEmpty && runs.last.sameStyle(run)) {
      runs[runs.length - 1] = runs.last.copyWith(
        text: runs.last.text + mark.unit,
      );
    } else {
      runs.add(run);
    }
  }
  if (runs.isEmpty) {
    return <RichTextRun>[
      RichTextRun(text: '', size: emptySize, bold: emptyBold),
    ];
  }
  return runs;
}

_Mark _styleAt(RichTextParagraph paragraph, int offset) {
  final List<_Mark> marks = _explode(paragraph);
  if (marks.isEmpty) {
    final RichTextRun run =
        paragraph.runs.isEmpty
            ? const RichTextRun(text: '')
            : paragraph.runs.first;
    return _Mark('', run.size, run.bold);
  }
  final int index = offset <= 0 ? 0 : (offset - 1).clamp(0, marks.length - 1);
  return marks[index];
}

/// 입력으로 바뀐 평문만 반영한다. 새로 들어간 글자만 [typingSize], [typingBold]를 받는다.
List<RichTextParagraph> applyTextEdit({
  required RichTextParagraph paragraph,
  required String before,
  required String after,
  required RichTextSize typingSize,
  required bool typingBold,
  required String Function() nextId,
}) {
  final List<_Mark> marks =
      paragraph.text == before
          ? _explode(paragraph)
          : <_Mark>[
            for (var index = 0; index < before.length; index++)
              _Mark(before.substring(index, index + 1), typingSize, typingBold),
          ];
  var prefix = 0;
  final int maxPrefix =
      before.length < after.length ? before.length : after.length;
  while (prefix < maxPrefix &&
      before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
    prefix++;
  }
  var suffix = 0;
  while (suffix < before.length - prefix &&
      suffix < after.length - prefix &&
      before.codeUnitAt(before.length - 1 - suffix) ==
          after.codeUnitAt(after.length - 1 - suffix)) {
    suffix++;
  }
  final int deleteUntil = before.length - suffix;
  final String inserted = after.substring(prefix, after.length - suffix);
  final List<List<_Mark>> groups = <List<_Mark>>[<_Mark>[]];
  final List<String> ids = <String>[paragraph.id];
  final List<RichTextAlign> aligns = <RichTextAlign>[paragraph.align];

  void push(String unit, RichTextSize size, bool bold) {
    if (unit == '\n') {
      groups.add(<_Mark>[]);
      ids.add(nextId());
      aligns.add(paragraph.align);
      return;
    }
    groups.last.add(_Mark(unit, size, bold));
  }

  for (final _Mark mark in marks.take(prefix)) {
    push(mark.unit, mark.size, mark.bold);
  }
  for (var index = 0; index < inserted.length; index++) {
    push(inserted.substring(index, index + 1), typingSize, typingBold);
  }
  for (final _Mark mark in marks.skip(deleteUntil)) {
    push(mark.unit, mark.size, mark.bold);
  }

  return <RichTextParagraph>[
    for (var index = 0; index < groups.length; index++)
      RichTextParagraph(
        id: ids[index],
        align: aligns[index],
        runs: _coalesce(
          groups[index],
          emptySize: typingSize,
          emptyBold: typingBold,
        ),
      ),
  ];
}

/// 여러 문단을 한 글 칸의 줄바꿈으로 편집한다. 화면의 글은 그대로 두고 문단만 맞춘다.
List<RichTextParagraph> applyDocumentEdit({
  required List<RichTextParagraph> paragraphs,
  required String before,
  required String after,
  required RichTextSize typingSize,
  required bool typingBold,
  required String Function() nextId,
}) {
  final List<RichTextParagraph> source =
      paragraphs.isEmpty
          ? <RichTextParagraph>[RichTextParagraph(id: nextId())]
          : paragraphs;
  final String joined = plainTextOf(source);
  final List<_Mark> marks =
      joined == before
          ? _explodeJoined(source)
          : <_Mark>[
            for (var index = 0; index < before.length; index++)
              _Mark(before.substring(index, index + 1), typingSize, typingBold),
          ];
  var prefix = 0;
  final int maxPrefix =
      before.length < after.length ? before.length : after.length;
  while (prefix < maxPrefix &&
      before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
    prefix++;
  }
  var suffix = 0;
  while (suffix < before.length - prefix &&
      suffix < after.length - prefix &&
      before.codeUnitAt(before.length - 1 - suffix) ==
          after.codeUnitAt(after.length - 1 - suffix)) {
    suffix++;
  }
  final int deleteUntil = before.length - suffix;
  final String inserted = after.substring(prefix, after.length - suffix);
  final List<List<_Mark>> groups = <List<_Mark>>[<_Mark>[]];
  final List<String> ids = <String>[source.first.id];
  final List<RichTextAlign> aligns = <RichTextAlign>[source.first.align];
  var saved = 1;
  var align = source.first.align;

  void pushNewline({required bool insertedBreak}) {
    groups.add(<_Mark>[]);
    if (!insertedBreak && saved < source.length) {
      ids.add(source[saved].id);
      align = source[saved].align;
      saved++;
    } else {
      ids.add(nextId());
    }
    aligns.add(align);
  }

  for (final _Mark mark in marks.take(prefix)) {
    if (mark.unit == '\n') {
      pushNewline(insertedBreak: false);
      continue;
    }
    groups.last.add(mark);
  }
  for (var index = 0; index < inserted.length; index++) {
    final String unit = inserted.substring(index, index + 1);
    if (unit == '\n') {
      pushNewline(insertedBreak: true);
      continue;
    }
    groups.last.add(_Mark(unit, typingSize, typingBold));
  }
  for (final _Mark mark in marks.skip(deleteUntil)) {
    if (mark.unit == '\n') {
      pushNewline(insertedBreak: false);
      continue;
    }
    groups.last.add(mark);
  }

  return <RichTextParagraph>[
    for (var index = 0; index < groups.length; index++)
      RichTextParagraph(
        id: ids[index],
        align: aligns[index],
        runs: _coalesce(
          groups[index],
          emptySize: typingSize,
          emptyBold: typingBold,
        ),
      ),
  ];
}

List<_Mark> _explodeJoined(List<RichTextParagraph> paragraphs) {
  final List<_Mark> marks = <_Mark>[];
  for (var index = 0; index < paragraphs.length; index++) {
    if (index > 0) {
      final RichTextRun run =
          paragraphs[index].runs.isEmpty
              ? const RichTextRun(text: '')
              : paragraphs[index].runs.first;
      marks.add(_Mark('\n', run.size, run.bold));
    }
    marks.addAll(_explode(paragraphs[index]));
  }
  return marks;
}

RichTextParagraph applyInlineStyle({
  required RichTextParagraph paragraph,
  required int start,
  required int end,
  RichTextSize? size,
  bool? bold,
}) {
  final List<_Mark> marks = _explode(paragraph);
  final int from = start.clamp(0, marks.length);
  final int to = end.clamp(from, marks.length);
  final List<_Mark> next = <_Mark>[
    for (var index = 0; index < marks.length; index++)
      if (index < from || index >= to)
        marks[index]
      else
        _Mark(
          marks[index].unit,
          size ?? marks[index].size,
          bold ?? marks[index].bold,
        ),
  ];
  return paragraph.copyWith(runs: _coalesce(next));
}

bool rangeIsBold(RichTextParagraph paragraph, int start, int end) {
  final List<_Mark> marks = _explode(paragraph);
  final int from = start.clamp(0, marks.length);
  final int to = end.clamp(from, marks.length);
  if (from == to) return false;
  for (var index = from; index < to; index++) {
    if (!marks[index].bold) return false;
  }
  return true;
}

RichTextSize? uniformSize(RichTextParagraph paragraph, int start, int end) {
  final List<_Mark> marks = _explode(paragraph);
  final int from = start.clamp(0, marks.length);
  final int to = end.clamp(from, marks.length);
  if (from == to) return null;
  final RichTextSize size = marks[from].size;
  for (var index = from; index < to; index++) {
    if (marks[index].size != size) return null;
  }
  return size;
}

/// 커서가 문단 끝이 아니면 뒤쪽만 새 정렬로 나눈다. 문단 전체를 고른 경우에만 문단 정렬을 바꾼다.
RichTextAlignEdit applyParagraphAlign({
  required RichTextParagraph paragraph,
  required int start,
  required int end,
  required RichTextAlign align,
  required String Function() nextId,
}) {
  final String text = paragraph.text;
  final int from = start.clamp(0, text.length);
  final int to = end.clamp(from, text.length);
  if (text.isEmpty || (from == 0 && to == text.length)) {
    final RichTextParagraph next = paragraph.copyWith(align: align);
    return RichTextAlignEdit(
      paragraphs: <RichTextParagraph>[next],
      focusId: next.id,
      caret: to,
    );
  }
  if (from == to) {
    if (from == 0) {
      final RichTextParagraph next = paragraph.copyWith(align: align);
      return RichTextAlignEdit(
        paragraphs: <RichTextParagraph>[next],
        focusId: next.id,
        caret: 0,
      );
    }
    final _Mark edge = _styleAt(paragraph, from);
    final RichTextParagraph head = RichTextParagraph(
      id: nextId(),
      align: paragraph.align,
      runs: _coalesce(_explode(paragraph).sublist(0, from)),
    );
    final RichTextParagraph tail = RichTextParagraph(
      id: paragraph.id,
      align: align,
      runs: _coalesce(
        _explode(paragraph).sublist(from),
        emptySize: edge.size,
        emptyBold: edge.bold,
      ),
    );
    return RichTextAlignEdit(
      paragraphs: <RichTextParagraph>[head, tail],
      focusId: tail.id,
      caret: 0,
    );
  }
  final List<RichTextParagraph> parts = <RichTextParagraph>[];
  if (from > 0) {
    parts.add(
      RichTextParagraph(
        id: nextId(),
        align: paragraph.align,
        runs: _coalesce(_explode(paragraph).sublist(0, from)),
      ),
    );
  }
  final RichTextParagraph middle = RichTextParagraph(
    id: paragraph.id,
    align: align,
    runs: _coalesce(_explode(paragraph).sublist(from, to)),
  );
  parts.add(middle);
  if (to < text.length) {
    parts.add(
      RichTextParagraph(
        id: nextId(),
        align: paragraph.align,
        runs: _coalesce(_explode(paragraph).sublist(to)),
      ),
    );
  }
  return RichTextAlignEdit(
    paragraphs: parts,
    focusId: middle.id,
    caret: middle.text.length,
  );
}

({RichTextSize size, bool bold}) styleAtCaret(
  RichTextParagraph paragraph,
  int offset,
) {
  final _Mark mark = _styleAt(paragraph, offset);
  return (size: mark.size, bold: mark.bold);
}

/// 문단 목록을 커서 위치에서 둘로 나눈다.
/// 앞쪽이 비면 글의 맨 앞에서 나눈 것이다. 맨 끝이면 뒤쪽은 이어서 쓸 빈 문단이다.
({List<RichTextParagraph> head, List<RichTextParagraph> tail})
splitRichParagraphs({
  required List<RichTextParagraph> paragraphs,
  required String paragraphId,
  required int caret,
  required String Function() nextId,
}) {
  final List<RichTextParagraph> source =
      paragraphs.isEmpty
          ? <RichTextParagraph>[RichTextParagraph(id: nextId())]
          : paragraphs;
  var index = source.indexWhere(
    (RichTextParagraph paragraph) => paragraph.id == paragraphId,
  );
  if (index < 0) index = source.length - 1;
  final RichTextParagraph current = source[index];
  final int offset =
      caret < 0
          ? 0
          : caret > current.text.length
          ? current.text.length
          : caret;
  final List<RichTextParagraph> before = source.sublist(0, index);
  final List<RichTextParagraph> after = source.sublist(index + 1);
  if (offset <= 0) {
    return (head: before, tail: <RichTextParagraph>[current, ...after]);
  }
  if (offset >= current.text.length) {
    return (
      head: <RichTextParagraph>[...before, current],
      tail:
          after.isEmpty
              ? <RichTextParagraph>[
                RichTextParagraph(id: nextId(), align: current.align),
              ]
              : after,
    );
  }
  final List<_Mark> marks = _explode(current);
  final ({RichTextSize size, bool bold}) edge = styleAtCaret(current, offset);
  return (
    head: <RichTextParagraph>[
      ...before,
      RichTextParagraph(
        id: current.id,
        align: current.align,
        runs: _coalesce(marks.sublist(0, offset)),
      ),
    ],
    tail: <RichTextParagraph>[
      RichTextParagraph(
        id: nextId(),
        align: current.align,
        runs: _coalesce(
          marks.sublist(offset),
          emptySize: edge.size,
          emptyBold: edge.bold,
        ),
      ),
      ...after,
    ],
  );
}

String plainTextOf(List<RichTextParagraph> paragraphs) {
  if (paragraphs.isEmpty) return '';
  return paragraphs
      .map((RichTextParagraph paragraph) => paragraph.text)
      .join('\n');
}

/// 선택과 겹치는 줄의 정렬만 바꾼다. 줄바꿈과 글자는 그대로 둔다.
List<RichTextParagraph> setLineAlign({
  required List<RichTextParagraph> paragraphs,
  required int start,
  required int end,
  required RichTextAlign align,
}) {
  if (paragraphs.isEmpty) return paragraphs;
  final int plainLength = plainTextOf(paragraphs).length;
  final int from = start < 0 ? 0 : (start > plainLength ? plainLength : start);
  final int to = end < from ? from : (end > plainLength ? plainLength : end);
  final List<RichTextParagraph> next = <RichTextParagraph>[];
  var cursor = 0;
  for (final RichTextParagraph paragraph in paragraphs) {
    final int paragraphStart = cursor;
    final int paragraphEnd = cursor + paragraph.text.length;
    final bool hit =
        from == to
            ? from >= paragraphStart && from <= paragraphEnd
            : from <= paragraphEnd && to > paragraphStart;
    next.add(hit ? paragraph.copyWith(align: align) : paragraph);
    cursor = paragraphEnd + 1;
  }
  return next;
}

({String id, int caret}) caretInParagraphs(
  List<RichTextParagraph> paragraphs,
  int offset,
) {
  if (paragraphs.isEmpty) return (id: '', caret: 0);
  var remaining = offset < 0 ? 0 : offset;
  for (var index = 0; index < paragraphs.length; index++) {
    final RichTextParagraph paragraph = paragraphs[index];
    final bool last = index == paragraphs.length - 1;
    if (remaining <= paragraph.text.length || last) {
      final int caret =
          remaining < 0
              ? 0
              : remaining > paragraph.text.length
              ? paragraph.text.length
              : remaining;
      return (id: paragraph.id, caret: caret);
    }
    remaining -= paragraph.text.length + 1;
  }
  final RichTextParagraph last = paragraphs.last;
  return (id: last.id, caret: last.text.length);
}
