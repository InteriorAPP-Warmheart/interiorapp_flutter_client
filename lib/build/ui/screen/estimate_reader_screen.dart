import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/original_file_sheet.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/quote_money_summary.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';

/// 줄이 바로 구분되도록 하는 교차색. 흰 줄과 차이가 보이게 둔다.
Color _rowTone(int index) {
  return index.isOdd ? const Color(0xFFD5DCE4) : AppColors.surface;
}

/// 한 공종의 세부 항목. 항목이 많으면 시트 안에서 내려 본다.
void showEstimateTradeSheet(BuildContext context, EstimateTrade trade) {
  final double fontScale = ResponsiveSize.fontScale(context);
  final bool empty = trade.lines.isEmpty;
  showAppBottomSheet<void>(
    context: context,
    title: trade.name,
    message: empty ? '넣은 항목이 없어요.' : '항목 ${trade.lines.length}개',
    size: AppBottomSheetSize.expanded,
    child:
        empty
            ? const SizedBox.shrink()
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuoteMoneySummary(
                  material: trade.material,
                  labor: trade.labor,
                  fontScale: fontScale,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: trade.lines.length,
                    separatorBuilder:
                        (BuildContext context, int index) =>
                            const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (BuildContext context, int index) {
                      return ColoredBox(
                        color: _rowTone(index),
                        child: _EstimateLineTile(
                          line: trade.lines[index],
                          fontScale: fontScale,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
  );
}

/// 견적서를 공종 단위로 나눠 보는 화면. 세부 항목은 아래 목록에서 스크롤한다.
class EstimateReaderScreen extends StatefulWidget {
  const EstimateReaderScreen({
    super.key,
    required this.quote,
    this.initialTrade = '',
  });

  final WorkQuote quote;
  final String initialTrade;

  @override
  State<EstimateReaderScreen> createState() => _EstimateReaderScreenState();
}

class _EstimateReaderScreenState extends State<EstimateReaderScreen> {
  late int _index;
  late bool _overview;
  final ScrollController _chips = ScrollController();
  final List<GlobalKey> _chipKeys = [];

  @override
  void initState() {
    super.initState();
    final List<EstimateTrade> trades = widget.quote.sheet.trades;
    final int found = trades.indexWhere(
      (EstimateTrade trade) => trade.name == widget.initialTrade,
    );
    _overview = found < 0;
    _index = found < 0 ? 0 : found;
    _chipKeys.addAll(
      List<GlobalKey>.generate(trades.length + 1, (_) => GlobalKey()),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revealChip(_overview ? 0 : _index + 1),
    );
  }

  @override
  void dispose() {
    _chips.dispose();
    super.dispose();
  }

  void _revealChip(int index) {
    if (index < 0 || index >= _chipKeys.length) return;
    final BuildContext? target = _chipKeys[index].currentContext;
    if (target == null || !target.mounted) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.5,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final WorkQuote quote = widget.quote;
    final EstimateSheet sheet = quote.sheet;
    final ProjectDocument? file = quote.documentOf(
      ProjectDocumentKind.estimate,
    );
    final EstimateTrade? trade =
        _overview || sheet.trades.isEmpty ? null : sheet.trades[_index];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('견적서'),
        actions: [
          if (file != null && file.fileName.isNotEmpty)
            TextButton(
              onPressed:
                  () => showOriginalFileSheet(context, fileName: file.fileName),
              child: Text(
                '원본',
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, 8, padding.right, 0),
            child: _EstimateCover(quote: quote, fontScale: fontScale),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36 * fontScale,
            child: ListView.separated(
              controller: _chips,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding.left),
              itemCount: sheet.trades.length + 1,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 6);
              },
              itemBuilder: (BuildContext context, int index) {
                final bool overviewChip = index == 0;
                final bool selected =
                    overviewChip
                        ? _overview
                        : index - 1 == _index && !_overview;
                return _TradeChip(
                  key: _chipKeys[index],
                  label: overviewChip ? '전체' : sheet.trades[index - 1].name,
                  selected: selected,
                  fontScale: fontScale,
                  onTap: () {
                    setState(() {
                      if (overviewChip) {
                        _overview = true;
                      } else {
                        _overview = false;
                        _index = index - 1;
                      }
                    });
                    _revealChip(index);
                  },
                );
              },
            ),
          ),
          if (trade != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding.left),
              child: _TradeHeading(trade: trade, fontScale: fontScale),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child:
                _overview
                    ? _TradeTotals(
                      trades: sheet.trades,
                      fontScale: fontScale,
                      padding: padding,
                      onOpen: (int index) {
                        setState(() {
                          _overview = false;
                          _index = index;
                        });
                        _revealChip(index + 1);
                      },
                    )
                    : trade == null
                    ? const SizedBox.shrink()
                    : _TradeLines(
                      trade: trade,
                      fontScale: fontScale,
                      padding: padding,
                    ),
          ),
        ],
      ),
    );
  }
}

class _EstimateCover extends StatelessWidget {
  const _EstimateCover({required this.quote, required this.fontScale});

  final WorkQuote quote;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final EstimateSheet sheet = quote.sheet;
    final int percent = (sheet.vatRate * 100).round();
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quote.documentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  quote.statusLabel,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xB3FFFFFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            QuoteMoneySummary(
              material: sheet.material,
              labor: sheet.labor,
              fontScale: fontScale,
              onDark: true,
              vatPercent: percent,
              vatIncluded: sheet.grandTotal,
            ),
            if (quote.company.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                quote.company,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xD9FFFFFF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TradeChip extends StatelessWidget {
  const _TradeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TradeHeading extends StatelessWidget {
  const _TradeHeading({required this.trade, required this.fontScale});

  final EstimateTrade trade;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool empty = trade.lines.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          empty ? '항목 없음' : '항목 ${trade.lines.length}개',
          style: TextStyle(
            fontSize: 13 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        if (trade.total > 0) ...[
          const SizedBox(height: 8),
          QuoteMoneySummary(
            material: trade.material,
            labor: trade.labor,
            fontScale: fontScale,
          ),
        ],
      ],
    );
  }
}

class _TradeTotals extends StatelessWidget {
  const _TradeTotals({
    required this.trades,
    required this.fontScale,
    required this.padding,
    required this.onOpen,
  });

  final List<EstimateTrade> trades;
  final double fontScale;
  final EdgeInsets padding;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        4,
        padding.right,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: trades.length,
      separatorBuilder:
          (BuildContext context, int index) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final EstimateTrade trade = trades[index];
        final bool empty = trade.total == 0;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _rowTone(index),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: const Border.fromBorderSide(
              BorderSide(color: AppColors.border),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onOpen(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trade.name,
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.w700,
                              color:
                                  empty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    QuoteMoneySummary(
                      material: trade.material,
                      labor: trade.labor,
                      fontScale: fontScale,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TradeLines extends StatelessWidget {
  const _TradeLines({
    required this.trade,
    required this.fontScale,
    required this.padding,
  });

  final EstimateTrade trade;
  final double fontScale;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (trade.lines.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(padding.left, 24, padding.right, 0),
        child: Text(
          '이번 견적에 넣은 항목이 없어요.',
          style: TextStyle(
            fontSize: 15 * fontScale,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      key: ValueKey<String>(trade.name),
      padding: EdgeInsets.fromLTRB(
        padding.left,
        8,
        padding.right,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: trade.lines.length,
      separatorBuilder:
          (BuildContext context, int index) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _rowTone(index),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: const Border.fromBorderSide(
              BorderSide(color: AppColors.border),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _EstimateLineTile(
              line: trade.lines[index],
              fontScale: fontScale,
            ),
          ),
        );
      },
    );
  }
}

class _EstimateLineTile extends StatefulWidget {
  const _EstimateLineTile({required this.line, required this.fontScale});

  final EstimateLine line;
  final double fontScale;

  @override
  State<_EstimateLineTile> createState() => _EstimateLineTileState();
}

class _EstimateLineTileState extends State<_EstimateLineTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final EstimateLine line = widget.line;
    final double fontScale = widget.fontScale;
    final bool canOpen = line.materials.isNotEmpty;
    final String meta = canOpen ? '' : _lineMeta(line);
    final int? material = line.materialTotal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.name,
            style: TextStyle(
              fontSize: 15 * fontScale,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              meta,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (material != null || canOpen) ...[
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canOpen ? () => setState(() => _open = !_open) : null,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 16 * fontScale,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '재료비',
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (material != null)
                      Text(
                        '${formatWon(material)}원',
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    if (canOpen) ...[
                      const SizedBox(width: 2),
                      Icon(
                        _open ? Icons.expand_less : Icons.expand_more,
                        size: 20 * fontScale,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child:
                _open
                    ? _MaterialList(
                      materials: line.materials,
                      fontScale: fontScale,
                    )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _MaterialList extends StatelessWidget {
  const _MaterialList({required this.materials, required this.fontScale});

  final List<EstimateMaterial> materials;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 22),
      child: Column(
        children: [
          for (var i = 0; i < materials.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _MaterialRow(item: materials[i], fontScale: fontScale),
          ],
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.item, required this.fontScale});

  final EstimateMaterial item;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String meta = _materialMeta(item);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (item.amount != null) ...[
          const SizedBox(width: 12),
          Text(
            '${formatWon(item.amount!)}원',
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

String _lineMeta(EstimateLine line) {
  final String unit = line.unit.trim();
  return [
    if (line.spec.trim().isNotEmpty) line.spec.trim(),
    if (unit.isNotEmpty && unit != '식') unit,
    if (line.quantity.trim().isNotEmpty) line.quantity.trim(),
  ].join(' · ');
}

String _materialMeta(EstimateMaterial item) {
  final String quantity = item.quantity.trim();
  final String unit = item.unit.trim();
  final String count =
      quantity.isEmpty
          ? (unit.isEmpty || unit == '식' ? '' : unit)
          : (unit.isEmpty || unit == '식' ? quantity : '$quantity$unit');
  return [
    if (item.spec.trim().isNotEmpty) item.spec.trim(),
    if (count.isNotEmpty) count,
  ].join(' · ');
}
