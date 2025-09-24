import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/recommend_build_provider.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/image_slider_section.dart';
import 'package:intl/intl.dart';

/// 가격 포맷
String _formatKrw(dynamic raw) {
  final String original = raw?.toString() ?? '';
  // 이미 "만원" 또는 "억" 표기 등 포맷된 경우는 그대로 사용
  if (original.contains('만') || original.contains('억')) return original;
  // 숫자만 추출 후 만원 단위로 변환
  final String digits = original.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return original;
  final int value = int.tryParse(digits) ?? 0;
  if (value == 0) return '0원';

  // 억(100,000,000) 단위 처리
  const int eokUnit = 100000000; // 1억
  const int manUnit = 10000; // 1만원

  if (value >= eokUnit) {
    final int eok = value ~/ eokUnit;
    final int remainder = value % eokUnit;
    final int man = remainder ~/ manUnit; // 억 단위 이하를 만원으로
    if (man > 0) {
      return '${NumberFormat('#,##0', 'ko_KR').format(eok)}억 ${NumberFormat('#,##0', 'ko_KR').format(man)}만원';
    }
    return '${NumberFormat('#,##0', 'ko_KR').format(eok)}억';
  }

  // 억 미만은 만원 단위로 표기
  final double man = value / manUnit;
  final bool isInt = man == man.floorToDouble();
  final NumberFormat fmt = NumberFormat(isInt ? '#,##0' : '#,##0.#', 'ko_KR');
  return '${fmt.format(man)}만원';
}

/// 시공기간 포맷
String _formatBuildPeriod(dynamic raw) {
  final String original = raw?.toString() ?? '';
  if (original.isEmpty) return '';

  // 한글 단위 입력 처리: "X년 Y개월", "X개월", "X주", "X일"
  String sK = original.replaceAll(' ', '');
  int? parseIntSafe(String v) => int.tryParse(v);

  if (sK.contains('년')) {
    // 년 단위는 개월로 환산(1년=12개월), 주/일로는 환산하지 않음
    final reg = RegExp(r'^(\d+)년(?:(\d+)개월)?$');
    final m = reg.firstMatch(sK);
    if (m != null) {
      final y = parseIntSafe(m.group(1)!) ?? 0;
      final mm = parseIntSafe(m.group(2) ?? '0') ?? 0;
      final totalMonths = y * 12 + mm;
      // 간결 표기: 가장 큰 단위 하나만, 반올림 없음
      return '$totalMonths개월';
    }
  }
  if (sK.endsWith('개월')) {
    final n = parseIntSafe(sK.replaceAll('개월', '')) ?? 0;
    return n <= 0 ? original : '$n개월';
  }
  if (sK.endsWith('주')) {
    final n = parseIntSafe(sK.replaceAll('주', '')) ?? 0;
    return n <= 0 ? original : '$n주';
  }
  if (sK.endsWith('일')) {
    final n = parseIntSafe(sK.replaceAll('일', '')) ?? 0;
    return n <= 0 ? original : '$n일';
  }

  // 축약 표기/숫자 표기 처리 (y,m,w,d), 단 년(y)은 개월로 환산
  int daysFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    final s = v.toString().trim().toLowerCase();
    final match = RegExp(r'^(\d+)\s*([ymwd])?$').firstMatch(s);
    if (match != null) {
      final n = int.tryParse(match.group(1)!) ?? 0;
      final unit = match.group(2);
      switch (unit) {
        case 'y':
          return n * 12 * 30; // 년→개월→일 근사 환산
        case 'm':
          return n * 30;
        case 'w':
          return n * 7;
        case 'd':
        case null:
          return n;
      }
    }
    final onlyNum = int.tryParse(s) ?? 0;
    return onlyNum;
  }

  final int days = daysFrom(original);
  if (days <= 0) return original;

  // 간결 표기: 한 단위만 표시 + 반올림 (우선순위: 개월 > 주 > 일)
  if (days >= 30) {
    final int monthsRounded = ((days / 30.0).round()).clamp(1, 1000000);
    return '약 $monthsRounded개월';
  }
  if (days >= 7) {
    final int weeksRounded = ((days / 7.0).round()).clamp(1, 1000000);
    return '약 $weeksRounded주';
  }
  return '$days일';
}

/// 프리셋 스타일을 제공하는 슬라이더 헬퍼
class ImageSliderWidget {
  const ImageSliderWidget();

  /// 쇼룸 전용 프리셋 (썸네일 오버레이 + pill 테마명 + 아바타/이름/좋아요)
  Widget showroomInfo({
    required WidgetRef ref,
    double viewportFraction = 0.95,
    double gap = 12.0,
  }) {
    return ImageSliderSection<HotShowroomModel>(
      watchItems: (ref) => AsyncValue.data(ref.watch(hotShowroomSliderVm)),
      viewportFraction: viewportFraction,
      gap: gap,
      onIndexChange: (i) => ref.read(hotShowroomSliderIndexProvider.notifier).changeIndex(i),
      imageBuilder: (context, item) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(item.thumbnailUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 2,
              bottom: 0,
              child: Row(
                children: [
                  Expanded(child: SizedBox()),
                  IconButton(
                    onPressed: () {
                      ref.read(hotShowroomSliderVm.notifier).toggleFavoriteByIndex(item.id);
                    },
                    icon: Icon(
                      item.favoriteStatus ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      infoBuilder: (context, item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(maxWidth: 220, minHeight: 20),
              child: Text(
                item.themeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(item.userProfileUrl),
                  radius: 12,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    item.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12, // 텍스트 높이와 맞춤
                  child: VerticalDivider(
                    width: 10, // 좌우 여백 포함
                    thickness: 1,
                    color: Color(0xFF333333),
                  ),
                ),
                const Text(
                  '좋아요',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
                const SizedBox(width: 2),
                Text(
                  item.likeCount > 999 ? '999+' : item.likeCount.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 추천 시공사례 전용 프리셋
  Widget recommendBuildInfo({
    required WidgetRef ref,
    double viewportFraction = 0.95,
    double gap = 12.0,
    double infoHeight = 56.0,
  }) {
    return ImageSliderSection<RecommendBuildModel>(
      watchItems: (ref) => AsyncValue.data(ref.watch(recommendBuildVm)),
      viewportFraction: viewportFraction,
      gap: gap,
      infoHeight: infoHeight,
      onIndexChange: (i) => ref.read(recommendBuildIndexProvider.notifier).changeIndex(i),
      imageBuilder: (context, item) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(item.thumbnailUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 2,
              bottom: 0,
              child: Row(
                children: [
                  Expanded(child: SizedBox()),
                  IconButton(
                    onPressed: () {
                      ref.read(recommendBuildVm.notifier).toggleFavoriteByIndex(item.id);
                    },
                    icon: Icon(
                      item.favoriteStatus
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      infoBuilder: (context, item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    item.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.star, color: Color(0xFF333333), size: 12),
                const SizedBox(width: 2),
                Text(
                  item.rating.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    item.buildAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12, // 텍스트 높이와 맞춤
                  child: VerticalDivider(
                    width: 10, // 좌우 여백 포함
                    thickness: 1,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  '시공기간 ${_formatBuildPeriod(item.buildPeriod)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(
                  height: 12, // 텍스트 높이와 맞춤
                  child: VerticalDivider(
                    width: 10, // 좌우 여백 포함
                    thickness: 1,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  '가격 약 ${_formatKrw(item.buildCost)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 심플한 케이스 스터디 프리셋 (디자인 변경 용이)
  Widget caseInfo<T>({
    required AsyncValue<List<T>> Function(WidgetRef ref) watchItems,
    required Widget Function(BuildContext, T) image,
    required Widget Function(BuildContext, T) info,
    double viewportFraction = 0.95,
    double gap = 12.0,
  }) {
    return ImageSliderSection<T>(
      watchItems: watchItems,
      viewportFraction: viewportFraction,
      gap: gap,
      imageBuilder: image,
      infoBuilder: info,
    );
  }
}
