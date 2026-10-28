/// 금액이 이번 견적과 어떤 관계인지.
enum PriceEffect {
  included('포함'),
  extra('별도'),
  mayChange('변동'),
  leftOut('제외');

  const PriceEffect(this.mark);

  /// 카드에 붙는 짧은 표시.
  final String mark;
}

/// 시공안에서 금액이 움직인 판단 하나.
/// 상담에서 나온 말은 근거로 남기고, 결론은 담당자가 정한다.
class QuoteJudgment {
  const QuoteJudgment({
    required this.conclusion,
    required this.customerNote,
    required this.staffNote,
    required this.effect,
    this.tradeName = '',
  });

  final String conclusion;
  final String customerNote;
  final String staffNote;
  final PriceEffect effect;

  /// 이 판단이 붙는 공사항목. 없으면 비운다.
  final String tradeName;
}

/// 고객이 받는 자료 종류.
enum ProjectDocumentKind { estimate, proposal, model, draft }

/// 견적서, 제안서, 3D 도면, 공사시안.
class ProjectDocument {
  const ProjectDocument({
    required this.kind,
    required this.title,
    required this.note,
    this.fileName = '',
    this.ready = false,
  });

  final ProjectDocumentKind kind;
  final String title;
  final String note;

  /// 원본 파일 이름. 아직 없으면 비운다.
  final String fileName;

  /// 앱에서 펼쳐 볼 수 있는지.
  final bool ready;
}

/// 제안서 한 장. 원본은 도면 PDF다.
class ProposalPage {
  const ProposalPage({required this.title, required this.caption});

  final String title;
  final String caption;
}

/// 항목에 들어가는 자재 하나. 규격, 수량, 금액은 서버에서 온다.
class EstimateMaterial {
  const EstimateMaterial({
    required this.name,
    this.spec = '',
    this.unit = '',
    this.quantity = '',
    this.amount,
  });

  final String name;
  final String spec;
  final String unit;
  final String quantity;

  /// 이 자재의 금액. 아직 없으면 null.
  final int? amount;
}

/// 견적 세부 한 줄. 공사항목 안에서 품목과 자재는 매번 달라진다.
class EstimateLine {
  const EstimateLine({
    required this.name,
    this.spec = '',
    this.unit = '',
    this.quantity = '',
    this.material,
    this.labor,
    this.materials = const <EstimateMaterial>[],
  });

  final String name;
  final String spec;
  final String unit;
  final String quantity;

  /// 자재별 금액이 없을 때 쓰는 재료비. 칸이 비어 있으면 null.
  final int? material;

  /// 노무비 금액. 항목마다 나누지 않고 공종 합계로만 보여 준다.
  final int? labor;

  /// 이 항목에 들어가는 자재. 비어 있으면 아직 자재 내역이 없는 것이다.
  final List<EstimateMaterial> materials;

  bool get hasMaterialPrices =>
      materials.any((EstimateMaterial item) => item.amount != null);

  /// 자재별 금액이 있으면 그 합이고, 없으면 [material]이다.
  int? get materialTotal {
    if (!hasMaterialPrices) return material;
    return materials.fold<int>(
      0,
      (int sum, EstimateMaterial item) => sum + (item.amount ?? 0),
    );
  }

  bool get hasMoney => materialTotal != null || labor != null;

  int get total => (materialTotal ?? 0) + (labor ?? 0);
}

/// 견적서에서 고정으로 두는 공사항목.
class EstimateTrade {
  const EstimateTrade({
    required this.name,
    this.lines = const <EstimateLine>[],
  });

  final String name;
  final List<EstimateLine> lines;

  int get material => lines.fold(
    0,
    (int sum, EstimateLine line) => sum + (line.materialTotal ?? 0),
  );

  int get labor =>
      lines.fold(0, (int sum, EstimateLine line) => sum + (line.labor ?? 0));

  int get total => material + labor;
}

/// 엑셀 견적서의 본문. 표지 문구와 조건, 공사항목을 담는다.
class EstimateSheet {
  const EstimateSheet({
    required this.trades,
    this.conditions = const <String>[],
    this.vatRate = 0.1,
  });

  final List<EstimateTrade> trades;
  final List<String> conditions;

  /// 부가세 비율. 0.1이면 10% 별도.
  final double vatRate;

  int get material =>
      trades.fold(0, (int sum, EstimateTrade trade) => sum + trade.material);

  int get labor =>
      trades.fold(0, (int sum, EstimateTrade trade) => sum + trade.labor);

  int get subtotal => material + labor;

  int get vat => (subtotal * vatRate).round();

  int get grandTotal => subtotal + vat;

  EstimateTrade? tradeNamed(String name) {
    for (final EstimateTrade trade in trades) {
      if (trade.name == name) return trade;
    }
    return null;
  }
}

/// 시공 판단과 견적, 받은 자료를 한곳에 둔 묶음.
class WorkQuote {
  const WorkQuote({
    required this.documentTitle,
    required this.company,
    required this.statusLabel,
    required this.sheet,
    this.judgments = const <QuoteJudgment>[],
    this.documents = const <ProjectDocument>[],
    this.proposalPages = const <ProposalPage>[],
  });

  /// 견적서 표지에 적힌 공사명.
  final String documentTitle;
  final String company;
  final String statusLabel;
  final EstimateSheet sheet;
  final List<QuoteJudgment> judgments;
  final List<ProjectDocument> documents;
  final List<ProposalPage> proposalPages;

  ProjectDocument? documentOf(ProjectDocumentKind kind) {
    for (final ProjectDocument item in documents) {
      if (item.kind == kind) return item;
    }
    return null;
  }
}

/// 금액을 천 단위로 끊는다. 원 단위 글자는 붙이지 않는다.
String formatWon(int value) {
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  final String body = buffer.toString();
  return value < 0 ? '-$body' : body;
}
