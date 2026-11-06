import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/original_file_sheet.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 계약서를 원본과 글로 정리된 내용으로 보는 화면.
class ContractReaderScreen extends StatelessWidget {
  const ContractReaderScreen({super.key, required this.quote});

  final WorkQuote quote;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final EstimateSheet sheet = quote.sheet;
    final ProjectDocument? file = quote.documentOf(
      ProjectDocumentKind.contract,
    );
    final String fileName =
        file != null && file.fileName.isNotEmpty
            ? file.fileName
            : '${quote.documentTitle} 계약서.pdf';
    final int base = sheet.subtotal;
    const List<(String, String, int)> rounds = [
      ('선납금', '계약할 때', 50),
      ('중도금', '공사 중간에', 40),
      ('잔금', '준공 확인할 때', 10),
    ];
    final List<int> amounts = _splitByPercent(base, <int>[
      for (final round in rounds) round.$3,
    ]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('계약서'),
        actions: [
          TextButton(
            onPressed: () => showOriginalFileSheet(context, fileName: fileName),
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
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          8,
          padding.right,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            quote.documentTitle,
            style: TextStyle(
              fontSize: 22 * fontScale,
              height: 1.3,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quote.company,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _ContractBlock(
            title: '공사 범위',
            fontScale: fontScale,
            child: Text(
              sheet.trades.map((EstimateTrade trade) => trade.name).join('\n'),
              style: _body(fontScale),
            ),
          ),
          const SizedBox(height: 8),
          _ContractBlock(
            title: '금액',
            fontScale: fontScale,
            child: Column(
              children: [
                _MoneyRow(
                  label: '공사비',
                  value: '${formatWon(base)}원',
                  fontScale: fontScale,
                  strong: true,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '부가세 별도',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ContractBlock(
            title: '결제',
            fontScale: fontScale,
            child: Column(
              children: [
                for (var i = 0; i < rounds.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _MoneyRow(
                    label: '${rounds[i].$1}, ${rounds[i].$2}',
                    value: '${rounds[i].$3}%  ${formatWon(amounts[i])}원',
                    fontScale: fontScale,
                  ),
                ],
              ],
            ),
          ),
          if (sheet.conditions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ContractBlock(
              title: '조건',
              fontScale: fontScale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < sheet.conditions.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                      child: Text(
                        '${i + 1}. ${sheet.conditions[i]}',
                        style: _body(fontScale),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle _body(double fontScale) {
  return TextStyle(
    fontSize: 15 * fontScale,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

class _ContractBlock extends StatelessWidget {
  const _ContractBlock({
    required this.title,
    required this.fontScale,
    required this.child,
  });

  final String title;
  final double fontScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    required this.fontScale,
    this.strong = false,
  });

  final String label;
  final String value;
  final double fontScale;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: (strong ? 16 : 15) * fontScale,
      height: 1.35,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
      color: AppColors.textPrimary,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }
}

List<int> _splitByPercent(int total, List<int> percents) {
  final List<int> amounts = <int>[];
  var used = 0;
  for (var i = 0; i < percents.length; i++) {
    if (i == percents.length - 1) {
      amounts.add(total - used);
      break;
    }
    final int amount = (total * percents[i] / 100).round();
    used += amount;
    amounts.add(amount);
  }
  return amounts;
}
