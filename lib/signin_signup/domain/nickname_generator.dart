import 'dart:math';
import 'package:interiorapp_flutter_client/signin_signup/util/nickname_data_service.dart';

class NicknameGenerator {
  // 캐싱을 위한 정적 변수
  static Map<String, List<String>>? _cachedData;
  
  /// 데이터를 로드하여 캐시에 저장
  static Future<Map<String, List<String>>> _getData() async {
    if (_cachedData != null) return _cachedData!;
    
    _cachedData = await NicknameDataService.getAllData();
    return _cachedData!;
  }
  
  /// 동기 버전의 닉네임 생성 (빠른 응답을 위해)
  static String generateNicknameSync() {
    // 기본 데이터로 빠른 생성
    final defaultAdjectives = ['멋진', '빠른', '행복한', '푸른', '화려한', '차분한', '활발한', '신비로운'];
    final defaultAnimals = ['호랑이', '사자', '독수리', '고래', '펭귄', '토끼', '나비', '해달'];
    final defaultObjects = ['별', '달', '해', '구름', '바람', '물', '불', '흙'];
    final defaultFoods = ['피자', '햄버거', '치킨', '라면', '김치', '떡볶이', '순대', '튀김'];
    final defaultEmotionAdjectives = ['따뜻한', '시원한', '조용한', '밝은', '어두운', '빠른', '느린', '가벼운'];
    
    final random = Random();
    
    // 생성 패턴 선택 (8가지 패턴)
    final pattern = random.nextInt(8);
    
    switch (pattern) {
      case 0: // 형용사 + 동물
        final adjective = defaultAdjectives[random.nextInt(defaultAdjectives.length)];
        final animal = defaultAnimals[random.nextInt(defaultAnimals.length)];
        return _addOptionalNumber('$adjective$animal', random);
        
      case 1: // 형용사 + 사물
        final adjective = defaultAdjectives[random.nextInt(defaultAdjectives.length)];
        final object = defaultObjects[random.nextInt(defaultObjects.length)];
        return _addOptionalNumber('$adjective$object', random);
        
      case 2: // 형용사 + 음식
        final adjective = defaultAdjectives[random.nextInt(defaultAdjectives.length)];
        final food = defaultFoods[random.nextInt(defaultFoods.length)];
        return _addOptionalNumber('$adjective$food', random);
        
      case 3: // 색상 + 동물
        final colors = ['빨간', '파란', '노란', '초록', '보라', '주황', '분홍'];
        final color = colors[random.nextInt(colors.length)];
        final animal = defaultAnimals[random.nextInt(defaultAnimals.length)];
        return _addOptionalNumber('$color$animal', random);
        
      case 4: // 색상 + 음식
        final colors = ['빨간', '파란', '노란', '초록', '보라', '주황', '분홍'];
        final color = colors[random.nextInt(colors.length)];
        final food = defaultFoods[random.nextInt(defaultFoods.length)];
        return _addOptionalNumber('$color$food', random);
        
      case 5: // 감정형용사 + 동물
        final emotionAdj = defaultEmotionAdjectives[random.nextInt(defaultEmotionAdjectives.length)];
        final animal = defaultAnimals[random.nextInt(defaultAnimals.length)];
        return _addOptionalNumber('$emotionAdj$animal', random);
        
      case 6: // 감정형용사 + 사물
        final emotionAdj = defaultEmotionAdjectives[random.nextInt(defaultEmotionAdjectives.length)];
        final object = defaultObjects[random.nextInt(defaultObjects.length)];
        return _addOptionalNumber('$emotionAdj$object', random);
        
      case 7: // 감정형용사 + 음식
        final emotionAdj = defaultEmotionAdjectives[random.nextInt(defaultEmotionAdjectives.length)];
        final food = defaultFoods[random.nextInt(defaultFoods.length)];
        return _addOptionalNumber('$emotionAdj$food', random);
        
      default:
        return 'User${random.nextInt(999999)}';
    }
  }
  
  /// 숫자 추가 (50% 확률)
  static String _addOptionalNumber(String base, Random random) {
    if (random.nextBool()) {
      final number = random.nextInt(999) + 1;
      return '$base$number';
    }
    return base;
  }
  
  /// 비동기 버전의 닉네임 생성 (전체 데이터 사용)
  static Future<String> generateNicknameAsync() async {
    final data = await _getData();
    final random = Random();
    
    // 생성 패턴 선택 (12가지 패턴)
    final pattern = random.nextInt(12);
    
    switch (pattern) {
      case 0: // 형용사 + 동물
        final adjective = data['adjectives']![random.nextInt(data['adjectives']!.length)];
        final animal = data['animals']![random.nextInt(data['animals']!.length)];
        return _addOptionalNumber('$adjective$animal', random);
        
      case 1: // 형용사 + 사물
        final adjective = data['adjectives']![random.nextInt(data['adjectives']!.length)];
        final object = data['objects']![random.nextInt(data['objects']!.length)];
        return _addOptionalNumber('$adjective$object', random);
        
      case 2: // 형용사 + 음식
        final adjective = data['adjectives']![random.nextInt(data['adjectives']!.length)];
        final food = data['foods']![random.nextInt(data['foods']!.length)];
        return _addOptionalNumber('$adjective$food', random);
        
      case 3: // 색상 + 동물
        final color = data['colors']![random.nextInt(data['colors']!.length)];
        final animal = data['animals']![random.nextInt(data['animals']!.length)];
        return _addOptionalNumber('$color$animal', random);
        
      case 4: // 색상 + 사물
        final color = data['colors']![random.nextInt(data['colors']!.length)];
        final object = data['objects']![random.nextInt(data['objects']!.length)];
        return _addOptionalNumber('$color$object', random);
        
      case 5: // 색상 + 음식
        final color = data['colors']![random.nextInt(data['colors']!.length)];
        final food = data['foods']![random.nextInt(data['foods']!.length)];
        return _addOptionalNumber('$color$food', random);
        
      case 6: // 감정형용사 + 동물
        final emotionAdj = data['emotion_adjectives']![random.nextInt(data['emotion_adjectives']!.length)];
        final animal = data['animals']![random.nextInt(data['animals']!.length)];
        return _addOptionalNumber('$emotionAdj$animal', random);
        
      case 7: // 감정형용사 + 사물
        final emotionAdj = data['emotion_adjectives']![random.nextInt(data['emotion_adjectives']!.length)];
        final object = data['objects']![random.nextInt(data['objects']!.length)];
        return _addOptionalNumber('$emotionAdj$object', random);
        
      case 8: // 감정형용사 + 음식
        final emotionAdj = data['emotion_adjectives']![random.nextInt(data['emotion_adjectives']!.length)];
        final food = data['foods']![random.nextInt(data['foods']!.length)];
        return _addOptionalNumber('$emotionAdj$food', random);
        
      case 9: // 감정 + 동물 (자연스러운 조합만)
        final emotions = data['emotions']!.where((e) => _isNaturalEmotion(e)).toList();
        if (emotions.isNotEmpty) {
          final emotion = emotions[random.nextInt(emotions.length)];
          final animal = data['animals']![random.nextInt(data['animals']!.length)];
          return _addOptionalNumber('$emotion$animal', random);
        }
        // fallback to 형용사 + 동물
        final adjective = data['adjectives']![random.nextInt(data['adjectives']!.length)];
        final animal = data['animals']![random.nextInt(data['animals']!.length)];
        return _addOptionalNumber('$adjective$animal', random);
        
      case 10: // 감정 + 사물 (자연스러운 조합만)
        final emotions = data['emotions']!.where((e) => _isNaturalEmotion(e)).toList();
        if (emotions.isNotEmpty) {
          final emotion = emotions[random.nextInt(emotions.length)];
          final object = data['objects']![random.nextInt(data['objects']!.length)];
          return _addOptionalNumber('$emotion$object', random);
        }
        // fallback to 형용사 + 사물
        final adjective = data['adjectives']![random.nextInt(data['adjectives']!.length)];
        final object = data['objects']![random.nextInt(data['objects']!.length)];
        return _addOptionalNumber('$adjective$object', random);
        
      case 11: // 감정 + 음식 (자연스러운 조합만)
        final emotions = data['emotions']!.where((e) => _isNaturalEmotion(e)).toList();
        if (emotions.isNotEmpty) {
          final emotion = emotions[random.nextInt(emotions.length)];
          final food = data['foods']![random.nextInt(data['foods']!.length)];
          return _addOptionalNumber('$emotion$food', random);
        }
        // fallback to 형용사 + 음식
        final adjective = data['adjectives']![random.nextInt(data['adjectives']!.length)];
        final food = data['foods']![random.nextInt(data['foods']!.length)];
        return _addOptionalNumber('$adjective$food', random);
        
      default:
        return 'User${random.nextInt(999999)}';
    }
  }
  
  /// 자연스러운 감정인지 확인 (명사 형태의 감정만 허용)
  static bool _isNaturalEmotion(String emotion) {
    final naturalEmotions = ['웃음', '기쁨', '행복', '즐거움', '설렘', '감동', '사랑', '평화', '희망', '꿈', '소망'];
    return naturalEmotions.contains(emotion);
  }
  
  /// 기본 닉네임 생성 (동기 버전 사용 - 빠른 응답)
  static String generateNickname() {
    return generateNicknameSync();
  }

  /// 중복 확인을 위한 닉네임 생성
  static String generateUniqueNickname(List<String> existingNicknames) {
    String nickname;
    int attempts = 0;

    do {
      nickname = generateNickname();
      attempts++;

      // 무한 루프 방지
      if (attempts > 100) {
        final random = Random();
        nickname = 'User${random.nextInt(999999)}';
        break;
      }
    } while (existingNicknames.contains(nickname));

    return nickname;
  }
  
  /// 비동기 중복 확인을 위한 닉네임 생성
  static Future<String> generateUniqueNicknameAsync(List<String> existingNicknames) async {
    String nickname;
    int attempts = 0;

    do {
      nickname = await generateNicknameAsync();
      attempts++;

      // 무한 루프 방지
      if (attempts > 100) {
        final random = Random();
        nickname = 'User${random.nextInt(999999)}';
        break;
      }
    } while (existingNicknames.contains(nickname));

    return nickname;
  }
  
  /// 캐시 초기화 (테스트나 데이터 리로드 시 사용)
  static void clearCache() {
    _cachedData = null;
    NicknameDataService.clearCache();
  }
}