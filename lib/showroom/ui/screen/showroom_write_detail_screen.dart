import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/filter_chip_widget.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/space_type_filter_widget.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_write_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_write_vm.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class ShowroomWriteDetailScreen extends ConsumerWidget {
  const ShowroomWriteDetailScreen({super.key, this.buildId});

  final String? buildId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);

    // 직접 작성 모드 (선택 데이터 없음)
    if (buildId == null || buildId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('쇼룸 글쓰기 (직접 작성)')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ref.watch(showroomNameTextControllerProvider),
                  decoration: const InputDecoration(
                    hintText: '제목을 입력하세요',
                    hintStyle: TextStyle(color: Color(0xFFD6D6D6)),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F1F1)),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: sectionGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '진행 방식',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 버튼 누르면 시공 진행 방식을 드롭다운이나 팝업으로 보여줘서 선택하게끔 해야함
                      },
                      child: Text(
                        '와플 외 시공',
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFAFAFAF),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Color(0xFFF1F1F1)),
                SizedBox(height: sectionGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '시공 기간',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 기간 선택 가능한 캘린더 화면으로 이동
                      },
                      child: Row(
                        children: [
                          Text(
                            '기간 선택',
                            style: TextStyle(
                              fontSize: 15 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: subGap),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFFAFAFAF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: Color(0xFFF1F1F1)),
                SizedBox(height: sectionGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '지역',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 지역 설정 화면으로 이동
                        // 지역 설정 API 호출
                      },
                      child: Row(
                        children: [
                          Text(
                            '지역 설정',
                            style: TextStyle(
                              fontSize: 15 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: subGap),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFFAFAFAF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: Color(0xFFF1F1F1)),
                SizedBox(height: sectionGap),
                Text(
                  '공간 형태',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: subGap),
                SpaceTypeFilterWidget(
                  filterState: ref.watch(showroomWriteFilterProvider),
                  onSpaceTypeToggle: (spaceTypeId) {
                    ref.read(showroomWriteFilterProvider.notifier).toggleSpaceType(spaceTypeId);
                  },
                  onFilterToggle: (filterId) {
                    // toggleFilter는 자동으로 카테고리를 찾아줌
                    ref.read(showroomWriteFilterProvider.notifier).toggleFilter(filterId);
                  },
                  fontSize: 15 * fontScale,
                  buttonHeight: 40,
                  spacing: subGap,
                ),
                SizedBox(height: sectionGap),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '시공 면적',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    TextButton(
                      onPressed: () {
                        AreaConversionViewModel.convertArea(
                          ref.read(areaTextControllerProvider),
                          ref.read(areaUnitProvider),
                          ref.read(areaUnitProvider.notifier),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.change_circle, size: 20),
                          SizedBox(width: subGap),
                          Text(
                            ref.watch(areaUnitProvider) ? 'm²' : '평',
                            style: TextStyle(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: ref.watch(areaTextControllerProvider),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '3.3',
                    hintStyle: TextStyle(color: Color(0xFFD6D6D6)),
                    suffixText: ref.watch(areaUnitProvider) ? '평' : 'm²',
                    suffixStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 14 * fontScale,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFD6D6D6)),
                    ),
                  ),
                ),
                SizedBox(height: sectionGap),
                Text(
                  '총 비용',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: subGap),
                TextField(
                  controller: ref.watch(totalCostTextControllerProvider),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    CostFormattingViewModel.formatCostInput(
                      ref.read(totalCostTextControllerProvider),
                      (unit) {
                        ref.read(costUnitProvider.notifier).setUnit(unit);
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Color(0xFFD6D6D6)),
                    suffixText: '만원',
                    suffixStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 14 * fontScale,
                    ),
                    helperText: ref.watch(costUnitProvider),
                    helperStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12 * fontScale,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFD6D6D6)),
                    ),
                  ),
                ),
                SizedBox(height: sectionGap),
                Text(
                  '스타일',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: subGap),
                _buildStyleFilter(ref, fontScale, subGap),
                SizedBox(height: sectionGap),
                Text(
                  '톤앤매너',
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: subGap),
                _buildToneMannerFilter(ref, fontScale, subGap),
                SizedBox(height: sectionGap),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        () => {
                          // TODO: 빈값 없는지 체크한 뒤 다음 화면으로 이동, 충족되지 않으면 버튼 비활성화 고려
                        },
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sectionGap * 2),
              ],
            ),
          ),
        ),
      );
    }

    // 선택 데이터 기반 모드
    final detailAsync = ref.watch(showroomSelectedBuildProvider(buildId!));

    return detailAsync.when(
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('쇼룸 글쓰기')),
            body: const Center(child: Text('선택한 데이터가 없습니다.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('쇼룸 글쓰기 (선택 데이터)')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail['buildName'] ?? '제목 없음',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail['buildPeriod'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (detail['buildImage'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      detail['buildImage'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 160,
                            width: double.infinity,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image),
                          ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  '선택된 데이터가 미리 채워진 상태입니다.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // TODO: 여기에 실제 작성 폼을 배치하고 detail 데이터를 초기값으로 사용하세요.
              ],
            ),
          ),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(title: const Text('쇼룸 글쓰기')),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('쇼룸 글쓰기')),
            body: Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error')),
          ),
    );
  }

  /// 스타일 필터 위젯 빌드
  Widget _buildStyleFilter(WidgetRef ref, double fontScale, double subGap) {
    final filterState = ref.watch(showroomWriteFilterProvider);
    final styleItems = filterState.categoryItems['스타일'] ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          styleItems.map((item) {
            return FilterChipWidget(
              item: item,
              onTap: () {
                ref
                    .read(showroomWriteFilterProvider.notifier)
                    .toggleFilterWithCategory(item.id, '스타일');
              },
              fontSize: 15 * fontScale,
            );
          }).toList(),
    );
  }

  /// 톤앤매너 필터 위젯 빌드
  Widget _buildToneMannerFilter(
    WidgetRef ref,
    double fontScale,
    double subGap,
  ) {
    final filterState = ref.watch(showroomWriteFilterProvider);
    final toneItems = filterState.categoryItems['톤앤매너'] ?? [];

    final Map<String, Color> colorMap = {
      'red': Colors.red,
      'orange': Colors.orange,
      'yellow': Colors.yellow,
      'green': Colors.green,
      'blue': Colors.blue,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'white': Colors.white,
      'gray': Colors.grey,
      'black': Colors.black,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          toneItems.map((item) {
            final color = colorMap[item.id] ?? Colors.grey;
            return ColorFilterChipWidget(
              item: item,
              color: color,
              onTap: () {
                ref
                    .read(showroomWriteFilterProvider.notifier)
                    .toggleFilterWithCategory(item.id, '톤앤매너');
              },
              fontSize: 15 * fontScale,
            );
          }).toList(),
    );
  }
}
