import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';

/// 계약서, 결제 요율, 에스크로 안내를 보고 계약요청하는 화면.
class ContractReviewScreen extends StatefulWidget {
  const ContractReviewScreen({
    super.key,
    required this.quote,
    this.alreadySigned = false,
  });

  final WorkQuote quote;
  final bool alreadySigned;

  @override
  State<ContractReviewScreen> createState() => _ContractReviewScreenState();
}

class _ContractReviewScreenState extends State<ContractReviewScreen> {
  late bool _signed = widget.alreadySigned;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);
    final EstimateSheet sheet = widget.quote.sheet;
    final int percent = (sheet.vatRate * 100).round();
    final List<_PayRound> rounds = _payRounds(sheet.grandTotal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('계약')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(padding.left, 8, padding.right, 16),
              children: [
                Text(
                  _signed ? '계약요청을 보냈어요' : '이제 계약이 남았어요',
                  style: TextStyle(
                    fontSize: 26 * fontScale,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _signed
                      ? '담당자가 방문해서 계약을 진행해요.'
                      : '시공과 금액을 확인했어요. 계약서와 결제 내용을 보고 계약요청해요.',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _VisitNotice(fontScale: fontScale),
                const SizedBox(height: 8),
                _Block(
                  title: '계약서',
                  fontScale: fontScale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.quote.documentTitle,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.quote.company,
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MoneyLine(
                        label: '공사비',
                        value: '${formatWon(sheet.subtotal)}원',
                        fontScale: fontScale,
                      ),
                      _MoneyLine(
                        label: '부가세 $percent% 포함',
                        value: '${formatWon(sheet.grandTotal)}원',
                        fontScale: fontScale,
                        strong: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sheet.trades
                            .map((EstimateTrade trade) => trade.name)
                            .join(' · '),
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _Block(
                  title: '에스크로',
                  fontScale: fontScale,
                  action: _EscrowLink(
                    fontScale: fontScale,
                    onPressed: () => _openEscrow(context),
                  ),
                  child: _EscrowDiagram(
                    total: sheet.grandTotal,
                    fontScale: fontScale,
                  ),
                ),
                const SizedBox(height: 8),
                _Block(
                  title: '결제 요율',
                  fontScale: fontScale,
                  child: _RateBoard(rounds: rounds, fontScale: fontScale),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              8,
              padding.right,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AppButton(
              label: _signed ? '계약요청했어요' : '계약요청',
              onPressed: _signed ? null : _sign,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sign() async {
    final bool? signed = await showAppDialog<bool>(
      context: context,
      title: '이 내용으로 계약요청할까요?',
      message:
          '계약서, 결제 요율, 에스크로 안내를 확인하셨나요?\n확인하셨다면 계약요청을 눌러주세요. 담당자가 방문해서 계약해요.',
      actions: (BuildContext dialogContext) {
        return [
          AppButton(
            label: '계약요청',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          AppButton(
            label: '다시 볼게요',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ];
      },
    );
    if (signed != true || !mounted) return;
    setState(() => _signed = true);
    Navigator.of(context).pop(true);
  }

  void _openEscrow(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    showAppBottomSheet<void>(
      context: context,
      title: '에스크로란?',
      size: AppBottomSheetSize.compact,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          for (final String line in _escrowLines) ...[
            Text(
              line,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

const List<String> _escrowLines = [
  '에스크로는 거래 금액을 제3자가 맡아 두는 방식이에요.',
  '제3자는 은행이에요. 공사비를 우리가 직접 받지 않아요.',
  '공사금액 전체를 에스크로 계좌에 맡기면, 은행이 그 돈을 보관해요.',
  '결제일이 되면 약속한 비율만큼 자동으로 빠져나가요.',
  '결제일 전에는 돈이 계좌에 그대로 남아요. 우리가 들고 있지 않아서 안전해요.',
];

class _PayRound {
  const _PayRound({
    required this.order,
    required this.name,
    required this.when,
    required this.percent,
    required this.amount,
  });

  final String order;
  final String name;
  final String when;
  final int percent;
  final int amount;
}

List<_PayRound> _payRounds(int total) {
  const List<String> names = ['선납금', '중도금', '잔금'];
  const List<String> whens = ['계약할 때', '공사 중간에', '준공 확인할 때'];
  const List<int> percents = [40, 30, 30];
  return [
    for (var i = 0; i < names.length; i++)
      _PayRound(
        order: '${i + 1}차',
        name: names[i],
        when: whens[i],
        percent: percents[i],
        amount: (total * percents[i] / 100).round(),
      ),
  ];
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.fontScale,
    required this.child,
    this.action,
  });

  final String title;
  final double fontScale;
  final Widget child;
  final Widget? action;

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
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _EscrowLink extends StatelessWidget {
  const _EscrowLink({required this.fontScale, required this.onPressed});

  final double fontScale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        '에스크로란?',
        style: TextStyle(
          fontSize: 13 * fontScale,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accent,
        ),
      ),
    );
  }
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: (strong ? 16 : 14) * fontScale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitNotice extends StatelessWidget {
  const _VisitNotice({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.person_pin_circle_outlined,
              color: AppColors.white,
              size: 28 * fontScale,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '담당자가 방문해서 계약해요',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '온라인만으로는 계약이 되지 않아요. 계약요청을 하면 담당자가 가서 계약해요.',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xE6FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscrowDiagram extends StatelessWidget {
  const _EscrowDiagram({required this.total, required this.fontScale});

  final int total;
  final double fontScale;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double box = (width - _gap) / 2;
        final double leftX = box / 2;
        final double rightX = box + _gap + box / 2;
        const double side = 22;
        final double escrowLeft = (leftX - side).clamp(0.0, width);
        final double escrowRight = (rightX + side).clamp(0.0, width);
        return SizedBox(
          width: width,
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: escrowRight - escrowLeft,
                  child: _UmlNode(
                    title: '에스크로',
                    note: '제3자 은행이 보관해요',
                    foot: '${formatWon(total)}원',
                    filled: true,
                    fontScale: fontScale,
                  ),
                ),
              ),
              SizedBox(
                height: 64,
                width: width,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -2,
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        painter: _EscrowArrowPainter(
                          leftX: leftX,
                          rightX: rightX,
                        ),
                      ),
                    ),
                    Positioned(
                      left: leftX + 8,
                      top: 0,
                      bottom: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '맡김',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: width - rightX + 8,
                      top: 0,
                      bottom: 0,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '결제일에 받음',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _UmlNode(
                        title: '고객',
                        note: '공사비 전체를 맡겨요',
                        fontScale: fontScale,
                      ),
                    ),
                    const SizedBox(width: _gap),
                    Expanded(
                      child: _UmlNode(
                        title: '와플',
                        note: '결제일에 받아요',
                        fontScale: fontScale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EscrowArrowPainter extends CustomPainter {
  const _EscrowArrowPainter({required this.leftX, required this.rightX});

  final double leftX;
  final double rightX;

  @override
  void paint(Canvas canvas, Size size) {
    _draw(canvas, from: Offset(leftX, size.height), to: Offset(leftX, 0));
    _draw(canvas, from: Offset(rightX, 0), to: Offset(rightX, size.height));
  }

  void _draw(Canvas canvas, {required Offset from, required Offset to}) {
    const double head = 9;
    final Offset delta = to - from;
    final double length = delta.distance;
    if (length <= head) return;
    final Offset unit = delta / length;
    final Offset neck = to - unit * head;
    canvas.drawLine(
      from,
      neck,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.butt,
    );
    final Offset side = Offset(-unit.dy, unit.dx) * 5;
    final Path path =
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(neck.dx + side.dx, neck.dy + side.dy)
          ..lineTo(neck.dx - side.dx, neck.dy - side.dy)
          ..close();
    canvas.drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _EscrowArrowPainter oldDelegate) {
    return leftX != oldDelegate.leftX || rightX != oldDelegate.rightX;
  }
}

class _UmlNode extends StatelessWidget {
  const _UmlNode({
    required this.title,
    required this.note,
    required this.fontScale,
    this.foot,
    this.filled = false,
  });

  final String title;
  final String note;
  final double fontScale;
  final String? foot;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = filled ? AppColors.white : AppColors.textPrimary;
    final Color noteColor =
        filled ? const Color(0xD9FFFFFF) : AppColors.textSecondary;
    final String? amount = foot;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: filled ? null : Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              note,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: noteColor,
              ),
            ),
            if (amount != null) ...[
              const SizedBox(height: 8),
              Text(
                amount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateBoard extends StatelessWidget {
  const _RateBoard({required this.rounds, required this.fontScale});

  final List<_PayRound> rounds;
  final double fontScale;

  static const double _gap = 8;
  static const double _minTile = 96;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = rounds.length;
        final double gaps = _gap * (count - 1);
        final double share = (constraints.maxWidth - gaps) / count;
        final List<Widget> tiles = [
          for (var i = 0; i < count; i++)
            _RateTile(index: i, round: rounds[i], fontScale: fontScale),
        ];
        final Widget board =
            share >= _minTile
                ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        if (i > 0) const SizedBox(width: _gap),
                        Expanded(child: tiles[i]),
                      ],
                    ],
                  ),
                )
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        if (i > 0) const SizedBox(width: _gap),
                        SizedBox(width: 128, child: tiles[i]),
                      ],
                    ],
                  ),
                );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            board,
            const SizedBox(height: 8),
            Text(
              '정확한 결제일은 계약 후 상담으로 정해요.',
              style: TextStyle(
                fontSize: 12 * fontScale,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.index,
    required this.round,
    required this.fontScale,
  });

  final int index;
  final _PayRound round;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  round.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EBE4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '${round.percent}%',
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${formatWon(round.amount)}원',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  round.when,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
