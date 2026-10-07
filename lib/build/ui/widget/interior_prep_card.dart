import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 목록 맨 아래의 사전준비 진입. 정식 현장보다 작게 둔다.
class InteriorPrepEntry extends StatelessWidget {
  const InteriorPrepEntry({super.key, required this.prep, required this.onTap});

  final InteriorPrep prep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Material(
      color: const Color(0xFFF6F3EE),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF8C7358)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사전준비 · ${prep.activePlaceName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '후보 현장 ${prep.candidates.length}곳',
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        color: const Color(0xFF8C7358),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8C7358)),
            ],
          ),
        ),
      ),
    );
  }
}
