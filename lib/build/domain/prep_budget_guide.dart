import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_survey.dart';

/// 상담 내용으로 가늠한 예산 상태. 확정 견적이 아니다.
enum PrepBudgetFit {
  unknown,
  adequate,
  tight,
  over,
}

/// 평수와 예산, 고른 마감으로 평당 금액을 비교한 결과.
class PrepBudgetReading {
  const PrepBudgetReading({
    required this.fit,
    required this.headline,
    required this.body,
    this.customerPerPyeong,
    this.expectedPerPyeong,
    this.customerTotal,
    this.expectedTotal,
    this.expensiveLabels = const <String>[],
    this.basisCaption = '',
  });

  final PrepBudgetFit fit;
  final String headline;
  final String body;

  /// 고객이 적은 예산을 평수로 나눈 금액.
  final int? customerPerPyeong;

  /// 보통 마감 기준에 고른 항목을 더하거나 뺀 예상 평당.
  final int? expectedPerPyeong;

  final int? customerTotal;
  final int? expectedTotal;

  /// 예상 평당을 올린 비싼 선택지.
  final List<String> expensiveLabels;

  /// 어떤 업종, 환경, 상황의 서버 기준인지. 없으면 비어 있다.
  final String basisCaption;

  bool get hasNumbers => customerPerPyeong != null && expectedPerPyeong != null;
}

/// 서버에 평당 기준을 물어볼 조건. 업종, 환경, 상황마다 금액이 다르다.
class PrepPyeongQuery {
  const PrepPyeongQuery({
    required this.industry,
    required this.environment,
    required this.situation,
  });

  /// 업종. 기타로 적었으면 그 글이다.
  final String industry;

  /// 환경. 지금은 철거 여부이고, 서버 조건이 늘면 여기만 넓힌다.
  final String environment;

  /// 상황. 지금은 공사 형태이고, 서버 조건이 늘면 여기만 넓힌다.
  final String situation;

  bool get isComplete =>
      industry.trim().isNotEmpty &&
      industry != PrepLabels.industryUndecided &&
      environment.trim().isNotEmpty &&
      situation.trim().isNotEmpty;

  String get label => [industry, environment, situation]
      .where((String part) => part.trim().isNotEmpty)
      .join(' · ');
}

/// 서버가 내려 준 한 조건의 평당 기준.
class PrepPyeongBasis {
  const PrepPyeongBasis({
    required this.basePerPyeong,
    required this.lowDelta,
    required this.highDelta,
    required this.industry,
    required this.environment,
    required this.situation,
  });

  /// 그 조건의 보통 마감 평당.
  final int basePerPyeong;

  /// 저렴한 선택지를 기준 평당에 더하는 값. 내리려면 음수다.
  final int lowDelta;

  /// 비싼 선택지를 기준 평당에 더하는 값. 올리려면 양수다.
  final int highDelta;

  final String industry;
  final String environment;
  final String situation;

  factory PrepPyeongBasis.fromJson(Map<String, dynamic> json) {
    return PrepPyeongBasis(
      basePerPyeong: (json['basePerPyeong'] as num).round(),
      lowDelta: (json['lowDelta'] as num?)?.round() ?? 0,
      highDelta: (json['highDelta'] as num?)?.round() ?? 0,
      industry: json['industry'] as String? ?? '',
      environment: json['environment'] as String? ?? '',
      situation: json['situation'] as String? ?? '',
    );
  }
}

/// 상담 전 예산 가늠. 평당 기준은 서버가 조건별로 내려 준다.
abstract final class PrepBudgetGuide {
  static const double sqmPerPyeong = 3.305785;

  static PrepBudgetReading read({
    required String area,
    required String budget,
    required Map<String, PrepFinishAnswer> finishes,
    required PrepPyeongQuery query,
    required PrepPyeongBasis? basis,
  }) {
    if (!query.isComplete) {
      return const PrepBudgetReading(
        fit: PrepBudgetFit.unknown,
        headline: '평당 기준을 고를 조건이 아직 없어요',
        body: '업종, 철거 여부, 공사 형태가 있어야 그 조건의 평당 기준을 서버에서 받을 수 있어요. 없어도 저장할 수 있어요.',
      );
    }
    if (basis == null) {
      return PrepBudgetReading(
        fit: PrepBudgetFit.unknown,
        headline: '이 조건의 평당 기준을 아직 받지 못했어요',
        body: '${query.label} 조건의 평당은 서버에서 받아요. 업종, 환경, 상황마다 달라서, 기준이 오기 전에는 초과 여부를 말하지 않아요. 없어도 저장할 수 있어요.',
        basisCaption: query.label,
      );
    }
    final double? pyeong = _pyeongOf(area);
    final int? total = _wonOf(budget);
    if (pyeong == null || total == null) {
      return PrepBudgetReading(
        fit: PrepBudgetFit.unknown,
        headline: '평당 금액을 아직 볼 수 없어요',
        body: '평수와 예산이 있어야 서버 기준과 비교할 수 있어요. 몰라도 저장할 수 있고, 상담에서 이어서 확인해요.',
        basisCaption: query.label,
      );
    }

    final List<String> expensive = <String>[];
    int delta = 0;
    for (final PrepQuestion question in PrepSurvey.details) {
      final PrepFinishAnswer? answer = finishes[question.id];
      if (answer == null) continue;
      for (final String label in answer.choices) {
        final PrepFinishOption? option = question.optionOf(label);
        if (option == null || option.undecided) continue;
        delta += switch (option.cost) {
          PrepCostBand.low => basis.lowDelta,
          PrepCostBand.mid => 0,
          PrepCostBand.high => basis.highDelta,
          null => 0,
        };
        if (option.cost == PrepCostBand.high) expensive.add(label);
      }
    }

    final int adjusted = basis.basePerPyeong + delta;
    final int expectedPer = adjusted < 0 ? 0 : adjusted;
    final int customerPer = (total / pyeong).round();
    final int expectedTotal = (expectedPer * pyeong).round();
    final PrepBudgetFit fit = customerPer >= expectedPer
        ? PrepBudgetFit.adequate
        : customerPer >= expectedPer * 0.85
        ? PrepBudgetFit.tight
        : PrepBudgetFit.over;

    return PrepBudgetReading(
      fit: fit,
      headline: switch (fit) {
        PrepBudgetFit.adequate => '예산이 적당해 보여요',
        PrepBudgetFit.tight => '예산이 빠듯해 보여요',
        PrepBudgetFit.over => '예산이 초과될 위험이 있어요',
        PrepBudgetFit.unknown => '평당 금액을 아직 볼 수 없어요',
      },
      body: switch (fit) {
        PrepBudgetFit.adequate =>
          '지금 고른 마감은 예산 평당 안에서 검토해 볼 만해요. 확정 견적이 아니고, 현장 확인과 상담 후에 금액은 달라질 수 있어요.',
        PrepBudgetFit.tight =>
          '예상 평당이 예산 평당에 가까워요. 상담에서 범위를 한 번 더 보면 좋아요. 현장 확인 후에 금액은 달라질 수 있어요.',
        PrepBudgetFit.over =>
          '이 마감이면 공사비가 예산보다 커질 수 있어요. 상담에서 범위를 줄이거나 예산을 다시 봐야 공사를 맞출 수 있어요. 확정 견적이 아니고, 현장 확인 후에 달라집니다.',
        PrepBudgetFit.unknown =>
          '평수와 예산이 있어야 비교할 수 있어요. 몰라도 저장할 수 있고, 상담에서 이어서 확인해요.',
      },
      customerPerPyeong: customerPer,
      expectedPerPyeong: expectedPer,
      customerTotal: total,
      expectedTotal: expectedTotal,
      expensiveLabels: List<String>.unmodifiable(expensive),
      basisCaption: query.label,
    );
  }

  static String formatWon(int won) {
    if (won >= 100000000) {
      final double eok = won / 100000000;
      final String head = _oneDecimal(eok, '억');
      final int rest = won % 100000000;
      if (rest < 10000) return '$head 원';
      return '$head ${_oneDecimal(rest / 10000, '만')} 원';
    }
    if (won >= 10000) return '${_oneDecimal(won / 10000, '만')} 원';
    return '$won원';
  }

  static String _oneDecimal(double value, String unit) {
    final double rounded = (value * 10).round() / 10;
    if ((rounded - rounded.roundToDouble()).abs() < 0.05) return '${rounded.round()}$unit';
    return '${rounded.toStringAsFixed(1)}$unit';
  }

  static double? _pyeongOf(String area) {
    final String trimmed = area.trim();
    if (trimmed.isEmpty || trimmed == PrepLabels.areaUnknown) return null;
    if (trimmed.endsWith('㎡')) {
      final double? sqm = double.tryParse(trimmed.replaceAll('㎡', '').replaceAll(',', '').trim());
      if (sqm == null || sqm <= 0) return null;
      return sqm / sqmPerPyeong;
    }
    final double? pyeong = double.tryParse(trimmed.replaceAll('평', '').replaceAll(',', '').trim());
    if (pyeong == null || pyeong <= 0) return null;
    return pyeong;
  }

  static int? _wonOf(String budget) {
    final String trimmed = budget.trim();
    if (trimmed.isEmpty || trimmed == PrepLabels.budgetUndecided) return null;
    if (trimmed.contains('만') || trimmed.contains('억')) return null;
    final String digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final int? won = int.tryParse(digits);
    if (won == null || won <= 0) return null;
    return won;
  }
}
