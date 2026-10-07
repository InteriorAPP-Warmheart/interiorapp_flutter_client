import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/core/theme/app_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class InteriorPrepScreen extends StatelessWidget {
  const InteriorPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final prep = SpaceCatalog.prep;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(title: const Text('사전준비')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '상담 전에 공간을 골라 두세요',
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: const Color(0xFF6E6E6E),
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECECEC)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '진행 중인 사전준비',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8C7358),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prep.activePlaceName,
                    style: TextStyle(
                      fontSize: 20 * fontScale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prep.activeSummary,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      color: const Color(0xFF6E6E6E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '후보 현장 ${prep.candidates.length}/2',
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final String place in prep.candidates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFECECEC)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.place_outlined, color: Color(0xFF8C7358)),
                  title: Text(
                    place,
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
