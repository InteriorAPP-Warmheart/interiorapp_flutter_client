import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';
import 'package:interiorapp_flutter_client/search/data/repository/search_result_impl.dart';
import 'package:interiorapp_flutter_client/search/data/source/remote/search_result_datasource.dart';
import 'package:interiorapp_flutter_client/search/domain/use_case/search_result_use_case.dart';
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