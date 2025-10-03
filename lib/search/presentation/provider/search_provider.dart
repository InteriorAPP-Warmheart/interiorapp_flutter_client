import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';
import 'package:interiorapp_flutter_client/search/data/repository/search_result_impl.dart';
import 'package:interiorapp_flutter_client/search/data/repository/search_suggestion_impl.dart';
import 'package:interiorapp_flutter_client/search/data/source/remote/search_result_datasource.dart';
import 'package:interiorapp_flutter_client/search/data/source/remote/search_suggestion_remote_data_source_impl.dart';
import 'package:interiorapp_flutter_client/search/domain/use_case/search_result_use_case.dart';
import 'package:interiorapp_flutter_client/search/domain/use_case/search_suggestion_use_case.dart';
import 'package:interiorapp_flutter_client/search/presentation/vm/search_vm.dart';

final searchProvider = NotifierProvider<SearchNotifier, String>(() => SearchNotifier());

// Data Source Provider
final searchResultRemoteDataSourceProvider = Provider((ref) {
  return SearchResultRemoteDataSourceImpl();
});

// Repository Provider
final searchResultRepositoryProvider = Provider((ref) {
  return SearchResultImpl(
    remoteDataSource: ref.read(searchResultRemoteDataSourceProvider),
  );
});

// UseCase Provider
final searchResultUseCaseProvider = Provider((ref) {
  return SearchResultUseCase(ref.read(searchResultRepositoryProvider));
});

final searchResultProvider = FutureProvider<List<SearchResultModel>>((ref) async {
  return await ref.read(searchResultUseCaseProvider).getSearchResultItems();
});

// 검색어에 따른 통합 검색 결과 Provider
final searchResultByQueryProvider = FutureProvider.family<List<SearchResultModel>, String>((ref, query) async {
  return await ref.read(searchResultUseCaseProvider).searchItems(query);
});

// 카테고리별 검색 결과 Provider
final categorySearchResultProvider = FutureProvider.family<List<SearchResultModel>, ({String query, String category})>((ref, params) async {
  return await ref.read(searchResultUseCaseProvider).searchByCategory(params.query, params.category);
});

// Search Suggestion Providers
final searchSuggestionRemoteDataSourceProvider = Provider((ref) {
  return SearchSuggestionRemoteDataSourceImpl();
});

final searchSuggestionRepositoryProvider = Provider((ref) {
  return SearchSuggestionImpl(
    remoteDataSource: ref.read(searchSuggestionRemoteDataSourceProvider),
  );
});

final searchSuggestionUseCaseProvider = Provider((ref) {
  return SearchSuggestionUseCase(ref.read(searchSuggestionRepositoryProvider));
});

final relatedKeywordsProvider = FutureProvider.family<List<SearchSuggestionModel>, String>((ref, query) async {
  return await ref.read(searchSuggestionUseCaseProvider).getRelatedKeywords(query);
});

final trendingKeywordsProvider = FutureProvider<List<SearchSuggestionModel>>((ref) async {
  return await ref.read(searchSuggestionUseCaseProvider).getTrendingKeywords();
});