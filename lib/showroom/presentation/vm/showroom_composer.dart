import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';

class ShowroomDraft {
  const ShowroomDraft({
    this.seeded = false,
    this.projectId = '',
    this.projectName = '',
    this.sitePhotos = const <PublicSitePhoto>[],
    this.thumbnailUrl = '',
    this.title = '',
    this.style = '',
    this.industry = '',
    this.areaPyeong = 50,
    this.area = '50평',
    this.budget = '',
    this.period = '',
    this.periodStart,
    this.periodEnd,
    this.showCostDetail = false,
    this.costFromQuote = false,
    this.costTotal = '',
    this.costLines = const <ShowroomCostLine>[],
    this.process = const <ShowroomProcessFrame>[],
    this.blocks = const <ShowroomBlock>[],
  });

  final bool seeded;
  final String projectId;
  final String projectName;
  final List<PublicSitePhoto> sitePhotos;
  final String thumbnailUrl;
  final String title;
  final String style;
  final String industry;
  final int areaPyeong;
  final String area;
  final String budget;
  final String period;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  /// 세부 공사비를 글에 넣기로 한 뒤에만 보여 준다.
  final bool showCostDetail;

  /// 지금 적힌 세부 공사비가 견적서에서 온 것인지.
  final bool costFromQuote;
  final String costTotal;
  final List<ShowroomCostLine> costLines;
  final List<ShowroomProcessFrame> process;
  final List<ShowroomBlock> blocks;

  bool get hasBody => blocks.any((ShowroomBlock block) => block.hasContent);

  bool get canPreview => title.trim().isNotEmpty && hasBody;

  ShowroomCost get cost =>
      ShowroomCost(total: costTotal.trim(), lines: costLines);

  bool uses(String url) {
    if (url.isEmpty) return false;
    if (thumbnailUrl == url) return true;
    if (process.any((ShowroomProcessFrame frame) => frame.imageUrl == url)) {
      return true;
    }
    return blocks.any((ShowroomBlock block) => block.containsUrl(url));
  }

  /// 글 메타와 본문 순서를 한 문서로 보낸다. `body.blocks` 배열이 저장 순서다.
  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'projectId': projectId,
      'title': title,
      'style': style,
      'thumbnailUrl': thumbnailUrl,
      'industry': industry,
      'areaPyeong': areaPyeong,
      'area': area,
      'budget': budget,
      'periodStart': periodStart?.toIso8601String(),
      'periodEnd': periodEnd?.toIso8601String(),
      'costTotal': showCostDetail ? costTotal : '',
      'costLines':
          showCostDetail
              ? <Map<String, String>>[
                for (final ShowroomCostLine line in costLines)
                  <String, String>{'name': line.name, 'amount': line.amount},
              ]
              : const <Map<String, String>>[],
      'process': <Map<String, String>>[
        for (final ShowroomBlock block in blocks)
          if (block.kind == ShowroomBlockKind.process)
            for (final ShowroomProcessFrame frame in block.frames)
              if (frame.imageUrl.trim().isNotEmpty ||
                  frame.trade.trim().isNotEmpty ||
                  frame.caption.trim().isNotEmpty)
                <String, String>{
                  'trade': frame.trade,
                  'imageUrl': frame.imageUrl,
                  'caption': frame.caption,
                },
      ],
      'body': ShowroomBodyDocument(blocks).toJson(),
    };
  }

  ShowroomDraft copyWith({
    bool? seeded,
    String? projectId,
    String? projectName,
    List<PublicSitePhoto>? sitePhotos,
    String? thumbnailUrl,
    String? title,
    String? style,
    String? industry,
    int? areaPyeong,
    String? area,
    String? budget,
    String? period,
    DateTime? periodStart,
    DateTime? periodEnd,
    bool? showCostDetail,
    bool? costFromQuote,
    String? costTotal,
    List<ShowroomCostLine>? costLines,
    List<ShowroomProcessFrame>? process,
    List<ShowroomBlock>? blocks,
  }) {
    return ShowroomDraft(
      seeded: seeded ?? this.seeded,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      sitePhotos: sitePhotos ?? this.sitePhotos,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      style: style ?? this.style,
      industry: industry ?? this.industry,
      areaPyeong: areaPyeong ?? this.areaPyeong,
      area: area ?? this.area,
      budget: budget ?? this.budget,
      period: period ?? this.period,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      showCostDetail: showCostDetail ?? this.showCostDetail,
      costFromQuote: costFromQuote ?? this.costFromQuote,
      costTotal: costTotal ?? this.costTotal,
      costLines: costLines ?? this.costLines,
      process: process ?? this.process,
      blocks: blocks ?? this.blocks,
    );
  }
}

class ShowroomComposer extends Notifier<ShowroomDraft> {
  int _seq = 0;

  String _nextId(String prefix) => '$prefix-${_seq++}';

  @override
  ShowroomDraft build() => const ShowroomDraft();

  ShowroomDraft seed({
    SpaceProject? project,
    PrepRecord? record,
    List<PublicSitePhoto> photos = const <PublicSitePhoto>[],
  }) {
    final int pyeong = _pyeong(record);
    final DateTime? periodStart = record?.periodStart;
    final DateTime? periodEnd = record?.periodEnd;
    final ShowroomDraft draft = ShowroomDraft(
      seeded: true,
      projectId: project?.id ?? '',
      projectName: project?.placeName ?? record?.placeName ?? '',
      sitePhotos: photos,
      title: record?.placeName ?? project?.placeName ?? '',
      style: _styleName(record),
      industry: _industry(record),
      areaPyeong: pyeong,
      area: '$pyeong평',
      budget: _budgetWon(record),
      period: _periodLabel(periodStart, periodEnd),
      periodStart: periodStart,
      periodEnd: periodEnd,
      process: const <ShowroomProcessFrame>[],
      blocks: _blocksFrom(record),
    );
    state = draft;
    return draft;
  }

  void setTitle(String value) => state = state.copyWith(title: value);
  void setStyle(String value) => state = state.copyWith(style: value);
  void setIndustry(String value) => state = state.copyWith(industry: value);
  void setBudget(String value) => state = state.copyWith(budget: value);
  void setCostTotal(String value) => state = state.copyWith(costTotal: value);

  /// 견적 공종으로 세부 공사비를 채운다.
  void loadCostFromQuote(WorkQuote quote) {
    final ShowroomCost filled = showroomCostFromQuote(quote);
    state = state.copyWith(
      showCostDetail: true,
      costFromQuote: true,
      costTotal: filled.total,
      costLines: filled.lines,
    );
  }

  /// 빈 항목 하나로 세부 공사비를 직접 적기 시작한다.
  void startCostDetail() {
    state = state.copyWith(
      showCostDetail: true,
      costFromQuote: false,
      costTotal: '',
      costLines: const <ShowroomCostLine>[
        ShowroomCostLine(name: '', amount: ''),
      ],
    );
  }

  /// 세부 공사비를 글에서 뺀다.
  void clearCostDetail() {
    state = state.copyWith(
      showCostDetail: false,
      costFromQuote: false,
      costTotal: '',
      costLines: const <ShowroomCostLine>[],
    );
  }

  void addCostLine() {
    state = state.copyWith(
      costLines: <ShowroomCostLine>[
        ...state.costLines,
        const ShowroomCostLine(name: '', amount: ''),
      ],
    );
  }

  void updateCostLine(int index, {String? name, String? amount}) {
    if (index < 0 || index >= state.costLines.length) return;
    final List<ShowroomCostLine> lines = <ShowroomCostLine>[...state.costLines];
    final ShowroomCostLine current = lines[index];
    lines[index] = ShowroomCostLine(
      name: name ?? current.name,
      amount: amount ?? current.amount,
    );
    state = state.copyWith(costLines: lines);
  }

  void removeCostLine(int index) {
    if (index < 0 || index >= state.costLines.length) return;
    final List<ShowroomCostLine> lines = <ShowroomCostLine>[...state.costLines]
      ..removeAt(index);
    state = state.copyWith(costLines: lines);
  }

  /// 현장 공정 순서대로 공정 이름, 기록된 내용, 그 공정의 사진을 채운다.
  List<ShowroomProcessFrame> framesFromRecord(ConstructionProgress progress) {
    final List<ShowroomProcessFrame> frames = <ShowroomProcessFrame>[];
    for (final String raw in progress.trades) {
      final String trade = raw.trim();
      if (trade.isEmpty) continue;
      frames.add(
        ShowroomProcessFrame(
          id: _nextId('process'),
          trade: trade,
          caption: _recordNote(progress, trade),
          imageUrl: _recordPhoto(progress, trade),
        ),
      );
    }
    return frames;
  }

  void setThumbnail(String url) => state = state.copyWith(thumbnailUrl: url);
  void clearThumbnail() => state = state.copyWith(thumbnailUrl: '');

  void setAreaPyeong(int value) {
    final int pyeong = value.clamp(1, 1000);
    state = state.copyWith(areaPyeong: pyeong, area: '$pyeong평');
  }

  void setPeriodRange(DateTime start, DateTime end) {
    final DateTime from = DateTime(start.year, start.month, start.day);
    final DateTime to = DateTime(end.year, end.month, end.day);
    state = state.copyWith(
      periodStart: from,
      periodEnd: to,
      period: _periodLabel(from, to),
    );
  }

  ShowroomAreaInsert insertAreaInside({
    String? blockId,
    String? paragraphId,
    int? caret,
    ShowroomImageLayout layout = ShowroomImageLayout.slider,
    String imageUrl = '',
    List<String> imageUrls = const <String>[],
  }) {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: state.blocks,
      nextId: () => _nextId('body'),
      blockId: blockId,
      paragraphId: paragraphId,
      caret: caret,
      layout: layout,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
    );
    _replace(inserted.blocks);
    return inserted;
  }

  String insertImageAfter(String blockId, String url) {
    final String id = _nextId('images');
    final ShowroomBlock created = ShowroomBlock.images(
      id: id,
      urls: <String>[url],
    );
    final int index = state.blocks.indexWhere(
      (ShowroomBlock block) => block.id == blockId,
    );
    final List<ShowroomBlock> next = <ShowroomBlock>[...state.blocks];
    next.insert(index < 0 ? next.length : index + 1, created);
    _replace(next);
    return id;
  }

  void removeBlock(String id) {
    _replace(
      state.blocks.where((ShowroomBlock block) => block.id != id).toList(),
    );
  }

  void moveBlock(String id, int delta) {
    final int index = state.blocks.indexWhere(
      (ShowroomBlock block) => block.id == id,
    );
    if (index < 0) return;
    final int target = index + delta;
    if (target < 0 || target >= state.blocks.length) return;
    final List<ShowroomBlock> next = <ShowroomBlock>[...state.blocks];
    final ShowroomBlock block = next.removeAt(index);
    next.insert(target, block);
    _replace(next);
  }

  void updateParagraphs(String id, List<RichTextParagraph> paragraphs) {
    _map(id, (ShowroomBlock block) => block.copyWith(paragraphs: paragraphs));
  }

  void setImageLayout(String id, ShowroomImageLayout layout) {
    _map(id, (ShowroomBlock block) {
      return block.withLayout(layout, _nextId('pair'));
    });
  }

  void addBlockImage(String id, String url) {
    addBlockImages(id, <String>[url]);
  }

  void addBlockImages(String id, List<String> urls) {
    final List<String> incoming =
        urls.where((String url) => url.isNotEmpty).toList();
    if (incoming.isEmpty) return;
    _map(id, (ShowroomBlock block) {
      ShowroomBlock next = block;
      for (final String url in incoming) {
        next = next.added(url, _nextId('pair'));
      }
      return next;
    });
  }

  void removeBlockImage(String id, int index) {
    _map(id, (ShowroomBlock block) {
      if (index < 0 || index >= block.urls.length) return block;
      final List<String> urls = <String>[...block.urls]..removeAt(index);
      return block.copyWith(urls: urls);
    });
  }

  void addPair(String id) {
    _map(id, (ShowroomBlock block) {
      return block.copyWith(
        pairs: <ShowroomBeforeAfterPair>[
          ...block.pairs,
          ShowroomBeforeAfterPair(id: _nextId('pair')),
        ],
      );
    });
  }

  void setPairImage(
    String blockId,
    String pairId, {
    required bool before,
    required String url,
  }) {
    _map(blockId, (ShowroomBlock block) {
      return block.copyWith(
        pairs: <ShowroomBeforeAfterPair>[
          for (final ShowroomBeforeAfterPair pair in block.pairs)
            if (pair.id != pairId)
              pair
            else if (before)
              pair.copyWith(beforeUrl: url)
            else
              pair.copyWith(afterUrl: url),
        ],
      );
    });
  }

  void setPairCaption(String blockId, String pairId, String caption) {
    _map(blockId, (ShowroomBlock block) {
      return block.copyWith(
        pairs: <ShowroomBeforeAfterPair>[
          for (final ShowroomBeforeAfterPair pair in block.pairs)
            if (pair.id == pairId) pair.copyWith(caption: caption) else pair,
        ],
      );
    });
  }

  void removePair(String blockId, String pairId) {
    _map(blockId, (ShowroomBlock block) {
      return block.copyWith(
        pairs:
            block.pairs
                .where((ShowroomBeforeAfterPair pair) => pair.id != pairId)
                .toList(),
      );
    });
  }

  void setBlocks(List<ShowroomBlock> blocks) {
    _replace(blocks);
  }

  void _replace(List<ShowroomBlock> blocks) {
    state = state.copyWith(blocks: blocks);
  }

  void _map(String id, ShowroomBlock Function(ShowroomBlock block) update) {
    _replace(<ShowroomBlock>[
      for (final ShowroomBlock block in state.blocks)
        if (block.id == id) update(block) else block,
    ]);
  }

  List<ShowroomBlock> _blocksFrom(PrepRecord? record) {
    final List<String> names =
        (record?.workPlace ?? '')
            .split(RegExp(r'[,·/]'))
            .map((String name) => name.trim())
            .where((String name) => name.isNotEmpty)
            .toList();
    if (names.isEmpty) {
      return <ShowroomBlock>[
        ShowroomBlock.text(id: _nextId('text'), paragraphId: _nextId('para')),
      ];
    }
    return <ShowroomBlock>[
      for (final String name in names) ...<ShowroomBlock>[
        ShowroomBlock.text(
          id: _nextId('text'),
          paragraphId: _nextId('para'),
          text: name,
          bold: true,
        ),
        ShowroomBlock.images(
          id: _nextId('images'),
          layout: ShowroomImageLayout.beforeAfter,
          pairs: <ShowroomBeforeAfterPair>[
            ShowroomBeforeAfterPair(id: _nextId('pair'), caption: name),
          ],
        ),
      ],
    ];
  }

  String _clean(String? value) => value?.trim() ?? '';

  String _industry(PrepRecord? record) {
    final String industry = _clean(record?.industry);
    if (industry.isEmpty || industry == PrepLabels.industryUndecided) return '';
    for (final IndustryCategory category in industryCategories) {
      for (final IndustryDetail detail in category.details) {
        if (detail.name == industry || detail.name.startsWith(industry)) {
          return detail.name;
        }
      }
    }
    return industry;
  }

  int _pyeong(PrepRecord? record) {
    if (record == null) return 50;
    final String area = record.area.trim();
    if (area.isEmpty || area == PrepLabels.areaUnknown) return 50;
    final RegExpMatch? match = RegExp(r'\d+').firstMatch(area);
    final int? parsed = match == null ? null : int.tryParse(match.group(0)!);
    if (parsed == null) return 50;
    return parsed.clamp(1, 1000);
  }

  String _styleName(PrepRecord? record) {
    final String raw = _clean(record?.style);
    for (final StyleMoodCard card in styleMoodCards) {
      if (card.title == raw) return card.title;
    }
    return '';
  }

  String _budgetWon(PrepRecord? record) {
    final int? won = _wonAmount(record?.budget ?? '');
    if (won == null || won <= 0) return '';
    return '${_grouped(won)}원';
  }

  int? _wonAmount(String raw) {
    final String text = raw.replaceAll(',', '').replaceAll(' ', '');
    if (text.isEmpty) return null;
    final RegExpMatch? eok = RegExp(r'(\d+)\s*억').firstMatch(text);
    final RegExpMatch? man = RegExp(r'(\d+)\s*만').firstMatch(text);
    if (eok != null || man != null) {
      final int eokWon =
          eok == null ? 0 : (int.tryParse(eok.group(1)!) ?? 0) * 100000000;
      final int manWon =
          man == null ? 0 : (int.tryParse(man.group(1)!) ?? 0) * 10000;
      final int sum = eokWon + manWon;
      return sum == 0 ? null : sum;
    }
    final String digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits);
  }

  String _grouped(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  String _periodLabel(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    final DateTime from = DateTime(start.year, start.month, start.day);
    final DateTime to = DateTime(end.year, end.month, end.day);
    final int days = to.difference(from).inDays.abs() + 1;
    return showroomSpanLabel(days);
  }

  String _recordNote(ConstructionProgress progress, String trade) {
    if (_sameTrade(progress.todayTrade, trade) &&
        progress.todaySummary.trim().isNotEmpty) {
      return progress.todaySummary.trim();
    }
    if (_sameTrade(progress.nextTrade, trade) &&
        progress.nextSummary.trim().isNotEmpty) {
      return progress.nextSummary.trim();
    }
    for (final SideTrade side in progress.sideTrades) {
      if (_sameTrade(side.name, trade) && side.summary.trim().isNotEmpty) {
        return side.summary.trim();
      }
    }
    return '';
  }

  String _recordPhoto(ConstructionProgress progress, String trade) {
    for (final PublicSitePhoto photo in progress.recentPhotos) {
      if (_sameTrade(photo.trade, trade)) return photo.imageUrl;
    }
    return '';
  }

  bool _sameTrade(String label, String trade) {
    final String left = label.replaceAll(' ', '');
    final String right = trade.replaceAll(' ', '');
    if (left.isEmpty || right.isEmpty) return false;
    return left.contains(right) || right.contains(left);
  }
}

/// 고른 날짜 사이를 개월과 주로 줄여 보여 준다. 하루는 양 끝을 포함한다.
String showroomSpanLabel(int days) {
  if (days <= 0) return '';
  if (days < 7) return '$days일';
  var months = days ~/ 30;
  var weeks = (days % 30) ~/ 7;
  if (days % 30 % 7 >= 4) weeks += 1;
  if (weeks >= 4) {
    months += 1;
    weeks -= 4;
  }
  if (months > 0 && weeks > 0) return '$months개월 $weeks주';
  if (months > 0) return '$months개월';
  return '$weeks주';
}

/// 견적 공종을 세부 공사비로 옮긴다. 경비와 기타 시공은 기타 한 줄로 묶는다.
ShowroomCost showroomCostFromQuote(WorkQuote quote) {
  final List<ShowroomCostLine> lines = <ShowroomCostLine>[];
  final Map<String, int> indexOf = <String, int>{};
  int misc = 0;

  void add(String name, int amount) {
    if (amount <= 0 || name.isEmpty) return;
    final int? index = indexOf[name];
    if (index == null) {
      indexOf[name] = lines.length;
      lines.add(ShowroomCostLine(name: name, amount: '${formatWon(amount)}원'));
      return;
    }
    final int current =
        int.tryParse(lines[index].amount.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    lines[index] = ShowroomCostLine(
      name: name,
      amount: '${formatWon(current + amount)}원',
    );
  }

  for (final EstimateTrade trade in quote.sheet.trades) {
    if (trade.total <= 0) continue;
    if (_overheadTrade(trade.name)) {
      misc += trade.total;
      continue;
    }
    final String tradeName = _tradeLabel(trade.name);
    for (final EstimateLine line in trade.lines) {
      if (line.total <= 0) continue;
      if (_overheadLine(line.name)) {
        misc += line.total;
      } else if (tradeName != '조명' && line.name.contains('조명')) {
        add('조명', line.total);
      } else {
        add(tradeName, line.total);
      }
    }
  }
  add('기타', misc);
  final int sum = lines.fold<int>(0, (int total, ShowroomCostLine line) {
    return total +
        (int.tryParse(line.amount.replaceAll(RegExp(r'[^\d]'), '')) ?? 0);
  });
  return ShowroomCost(
    total: sum <= 0 ? '' : '${formatWon(sum)}원',
    lines: lines,
  );
}

bool _overheadTrade(String name) {
  final String compact = name.replaceAll(RegExp(r'\s'), '');
  return compact.contains('경비') || compact.startsWith('기타');
}

bool _overheadLine(String name) {
  final String compact = name.replaceAll(RegExp(r'\s'), '');
  return compact.contains('잡비') || compact.contains('경비');
}

String _tradeLabel(String name) {
  var text = name.trim();
  if (text.endsWith('공사')) {
    text = text.substring(0, text.length - 2);
  } else if (text.endsWith('시공')) {
    text = text.substring(0, text.length - 2);
  }
  return text.trim();
}

final showroomComposerProvider =
    NotifierProvider.autoDispose<ShowroomComposer, ShowroomDraft>(
      ShowroomComposer.new,
    );
