import 'dart:convert';
import 'package:flutter/services.dart';

/// 닉네임 생성에 사용할 데이터를 관리하는 서비스
class NicknameDataService {
  static const String _dataPath = 'lib/signin_signup/util/nickname_data.json';
  
  // 캐싱을 위한 정적 변수들
  static List<String>? _cachedAdjectives;
  static List<String>? _cachedAnimals;
  static List<String>? _cachedObjects;
  static List<String>? _cachedColors;
  static List<String>? _cachedEmotions;
  static List<String>? _cachedEmotionAdjectives;
  static List<String>? _cachedFoods;
  
  /// JSON 데이터를 로드하여 캐시에 저장
  static Future<void> _loadData() async {
    if (_cachedAdjectives != null) return; // 이미 로드된 경우
    
    try {
      final String jsonString = await rootBundle.loadString(_dataPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _cachedAdjectives = List<String>.from(jsonData['adjectives'] ?? []);
      _cachedAnimals = List<String>.from(jsonData['animals'] ?? []);
      _cachedObjects = List<String>.from(jsonData['objects'] ?? []);
      _cachedColors = List<String>.from(jsonData['colors'] ?? []);
      _cachedEmotions = List<String>.from(jsonData['emotions'] ?? []);
      _cachedEmotionAdjectives = List<String>.from(jsonData['emotion_adjectives'] ?? []);
      _cachedFoods = List<String>.from(jsonData['foods'] ?? []);
    } catch (e) {
      // JSON 로드 실패 시 기본 데이터 사용
      _setDefaultData();
    }
  }
  
  /// 기본 데이터 설정 (JSON 로드 실패 시 사용)
  static void _setDefaultData() {
    _cachedAdjectives = ['멋진', '빠른', '행복한', '푸른', '화려한'];
    _cachedAnimals = ['호랑이', '사자', '독수리', '고래', '펭귄'];
    _cachedObjects = ['별', '달', '해', '구름', '바람'];
    _cachedColors = ['빨간', '파란', '노란', '초록', '보라'];
    _cachedEmotions = ['웃음', '기쁨', '행복', '즐거움', '설렘'];
    _cachedEmotionAdjectives = ['따뜻한', '시원한', '조용한', '밝은', '어두운'];
    _cachedFoods = ['피자', '햄버거', '치킨', '라면', '김치'];
  }
  
  /// 형용사 목록 반환
  static Future<List<String>> get adjectives async {
    await _loadData();
    return _cachedAdjectives!;
  }
  
  /// 동물 목록 반환
  static Future<List<String>> get animals async {
    await _loadData();
    return _cachedAnimals!;
  }
  
  /// 사물 목록 반환
  static Future<List<String>> get objects async {
    await _loadData();
    return _cachedObjects!;
  }
  
  /// 색상 목록 반환
  static Future<List<String>> get colors async {
    await _loadData();
    return _cachedColors!;
  }
  
  /// 감정 목록 반환
  static Future<List<String>> get emotions async {
    await _loadData();
    return _cachedEmotions!;
  }
  
  /// 감정 형용사 목록 반환
  static Future<List<String>> get emotionAdjectives async {
    await _loadData();
    return _cachedEmotionAdjectives!;
  }
  
  /// 음식 목록 반환
  static Future<List<String>> get foods async {
    await _loadData();
    return _cachedFoods!;
  }
  
  /// 모든 데이터를 한번에 로드하여 반환 (성능 최적화)
  static Future<Map<String, List<String>>> getAllData() async {
    await _loadData();
    return {
      'adjectives': _cachedAdjectives!,
      'animals': _cachedAnimals!,
      'objects': _cachedObjects!,
      'colors': _cachedColors!,
      'emotions': _cachedEmotions!,
      'emotion_adjectives': _cachedEmotionAdjectives!,
      'foods': _cachedFoods!,
    };
  }
  
  /// 캐시 초기화 (테스트나 데이터 리로드 시 사용)
  static void clearCache() {
    _cachedAdjectives = null;
    _cachedAnimals = null;
    _cachedObjects = null;
    _cachedColors = null;
    _cachedEmotions = null;
    _cachedEmotionAdjectives = null;
    _cachedFoods = null;
  }
}
