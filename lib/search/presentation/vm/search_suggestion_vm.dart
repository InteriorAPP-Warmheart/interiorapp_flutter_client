import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/search_provider.dart';

class SearchSuggestionNotifier extends Notifier<SearchSuggestionState> {
  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  SearchSuggestionState build() {
    return const SearchSuggestionState(
      relatedKeywords: [],
      isLoading: false,
      hasError: false,
    );
  }

  void updateQuery(String query) {
    _currentQuery = query;
    
    // 이전 타이머 취소
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      state = state.copyWith(
        relatedKeywords: [],
        isLoading: false,
        hasError: false,
      );
      return;
    }

    // 로딩 상태로 설정 (즉시)
    state = state.copyWith(isLoading: true);

    // 300ms 후에 실제 API 호출
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchRelatedKeywords(query);
    });
  }

  Future<void> _fetchRelatedKeywords(String query) async {
    try {
      final keywords = await ref.read(searchSuggestionUseCaseProvider)
          .getRelatedKeywords(query);
      
      // 현재 쿼리와 일치하는 경우에만 상태 업데이트
      if (query == _currentQuery) {
        state = state.copyWith(
          relatedKeywords: keywords,
          isLoading: false,
          hasError: false,
        );
      }
    } catch (error) {
      if (query == _currentQuery) {
        state = state.copyWith(
          relatedKeywords: [],
          isLoading: false,
          hasError: true,
        );
      }
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

class SearchSuggestionState {
  final List<SearchSuggestionModel> relatedKeywords;
  final bool isLoading;
  final bool hasError;

  const SearchSuggestionState({
    required this.relatedKeywords,
    required this.isLoading,
    required this.hasError,
  });

  SearchSuggestionState copyWith({
    List<SearchSuggestionModel>? relatedKeywords,
    bool? isLoading,
    bool? hasError,
  }) {
    return SearchSuggestionState(
      relatedKeywords: relatedKeywords ?? this.relatedKeywords,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

final searchSuggestionVmProvider = NotifierProvider<SearchSuggestionNotifier, SearchSuggestionState>(
  () => SearchSuggestionNotifier(),
);
