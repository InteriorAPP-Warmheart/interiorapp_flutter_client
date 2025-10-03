import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';
import 'package:interiorapp_flutter_client/search/data/source/remote/search_result_remote_data_source.dart';

/// 검색 결과 데이터 소스 구현체 (더미 데이터 사용)
class SearchResultRemoteDataSourceImpl implements SearchResultRemoteDataSource {
  final List<SearchResultModel> dummySearchResultItems = [
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/1011/600/600',
        'https://picsum.photos/id/1012/600/600',
        'https://picsum.photos/id/1013/600/600',
        'https://picsum.photos/id/1014/600/600',
      ],
      title: '모던 거실 인테리어',
      contentSnippet: '화이트와 우드톤을 활용해 따뜻한 분위기의 거실을 연출했어요. 식물과 조명을 포인트로 사용했습니다.',
      publisherNickname: 'daily_home',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=5',
    ),
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/1021/600/600',
        'https://picsum.photos/id/1022/600/600',
        'https://picsum.photos/id/1023/600/600',
      ],
      title: '북유럽풍 침실',
      contentSnippet: '부드러운 패브릭과 간접조명으로 포근한 침실을 완성했습니다. 수납은 최소화하고 여백을 살렸어요.',
      publisherNickname: 'cozy_life',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=12',
    ),
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/1031/600/600',
        'https://picsum.photos/id/1032/600/600',
        'https://picsum.photos/id/1033/600/600',
        'https://picsum.photos/id/1034/600/600',
        'https://picsum.photos/id/1035/600/600',
      ],
      title: '화이트 톤 주방 리모델링',
      contentSnippet: '아일랜드 식탁을 중심으로 동선을 개선하고, 상부장을 최소화해 더 넓어 보이도록 설계했어요.',
      publisherNickname: 'kitchen_studio',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=22',
    ),
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/1041/600/600',
        'https://picsum.photos/id/1042/600/600',
      ],
      title: '내추럴 원목 서재',
      contentSnippet: '집중이 잘 되는 톤으로 통일하고, 원목 책상과 오픈 선반으로 실용성을 높였습니다.',
      publisherNickname: 'study_place',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=30',
    ),
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/1051/600/600',
        'https://picsum.photos/id/1052/600/600',
        'https://picsum.photos/id/1053/600/600',
      ],
      title: '미드센추리 감성 포인트',
      contentSnippet:
          '빈티지 가구와 컬러 포인트 러그로 공간에 개성을 더했어요. 조명은 조도를 다양하게 조절할 수 있게 구성.',
      publisherNickname: 'vintage_day',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=40',
    ),
  ];

  final List<SearchResultModel> dummyStoreItems = [
    const SearchResultModel(
      imageUrls: ['https://picsum.photos/id/200/600/600'],
      title: '브랜드A · 미니 테이블 램프',
      contentSnippet: '침실과 거실 어디에 두어도 포인트가 되는 조명',
      publisherNickname: 'BrandA',
      publisherAvatarUrl: null,
    ),
    const SearchResultModel(
      imageUrls: ['https://picsum.photos/id/201/600/600'],
      title: '브랜드B · 우드 체어',
      contentSnippet: '오랜 시간 앉아도 편안한 인체공학 설계',
      publisherNickname: 'BrandB',
      publisherAvatarUrl: null,
    ),
    const SearchResultModel(
      imageUrls: ['https://picsum.photos/id/202/600/600'],
      title: '브랜드C · 러그 120x180',
      contentSnippet: '부드러운 촉감과 미끄럼 방지 처리',
      publisherNickname: 'BrandC',
      publisherAvatarUrl: null,
    ),
    const SearchResultModel(
      imageUrls: ['https://picsum.photos/id/203/600/600'],
      title: '브랜드D · 원형 사이드테이블',
      contentSnippet: '베드사이드, 소파 옆 어디든 잘 어울려요',
      publisherNickname: 'BrandD',
      publisherAvatarUrl: null,
    ),
  ];

  final List<SearchResultModel> dummyConstructionItems = [
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/300/600/600',
        'https://picsum.photos/id/301/600/600',
        'https://picsum.photos/id/302/600/600',
      ],
      title: '부분 리모델링 · 주방',
      contentSnippet: '상부장 최소화, 동선 개선으로 더 넓어진 주방',
      publisherNickname: 'AAA 시공업체',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=8',
    ),
    const SearchResultModel(
      imageUrls: ['https://picsum.photos/id/303/600/600'],
      title: '전체 공사 · 24평',
      contentSnippet: '화이트&우드 톤으로 밝고 따뜻한 공간 연출',
      publisherNickname: 'BBB 시공업체',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=16',
    ),
    const SearchResultModel(
      imageUrls: [
        'https://picsum.photos/id/304/600/600',
        'https://picsum.photos/id/305/600/600',
      ],
      title: '부분 리모델링 · 욕실',
      contentSnippet: '타일 교체와 수납 개선으로 실용성 강화',
      publisherNickname: 'CCC 시공업체',
      publisherAvatarUrl: 'https://i.pravatar.cc/100?img=20',
    ),
  ];

  @override
  Future<List<SearchResultModel>> getSearchResultItems() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return dummySearchResultItems;
  }

  @override
  Future<List<SearchResultModel>> searchItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.trim().isEmpty) {
      return dummySearchResultItems;
    }

    final lowerQuery = query.toLowerCase().trim();

    // 모든 데이터를 합쳐서 검색
    final allItems = [
      ...dummySearchResultItems,
      ...dummyStoreItems,
      ...dummyConstructionItems,
    ];

    // 검색어와 일치하는 아이템들 필터링
    final filteredItems =
        allItems.where((item) {
          final title = item.title?.toLowerCase() ?? '';
          final content = item.contentSnippet?.toLowerCase() ?? '';
          final publisher = item.publisherNickname?.toLowerCase() ?? '';

          return title.contains(lowerQuery) ||
              content.contains(lowerQuery) ||
              publisher.contains(lowerQuery);
        }).toList();

    // 검색어와의 유사도에 따라 정렬
    filteredItems.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, lowerQuery);
      final scoreB = _calculateRelevanceScore(b, lowerQuery);
      return scoreB.compareTo(scoreA);
    });

    print('🔍 Search query: "$query" -> Found ${filteredItems.length} items');

    return filteredItems;
  }

  /// 쇼룸 데이터에서 검색
  @override
  Future<List<SearchResultModel>> searchShowroomItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.trim().isEmpty) {
      return dummySearchResultItems;
    }

    final lowerQuery = query.toLowerCase().trim();

    // 쇼룸 데이터에서만 검색
    final filteredItems =
        dummySearchResultItems.where((item) {
          final title = item.title?.toLowerCase() ?? '';
          final content = item.contentSnippet?.toLowerCase() ?? '';
          final publisher = item.publisherNickname?.toLowerCase() ?? '';

          return title.contains(lowerQuery) ||
              content.contains(lowerQuery) ||
              publisher.contains(lowerQuery);
        }).toList();

    // 검색어와의 유사도에 따라 정렬
    filteredItems.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, lowerQuery);
      final scoreB = _calculateRelevanceScore(b, lowerQuery);
      return scoreB.compareTo(scoreA);
    });

    print(
      '🏠 Showroom search query: "$query" -> Found ${filteredItems.length} items',
    );

    return filteredItems;
  }

  /// 스토어 데이터에서 검색
  @override
  Future<List<SearchResultModel>> searchStoreItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.trim().isEmpty) {
      return dummyStoreItems;
    }

    final lowerQuery = query.toLowerCase().trim();

    // 스토어 데이터에서만 검색
    final filteredItems =
        dummyStoreItems.where((item) {
          final title = item.title?.toLowerCase() ?? '';
          final content = item.contentSnippet?.toLowerCase() ?? '';
          final publisher = item.publisherNickname?.toLowerCase() ?? '';

          return title.contains(lowerQuery) ||
              content.contains(lowerQuery) ||
              publisher.contains(lowerQuery);
        }).toList();

    // 검색어와의 유사도에 따라 정렬
    filteredItems.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, lowerQuery);
      final scoreB = _calculateRelevanceScore(b, lowerQuery);
      return scoreB.compareTo(scoreA);
    });

    print(
      '🛒 Store search query: "$query" -> Found ${filteredItems.length} items',
    );

    return filteredItems;
  }

  /// 시공 데이터에서 검색
  @override
  Future<List<SearchResultModel>> searchConstructionItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.trim().isEmpty) {
      return dummyConstructionItems;
    }

    final lowerQuery = query.toLowerCase().trim();

    // 시공 데이터에서만 검색
    final filteredItems =
        dummyConstructionItems.where((item) {
          final title = item.title?.toLowerCase() ?? '';
          final content = item.contentSnippet?.toLowerCase() ?? '';
          final publisher = item.publisherNickname?.toLowerCase() ?? '';

          return title.contains(lowerQuery) ||
              content.contains(lowerQuery) ||
              publisher.contains(lowerQuery);
        }).toList();

    // 검색어와의 유사도에 따라 정렬
    filteredItems.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, lowerQuery);
      final scoreB = _calculateRelevanceScore(b, lowerQuery);
      return scoreB.compareTo(scoreA);
    });

    print(
      '🔨 Construction search query: "$query" -> Found ${filteredItems.length} items',
    );

    return filteredItems;
  }

  /// 검색어와 아이템의 관련도 점수 계산
  int _calculateRelevanceScore(SearchResultModel item, String query) {
    int score = 0;
    final title = item.title?.toLowerCase() ?? '';
    final content = item.contentSnippet?.toLowerCase() ?? '';
    final publisher = item.publisherNickname?.toLowerCase() ?? '';

    // 제목에서 정확히 일치하는 경우 높은 점수
    if (title.contains(query)) {
      score += 10;
      // 제목의 시작 부분에 있으면 더 높은 점수
      if (title.startsWith(query)) {
        score += 5;
      }
    }

    // 내용에서 일치하는 경우
    if (content.contains(query)) {
      score += 5;
    }

    // 게시자명에서 일치하는 경우
    if (publisher.contains(query)) {
      score += 3;
    }

    // 키워드가 여러 필드에 걸쳐 있으면 보너스 점수
    int matches = 0;
    if (title.contains(query)) matches++;
    if (content.contains(query)) matches++;
    if (publisher.contains(query)) matches++;

    if (matches > 1) {
      score += matches * 2;
    }

    return score;
  }
}
