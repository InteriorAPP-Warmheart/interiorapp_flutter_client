import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

/// 상담이 접수된 직후. 내 공간이 만들어지고, 지금 상태만 보여 준다.
class PrepConsultScreen extends StatefulWidget {
  const PrepConsultScreen({super.key, required this.record});

  final PrepRecord record;

  @override
  State<PrepConsultScreen> createState() => _PrepConsultScreenState();
}

class _PrepConsultScreenState extends State<PrepConsultScreen> {
  SpaceProject? _project;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _project = SpaceBoard.instance.receiveConsult(widget.record);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(title: Text(widget.record.placeName)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding.left, subGap, padding.right, subGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ConsultReceivedBody(record: widget.record)),
              const SizedBox(height: 12),
              AppButton(
                label: '내 공간 보기',
                onPressed: _project == null
                    ? null
                    : () => context.pushReplacement(SpaceRoutes.detail(_project!.id)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsultReceivedBody extends StatelessWidget {
  const ConsultReceivedBody({super.key, required this.record});

  final PrepRecord record;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final String address = record.detailAddress.isEmpty
        ? record.address
        : '${record.address} ${record.detailAddress}';
    final String work = record.workScope == PrepLabels.partialWork && record.workPlace.isNotEmpty
        ? '${record.workScope} · ${record.workPlace}'
        : record.workScope;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상담이 접수됐어요',
          style: TextStyle(fontSize: 26 * fontScale, fontWeight: FontWeight.w700, height: 1.25),
        ),
        const SizedBox(height: 8),
        Text(
          record.placeName,
          style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: sectionGap),
        _SummaryCard(
          fontScale: fontScale,
          rows: [
            _SummaryRow('업종', _filled(record.industry)),
            _SummaryRow('주소', _filled(address)),
            _SummaryRow('공사 형태', _filled(work)),
            _SummaryRow('예산', _filled(record.budget)),
            _SummaryRow('일정', _filled(record.period)),
          ],
        ),
        SizedBox(height: sectionGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '다음',
                style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFFFFFFFF)),
              ),
              const SizedBox(height: 6),
              Text(
                '담당자가 내용을 확인하고 전화로 연락해요',
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '견적과 방문 일정은 아직 정하지 않아요.',
                style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _filled(String value) => value.trim().isEmpty ? '미입력' : value.trim();

class _SummaryRow {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.fontScale, required this.rows});

  final double fontScale;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE4E4E4)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      rows[i].label,
                      style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      style: TextStyle(fontSize: 15 * fontScale, height: 1.4, fontWeight: FontWeight.w600),
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
