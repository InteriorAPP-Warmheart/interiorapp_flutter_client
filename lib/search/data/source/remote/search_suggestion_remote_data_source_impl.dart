import 'package:interiorapp_flutter_client/search/data/source/remote/search_suggestion_remote_data_source.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';

/// 검색 제안 데이터 소스 구현체 (더미 데이터 사용)
class SearchSuggestionRemoteDataSourceImpl implements SearchSuggestionRemoteDataSource {
  // 연관 검색어 맵 (더미 데이터)
  final Map<String, List<String>> _relatedKeywordsMap = {
    '거실': ['거실 인테리어', '거실 리모델링', '거실 가구', '거실 조명', '거실 벽지'],
    '침실': ['침실 인테리어', '침실 가구', '침실 조명', '침실 수납', '침실 벽지'],
    '주방': ['주방 인테리어', '주방 리모델링', '주방 가구', '주방 조명', '주방 타일'],
    '화장실': ['화장실 리모델링', '화장실 타일', '화장실 수납', '화장실 조명'],
    '인테리어': ['모던 인테리어', '북유럽 인테리어', '미니멀 인테리어', '빈티지 인테리어'],
    '리모델링': ['전체 리모델링', '부분 리모델링', '주방 리모델링', '화장실 리모델링'],
    '브랜드': ['브랜드A', '브랜드B', '브랜드C', '브랜드D'],
    '램프': ['테이블 램프', '플로어 램프', '펜던트 램프', '스탠드 램프'],
    '체어': ['의자', '스툴', '소파', '벤치'],
    '테이블': ['식탁', '커피 테이블', '사이드 테이블', '책상'],
    '러그': ['원형 러그', '사각 러그', '긴 러그', '소형 러그'],
    '감성': ['감성 인테리어', '감성 조명', '감성 소품', '감성 가구'],
  };

  // 추천 검색어 (더미 데이터)
  final List<String> _trendingKeywords = [
    '모던 인테리어',
    '북유럽 스타일',
    '미니멀 라이프',
    '빈티지 가구',
    '원목 인테리어',
    '화이트 톤',
    '네이처 인테리어',
    '감성 조명',
    '수납 아이디어',
    '리모델링 후기',
  ];

  @override
  Future<List<SearchSuggestionModel>> getRelatedKeywords(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();
    final suggestions = <SearchSuggestionModel>[];

    // 연관 검색어 찾기
    for (final entry in _relatedKeywordsMap.entries) {
      final key = entry.key.toLowerCase();
      final values = entry.value;
      
      // 키워드가 키나 값에 포함되는지 확인
      if (key.contains(lowerQuery) || lowerQuery.contains(key)) {
        for (final value in values) {
          suggestions.add(SearchSuggestionModel(
            keyword: value,
            type: SearchSuggestionType.related,
            isTrending: false,
          ));
        }
      }
      
      // 값들에서도 검색
      for (final value in values) {
        if (value.toLowerCase().contains(lowerQuery) || lowerQuery.contains(value.toLowerCase())) {
          suggestions.add(SearchSuggestionModel(
            keyword: value,
            type: SearchSuggestionType.related,
            isTrending: false,
          ));
        }
      }
    }

    // 중복 제거 및 최대 5개로 제한
    final uniqueSuggestions = suggestions.toSet().toList();
    return uniqueSuggestions.take(5).toList();
  }

  @override
  Future<List<SearchSuggestionModel>> getTrendingKeywords() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _trendingKeywords.map((keyword) => SearchSuggestionModel(
      keyword: keyword,
      type: SearchSuggestionType.trending,
      isTrending: true,
    )).toList();
  }
}