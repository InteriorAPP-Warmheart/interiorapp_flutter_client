import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/original_file_sheet.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 제안서 PDF를 장 단위로 넘기며 보는 화면.
class ProposalReaderScreen extends StatefulWidget {
  const ProposalReaderScreen({super.key, required this.quote});

  final WorkQuote quote;

  @override
  State<ProposalReaderScreen> createState() => _ProposalReaderScreenState();
}

class _ProposalReaderScreenState extends State<ProposalReaderScreen> {
  final PageController _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<ProposalPage> pages = widget.quote.proposalPages;
    final ProjectDocument? file = widget.quote.documentOf(
      ProjectDocumentKind.proposal,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('제안서'),
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
      body:
          pages.isEmpty
              ? Center(
                child: Text(
                  '제안서 장이 아직 없어요',
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: pages.length,
                      onPageChanged:
                          (int index) => setState(() => _index = index),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: _ProposalSheet(
                            page: pages[index],
                            index: index,
                            count: pages.length,
                            fontScale: fontScale,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_index + 1} / ${pages.length}',
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < pages.length; i++) ...[
                              if (i > 0) const SizedBox(width: 5),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: i == _index ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      i == _index
                                          ? AppColors.primary
                                          : AppColors.border,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class _ProposalSheet extends StatelessWidget {
  const _ProposalSheet({
    required this.page,
    required this.index,
    required this.count,
    required this.fontScale,
  });

  final ProposalPage page;
  final int index;
  final int count;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String number = (index + 1).toString().padLeft(2, '0');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              page.title,
              style: TextStyle(
                fontSize: 28 * fontScale,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (page.caption.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                page.caption,
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.architecture_outlined,
                      size: 28,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이 장은 도면이에요',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count장 중 ${index + 1}장',
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
