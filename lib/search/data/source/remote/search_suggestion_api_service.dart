// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';

// /// 서버 연동을 위한 API 서비스 클래스
// class SearchSuggestionApiService {
//   static const String _baseUrl = 'https://api.your-domain.com';
//   static const Duration _timeout = Duration(seconds: 5);

//   final http.Client _client;

//   SearchSuggestionApiService({http.Client? client}) 
//       : _client = client ?? http.Client();

//   /// 연관 검색어 API 호출
//   Future<List<SearchSuggestionModel>> getRelatedKeywords(String query) async {
//     try {
//       final uri = Uri.parse('$_baseUrl/search/suggestions/related')
//           .replace(queryParameters: {'q': query});
      
//       final response = await _client
//           .get(uri)
//           .timeout(_timeout);

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = jsonDecode(response.body);
//         return jsonList
//             .map((json) => SearchSuggestionModel.fromJson(json))
//             .toList();
//       } else {
//         throw SearchSuggestionException(
//           'Failed to fetch related keywords: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw SearchSuggestionException('Network error: $e');
//     }
//   }

//   /// 추천 검색어 API 호출
//   Future<List<SearchSuggestionModel>> getTrendingKeywords() async {
//     try {
//       final uri = Uri.parse('$_baseUrl/search/suggestions/trending');
      
//       final response = await _client
//           .get(uri)
//           .timeout(_timeout);

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = jsonDecode(response.body);
//         return jsonList
//             .map((json) => SearchSuggestionModel.fromJson(json))
//             .toList();
//       } else {
//         throw SearchSuggestionException(
//           'Failed to fetch trending keywords: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw SearchSuggestionException('Network error: $e');
//     }
//   }

//   /// 검색어 자동완성 API 호출 (더 정교한 검색)
//   Future<List<SearchSuggestionModel>> getAutocompleteSuggestions(String query) async {
//     try {
//       final uri = Uri.parse('$_baseUrl/search/autocomplete')
//           .replace(queryParameters: {
//             'q': query,
//             'limit': '10',
//             'include_trending': 'true',
//           });
      
//       final response = await _client
//           .get(uri)
//           .timeout(_timeout);

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = jsonDecode(response.body);
//         return jsonList
//             .map((json) => SearchSuggestionModel.fromJson(json))
//             .toList();
//       } else {
//         throw SearchSuggestionException(
//           'Failed to fetch autocomplete suggestions: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw SearchSuggestionException('Network error: $e');
//     }
//   }

//   void dispose() {
//     _client.close();
//   }
// }

// /// 검색 제안 관련 예외 클래스
// class SearchSuggestionException implements Exception {
//   final String message;
  
//   const SearchSuggestionException(this.message);
  
//   @override
//   String toString() => 'SearchSuggestionException: $message';
// }

// /// 서버 응답 모델 예시
// class SearchSuggestionResponse {
//   final List<SearchSuggestionModel> suggestions;
//   final int totalCount;
//   final bool hasMore;
//   final String? nextCursor;

//   const SearchSuggestionResponse({
//     required this.suggestions,
//     required this.totalCount,
//     required this.hasMore,
//     this.nextCursor,
//   });

//   factory SearchSuggestionResponse.fromJson(Map<String, dynamic> json) {
//     return SearchSuggestionResponse(
//       suggestions: (json['suggestions'] as List)
//           .map((item) => SearchSuggestionModel.fromJson(item))
//           .toList(),
//       totalCount: json['total_count'] as int,
//       hasMore: json['has_more'] as bool,
//       nextCursor: json['next_cursor'] as String?,
//     );
//   }
// }

// /// API 에러 응답 모델
// class ApiErrorResponse {
//   final String error;
//   final String message;
//   final int? code;

//   const ApiErrorResponse({
//     required this.error,
//     required this.message,
//     this.code,
//   });

//   factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
//     return ApiErrorResponse(
//       error: json['error'] as String,
//       message: json['message'] as String,
//       code: json['code'] as int?,
//     );
//   }
// }
