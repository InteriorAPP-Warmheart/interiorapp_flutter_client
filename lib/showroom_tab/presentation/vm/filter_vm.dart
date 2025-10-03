import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/entity/filter_entity.dart';
import 'package:interiorapp_flutter_client/showroom_tab/presentation/provider/filter_provider.dart';

class FilterVm extends Notifier<FilterState> {
  @override
  FilterState build() {
    final categoryItems = <String, List<FilterItem>>{
      '스타일': [
        FilterItem(id: 'minimal', name: '미니멀'),
        FilterItem(id: 'modern', name: '모던'),
        FilterItem(id: 'northern', name: '북유럽'),
        FilterItem(id: 'natural', name: '내추럴'),
        FilterItem(id: 'industrial', name: '인더스트리얼'),
        FilterItem(id: 'classic', name: '클래식'),
        FilterItem(id: 'vintage', name: '빈티지'),
        FilterItem(id: 'korean', name: '한옥스타일'),
        FilterItem(id: 'hotel', name: '호텔스타일'),
        FilterItem(id: 'artwall', name: '아트월'),
        FilterItem(id: 'colorpoint', name: '컬러포인트'),
      ],

      // 공간 형태 - 상위
      '공간 형태': [],

      // 주거 공간 하위 항목
      '주거_공간': [
        FilterItem(id: 'apartment', name: '아파트', parentId: 'residential'),
        FilterItem(id: 'villa', name: '빌라(투룸/쓰리룸)', parentId: 'residential'),
        FilterItem(id: 'studio', name: '단독주택', parentId: 'residential'),
        FilterItem(id: 'officetel', name: '오피스텔', parentId: 'residential'),
        FilterItem(id: 'one_room', name: '원룸', parentId: 'residential'),
        FilterItem(id: 'shared_house',name: '고시원/셰어하우스',parentId: 'residential',),
      ],

      // 상업 공간 하위 항목
      '상업_공간': [
        FilterItem(id: 'store', name: '상가/매장', parentId: 'commercial'),
        FilterItem(id: 'restaurant', name: '음식점/카페', parentId: 'commercial'),
        FilterItem(id: 'office', name: '사무실/오피스', parentId: 'commercial'),
        FilterItem(id: 'other_commercial',name: '기타 상업시설',parentId: 'commercial',),
      ],

      // 주거 공간 세부 항목
      '주거_세부': [
        FilterItem(id: 'living_room', name: '거실', parentId: 'residential'),
        FilterItem(id: 'bedroom', name: '주방', parentId: 'residential'),
        FilterItem(id: 'kitchen', name: '욕실/화장실', parentId: 'residential'),
        FilterItem(id: 'bathroom', name: '침실', parentId: 'residential'),
        FilterItem(id: 'kids_room', name: '자녀방', parentId: 'residential'),
        FilterItem(id: 'dress_room', name: '드레스룸', parentId: 'residential'),
        FilterItem(id: 'multi_room', name: '다용도실', parentId: 'residential'),
        FilterItem(id: 'entrance', name: '현관', parentId: 'residential'),
        FilterItem(id: 'veranda', name: '베란다/발코니', parentId: 'residential'),
        FilterItem(id: 'interior_garden',name: '실내복도',parentId: 'residential',),
        FilterItem(id: 'study', name: '서재/작업실', parentId: 'residential'),
        FilterItem(id: 'storage', name: '창고/수납공간', parentId: 'residential'),
        FilterItem(id: 'attic', name: '마당', parentId: 'residential'),
        FilterItem(id: 'rooftop', name: '천장/루팅', parentId: 'residential'),
      ],

      // 상업 공간 세부 항목
      '상업_세부': [
        FilterItem(id: 'store_hall', name: '매장 홀', parentId: 'commercial'),
        FilterItem(id: 'counter', name: '카운터/리셉션', parentId: 'commercial'),
        FilterItem(id: 'work_space', name: '주방/작업공간', parentId: 'commercial'),
        FilterItem(id: 'meeting_room', name: '화장실', parentId: 'commercial'),
        FilterItem(id: 'conference', name: '회의실', parentId: 'commercial'),
        FilterItem(id: 'lounge', name: '휴게실', parentId: 'commercial'),
        FilterItem(id: 'open_lounge', name: '오픈라운지', parentId: 'commercial'),
        FilterItem(id: 'corridor', name: '복도/출입구', parentId: 'commercial'),
        FilterItem(id: 'warehouse', name: '창고', parentId: 'commercial'),
        FilterItem(id: 'garden', name: '진열대', parentId: 'commercial'),
        FilterItem(id: 'terrace', name: '테라스', parentId: 'commercial'),
        FilterItem(id: 'exterior', name: '외부존', parentId: 'commercial'),
      ],

      '예산': [], // 슬라이더로 처리 예정

      '톤앤매너': [
        FilterItem(id: 'red', name: '레드'),
        FilterItem(id: 'orange', name: '오렌지'),
        FilterItem(id: 'yellow', name: '옐로우'),
        FilterItem(id: 'green', name: '그린'),
        FilterItem(id: 'blue', name: '블루'),
        FilterItem(id: 'purple', name: '퍼플'),
        FilterItem(id: 'pink', name: '핑크'),
        FilterItem(id: 'brown', name: '브라운'),
        FilterItem(id: 'white', name: '화이트'),
        FilterItem(id: 'gray', name: '그레이'),
        FilterItem(id: 'black', name: '블랙'),
      ],

      '소재': [
        FilterItem(id: 'steel_floor', name: '강마루'),
        FilterItem(id: 'tile', name: '타일'),
        FilterItem(id: 'wallpaper', name: '벽지'),
        FilterItem(id: 'paint', name: '도장'),
        FilterItem(id: 'lighting', name: '조명'),
        FilterItem(id: 'partition', name: '파티션'),
        FilterItem(id: 'glass', name: '유리'),
        FilterItem(id: 'window', name: '창호'),
        FilterItem(id: 'ceiling', name: '천장'),
        FilterItem(id: 'wood', name: '우드'),
      ],
    };

    return FilterState(
      categoryItems: categoryItems,
      selectedCategory: '스타일',
      selectedFilters: [],
      selectedSpaceType: null,
      budgetRange: const RangeValues(0, 0),
    );
  }

  // 카테고리 선택
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  // 공간 형태 토글 (주거/상업 선택)
  void toggleSpaceType(String spaceTypeId) {
    if (state.selectedSpaceType == spaceTypeId) {
      // 이미 선택된 것을 다시 누르면 선택 해제
      state = state.copyWith(selectedSpaceType: null);
    } else {
      state = state.copyWith(selectedSpaceType: spaceTypeId);
    }
  }

  // 필터 토글
  void toggleFilter(String filterId) {
    final currentCategory = state.selectedCategory;

    // 공간 형태의 하위 카테고리들 찾기
    String? actualCategory = currentCategory;
    if (currentCategory == '공간 형태') {
      // 주거/상업 하위 항목에서 찾기
      if (state.selectedSpaceType == 'residential') {
        // 주거_공간과 주거_세부에서 찾기
        final spaceItem = (state.categoryItems['주거_공간'] ?? []).where(
          (item) => item.id == filterId,
        );
        final detailItem = (state.categoryItems['주거_세부'] ?? []).where(
          (item) => item.id == filterId,
        );

        if (spaceItem.isNotEmpty) {
          actualCategory = '주거_공간';
        } else if (detailItem.isNotEmpty) {
          actualCategory = '주거_세부';
        }
      } else if (state.selectedSpaceType == 'commercial') {
        // 상업_공간과 상업_세부에서 찾기
        final spaceItem = (state.categoryItems['상업_공간'] ?? []).where(
          (item) => item.id == filterId,
        );
        final detailItem = (state.categoryItems['상업_세부'] ?? []).where(
          (item) => item.id == filterId,
        );

        if (spaceItem.isNotEmpty) {
          actualCategory = '상업_공간';
        } else if (detailItem.isNotEmpty) {
          actualCategory = '상업_세부';
        }
      }
    }

    final categoryItems = state.categoryItems[actualCategory] ?? [];
    final itemIndex = categoryItems.indexWhere((item) => item.id == filterId);

    if (itemIndex == -1) return;

    final item = categoryItems[itemIndex];

    final updatedItems = categoryItems.map((item) {
      if (item.id == filterId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();

    final updatedCategories = Map<String, List<FilterItem>>.from(
      state.categoryItems,
    );
    updatedCategories[actualCategory] = updatedItems;

    // 선택된 필터 목록 업데이트
    List<SelectedFilter> selectedFilters = List.from(state.selectedFilters);
    final existingIndex = selectedFilters.indexWhere((f) => f.id == filterId);

    if (existingIndex != -1) {
      selectedFilters.removeAt(existingIndex);
    } else {
      selectedFilters.add(
        SelectedFilter(
          id: filterId,
          name: item.name,
          category: _getCategoryDisplayName(actualCategory),
        ),
      );
    }

    state = state.copyWith(
      categoryItems: updatedCategories,
      selectedFilters: selectedFilters,
    );
  }

  // 예산 범위 변경
  void updateBudgetRange(RangeValues range) {
    List<SelectedFilter> selectedFilters = List.from(state.selectedFilters);
    
    // 기존 예산 필터 제거
    selectedFilters.removeWhere((filter) => filter.category == '예산');
    
    // 새로운 예산 범위가 0이 아니면 추가
    if (range.start != 0 || range.end != 0) {
      selectedFilters.add(
        SelectedFilter(
          id: 'budget',
          name: _formatBudgetRange(range),
          category: '예산',
        ),
      );
    }
    
    state = state.copyWith(
      budgetRange: range,
      selectedFilters: selectedFilters,
    );
  }
  
  // 예산 범위 포맷팅
  String _formatBudgetRange(RangeValues range) {
    if (range.start == 0 && range.end == 0) {
      return '0원';
    }
    return '${_formatCurrency(range.start)} ~ ${_formatCurrency(range.end)}';
  }
  
  // 통화 포맷팅 함수
  String _formatCurrency(double value) {
    if (value == 0) return '0원';

    final intValue = value.round();
    final eok = intValue ~/ 100000000;
    final remainder = intValue % 100000000;
    final manWon = remainder ~/ 10000;

    List<String> parts = [];

    if (eok > 0) {
      parts.add('$eok억');
    }

    if (manWon > 0) {
      final manWonStr = manWon.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      parts.add('$manWonStr만원');
    }

    if (parts.isEmpty) return '0원';

    return parts.join(' ');
  }

  // 필터 초기화
  void resetFilters() {
    final resetCategories = state.categoryItems.map((key, items) {
      return MapEntry(
        key,
        items.map((item) => item.copyWith(isSelected: false)).toList(),
      );
    });

    state = state.copyWith(
      categoryItems: resetCategories,
      selectedFilters: [],
      clearSpaceType: true,
      budgetRange: const RangeValues(0, 0),
    );
  }

  // 선택된 필터 제거
 void removeSelectedFilter(String filterId) {
  // selectedFilters에서 직접 제거
  final updatedSelectedFilters = state.selectedFilters
      .where((filter) => filter.id != filterId)
      .toList();

  // 모든 카테고리를 순회하면서 해당 필터 항목의 isSelected를 false로 변경
  final updatedCategories = Map<String, List<FilterItem>>.from(
    state.categoryItems,
  );

  for (var key in updatedCategories.keys) {
    updatedCategories[key] = updatedCategories[key]!.map((item) {
      if (item.id == filterId) {
        return item.copyWith(isSelected: false);
      }
      return item;
    }).toList();
  }

  // 예산 필터인 경우 budgetRange도 초기화
  RangeValues newBudgetRange = state.budgetRange;
  if (filterId == 'budget') {
    newBudgetRange = const RangeValues(0, 0);
  }

  state = state.copyWith(
    categoryItems: updatedCategories,
    selectedFilters: updatedSelectedFilters,
    budgetRange: newBudgetRange,
  );
}
  // 카테고리 표시 이름 가져오기
  String _getCategoryDisplayName(String category) {
    if (category.startsWith('주거_')) return '공간 형태';
    if (category.startsWith('상업_')) return '공간 형태';
    return category;
  }




}

  //데이터 가져오기 
class FilteredShowroomNotifier extends AsyncNotifier<List<FilteredShowroomModel>> {
  @override
  Future<List<FilteredShowroomModel>> build() async {
    // 초기에는 빈 리스트 반환
    return [];
  }

  // 필터링 실행
  Future<void> fetchFiltered() async {
    // 로딩 상태로 변경
    state = const AsyncValue.loading();
    
    try {
      final filterState = ref.read(filterProvider);
      final useCase = ref.read(filteredShowroomUseCaseProvider);
      
      // 필터가 없으면 빈 리스트
      if (filterState.selectedFilters.isEmpty && 
          (filterState.budgetRange.start == 0 && filterState.budgetRange.end == 0)) {
        state = const AsyncValue.data([]);
        return;
      }
      
      // 카테고리별 필터 추출
      final styles = filterState.selectedFilters
          .where((f) => f.category == '스타일')
          .map((f) => f.id)
          .toList();
      
      final spaceTypes = filterState.selectedFilters
          .where((f) => f.category == '공간 형태')
          .map((f) => f.id)
          .toList();
      
      final tones = filterState.selectedFilters
          .where((f) => f.category == '톤앤매너')
          .map((f) => f.id)
          .toList();
      
      final materials = filterState.selectedFilters
          .where((f) => f.category == '소재')
          .map((f) => f.id)
          .toList();

      // 예산 필터
      double? minBudget;
      double? maxBudget;
      
      if (filterState.budgetRange.start > 0 || filterState.budgetRange.end > 0) {
        minBudget = filterState.budgetRange.start;
        maxBudget = filterState.budgetRange.end;
      }

      // API 호출
      final result = await useCase.getFilteredShowrooms(
        styles: styles.isEmpty ? null : styles,
        spaceTypes: spaceTypes.isEmpty ? null : spaceTypes,
        minBudget: minBudget,
        maxBudget: maxBudget,
        tones: tones.isEmpty ? null : tones,
        materials: materials.isEmpty ? null : materials,
      );
      
      // 성공 상태로 변경
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      // 에러 상태로 변경
      state = AsyncValue.error(error, stackTrace);
    }
  }
}