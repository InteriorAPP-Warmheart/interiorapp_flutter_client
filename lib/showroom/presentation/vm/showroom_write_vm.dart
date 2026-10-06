import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_write_provider.dart';

final showroomNameTextControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

final showroomWriteToggleButtonsProvider = Provider.autoDispose<List<bool>>((ref) {
  return [false, false];
});

/// 면적 변환 로직을 처리하는 VM
class AreaConversionViewModel {
  /// 평수와 제곱미터 변환 상수 (1평 = 3.3058 제곱미터)
  static const double _pyeongToSquareMeter = 3.3058;

  /// 면적 단위를 변환하고 값을 업데이트
  /// 
  /// [areaController] 면적 값을 입력받는 TextEditingController
  /// [currentUnit] 현재 단위 (true = 평, false = 제곱미터)
  /// [unitNotifier] 단위를 토글할 Notifier
  static void convertArea(
    TextEditingController areaController,
    bool currentUnit,
    AreaUnit unitNotifier,
  ) {
    final currentValue = double.tryParse(areaController.text) ?? 0.0;

    if (currentValue > 0) {
      // 변환 로직: 1평 = 3.3058 제곱미터
      final convertedValue = currentUnit
          ? currentValue * _pyeongToSquareMeter // 평 -> 제곱미터
          : currentValue / _pyeongToSquareMeter; // 제곱미터 -> 평

      areaController.text = convertedValue.toStringAsFixed(2);
    }

    // 단위 토글
    unitNotifier.toggle();
  }
}

/// 비용 포맷팅 및 단위 변환을 처리하는 VM
class CostFormattingViewModel {
  /// 숫자를 한글로 변환
  /// 
  /// [number] 변환할 숫자 (0~9999)
  /// 반환: 한글 숫자 문자열 (예: 1234 -> "일천이백삼십사")
  static String _numberToKorean(int number) {
    if (number == 0) return '';
    if (number == 1) return '일';

    const koreanDigits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
    const koreanUnits = ['', '십', '백', '천'];

    final digits = number.toString().split('').map(int.parse).toList();
    final length = digits.length;
    final result = StringBuffer();

    for (int i = 0; i < length; i++) {
      final digit = digits[i];
      final position = length - i - 1;

      if (digit > 0) {
        // '일'은 십, 백, 천 앞에서는 생략 (예: 10 -> "십", 100 -> "백")
        if (digit == 1 && position > 0) {
          result.write(koreanUnits[position]);
        } else {
          result.write(koreanDigits[digit]);
          if (position > 0) {
            result.write(koreanUnits[position]);
          }
        }
      }
    }

    return result.toString();
  }

  /// 금액을 한글로 표기
  /// 
  /// [amount] 금액 (원 단위)
  /// 반환: 한글 표기 문자열 (예: 100000000 -> "일억원", 1200009820 -> "십이억구천팔백이십원")
  static String amountToKorean(double amount) {
    if (amount == 0) return '영원';

    final amountInt = amount.toInt();
    final result = StringBuffer();

    // 조 단위
    if (amountInt >= 1000000000000) {
      final cho = amountInt ~/ 1000000000000;
      final choRemainder = amountInt % 1000000000000;
      if (cho > 0) {
        result.write(_numberToKorean(cho));
        result.write('조');
        if (choRemainder > 0) {
          result.write(' ');
        }
      }
      amount = choRemainder.toDouble();
    }

    // 억 단위
    if (amount >= 100000000) {
      final eok = (amount ~/ 100000000).toInt();
      final eokRemainder = (amount % 100000000).toInt();
      if (eok > 0) {
        result.write(_numberToKorean(eok));
        result.write('억');
        if (eokRemainder > 0) {
          result.write(' ');
        }
      }
      amount = eokRemainder.toDouble();
    }

    // 만 단위
    if (amount >= 10000) {
      final man = (amount ~/ 10000).toInt();
      final manRemainder = (amount % 10000).toInt();
      if (man > 0) {
        result.write(_numberToKorean(man));
        result.write('만');
        if (manRemainder > 0) {
          result.write(' ');
        }
      }
      amount = manRemainder.toDouble();
    }

    // 만원 미만도 표시
    if (amount > 0) {
      final remainder = amount.toInt();
      if (remainder > 0) {
        result.write(_numberToKorean(remainder));
      }
    }

    return result.toString();
  }

  /// 금액을 한글로 표기 (괄호 형식)
  /// 
  /// [amount] 금액 (원 단위)
  /// 반환: 한글 표기 문자열 (예: 100000000 -> "(일억)원", 1200009820 -> "(십이억구천팔백이십)원")
  static String amountToKoreanWithBrackets(double amount) {
    if (amount == 0) return '영원';
    final korean = amountToKorean(amount);
    return '$korean원';
  }

  /// 금액에 따른 단위 반환 (한글 표기, 괄호 형식)
  /// 
  /// [amount] 금액 (원 단위)
  /// 반환: 한글 표기 단위 문자열 (예: 100000000 -> "(일억)원", 1200009820 -> "(십이억구천팔백이십)원")
  static String getCostUnitKorean(double amount) {
    return amountToKoreanWithBrackets(amount);
  }

  /// 금액에 따른 단위 반환
  /// 
  /// [amount] 금액 (원 단위)
  /// 반환: ('만원', 나눈 값) 또는 ('억원', 나눈 값) 또는 ('조원', 나눈 값)
  static ({String unit, double value}) getCostUnit(double amount) {
    if (amount >= 1000000000000) {
      // 조원 (1조 이상)
      return (unit: '조원', value: amount / 1000000000000);
    } else if (amount >= 100000000) {
      // 억원 (1억 이상)
      return (unit: '억원', value: amount / 100000000);
    } else if (amount >= 10000) {
      // 만원 (1만 이상)
      return (unit: '만원', value: amount / 10000);
    } else {
      // 만원 미만은 그대로
      return (unit: '만원', value: amount / 10000);
    }
  }

  /// 숫자 문자열을 천단위 콤마가 포함된 문자열로 포맷팅
  /// 
  /// [text] 입력된 텍스트
  /// 반환: 포맷팅된 문자열 (예: "1000000" -> "1,000,000")
  static String formatWithCommas(String text) {
    // 숫자만 추출
    final numbersOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (numbersOnly.isEmpty) return '';

    // 천단위 콤마 추가
    final number = int.tryParse(numbersOnly) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 비용 입력 시 포맷팅 및 단위 업데이트
  /// 
  /// [controller] 비용 입력 TextEditingController (만원 단위로 입력)
  /// [onUnitChanged] 단위가 변경될 때 호출되는 콜백 (unit: String)
  static void formatCostInput(
    TextEditingController controller,
    void Function(String unit) onUnitChanged,
  ) {
    final text = controller.text;
    final formatted = formatWithCommas(text);
    
    // 포맷팅된 텍스트가 다르면 업데이트
    if (formatted != text) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length,
        ),
      );
    }

    // 입력값은 만원 단위이므로 실제 금액은 입력값 * 10000
    final numbersOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    final manWon = double.tryParse(numbersOnly) ?? 0.0;
    final actualAmount = manWon * 10000; // 만원을 원으로 변환
    
    // 한글 표기 계산 (실제 금액 기준)
    final costUnitKorean = getCostUnitKorean(actualAmount);
    onUnitChanged(costUnitKorean);
  }
}