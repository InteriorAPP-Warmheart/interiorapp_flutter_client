import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/repository/filter_repo_impl.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/source/filter_api.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/entity/filter_entity.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/repository/filter_repository.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/usecase/filter_usecase.dart';
import 'package:interiorapp_flutter_client/showroom_tab/presentation/vm/filter_vm.dart';

// API -> Repository -> UseCase providers

// 필터 상태 관리 VM Provider
final filterProvider = NotifierProvider<FilterVm, FilterState>(
  FilterVm.new,
);

final filteredShowroomApiProvider = Provider((ref) => FilteredShowroomApi());

final filteredShowroomRepositoryProvider = Provider<FilteredShowroomRepository>((ref) {
return FilteredShowroomImpl(ref.read(filteredShowroomApiProvider));
});


final filteredShowroomUseCaseProvider = Provider((ref) {
return FilteredShowroomUseCase(ref.read(filteredShowroomRepositoryProvider));
});


// 필터링된 쇼룸 목록 Provider
final filteredShowroomListProvider = 
    AsyncNotifierProvider<FilteredShowroomNotifier, List<FilteredShowroomModel>>(
  FilteredShowroomNotifier.new,
);


// 필터 카테고리 목록 Provider (정적 데이터)
final filterCategoriesProvider = Provider<List<String>>((ref) {
  return ['스타일', '공간 형태', '예산', '톤앤매너', '소재'];
});

// 현재 선택된 카테고리의 필터 아이템들을 반환하는 Provider
final currentCategoryItemsProvider = Provider<List<FilterItem>>((ref) {
  final filterState = ref.watch(filterProvider);
  return filterState.categoryItems[filterState.selectedCategory] ?? [];
});


// 선택된 필터가 있는지 확인하는 Provider
final hasSelectedFiltersProvider = Provider<bool>((ref) {
  final filterState = ref.watch(filterProvider);
  return filterState.selectedFilters.isNotEmpty;
});

