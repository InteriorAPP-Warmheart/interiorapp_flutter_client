좋아. 이번에는 단순히 색상표를 적용하는 수준이 아니라, 현재 개발 중인 Flutter 앱을 와플(WAPLL)이라는 프리미엄 인테리어 플랫폼에 맞는 디자인 시스템으로 정비한다는 관점에서 가이드를 잡아볼게.

네 앱은 일반적인 쇼핑 앱과 달리 상가 인테리어 사례, 자재, 시공업체, 프로젝트, 향후 AI 공간 설계까지 다룰 예정이잖아. 따라서 고급스러움은 어두운 색이나 큰 사진만으로 만드는 게 아니라, 타이포그래피·여백·사진 품질·카드 구조·콘텐츠 간 위계를 일관되게 설계하는 데서 나와.

내가 권하는 방향은 다음과 같아.

- 브랜드: 딥 네이비와 차콜을 활용한 전문 기업형 이미지
- 콘텐츠: 아이보리와 밝은 회백색을 활용한 정돈된 화면
- 이미지: 고급 건축 잡지처럼 큰 사진과 절제된 텍스트
- 카드: 테두리와 그림자를 남용하지 않고, 사진·여백·타이포그래피로 구분
- 개발 방식: Flutter의 공통 테마와 재사용 위젯으로 통일해 모든 탭에 같은 디자인 규칙 적용

아래는 실제 프로젝트에 옮겨 적용할 수 있도록 정리한 설계 가이드야.

## 1. 무료 폰트 추천: 고급스러운 느낌은 글꼴 조합에서 시작해

시안에서 보이는 느낌은 하나의 특이한 폰트보다는 영문 로고의 자간, 한글 UI의 정돈된 글꼴, 글자 굵기의 대비에서 만들어져.

Flutter 앱에서는 아래 세 가지를 우선 비교해 보길 추천해.

[Pretendard 프리텐다드 폰트 / 상업용 무료 폰트](https://images.openai.com/static-rsc-4/c8-nvItfenEQnpd5QxEIGZOTnqHSZLh0thQ399NYGk_iszjjLnjZ4UyTiSblRFXh5faCUKQkso5ExEUcY8wKy3_aZn3FWmBJP7XfX90OF5DHw-v9VhJrnIxAloQ1pxw0DHhZhW9K8OA693r6cPeldYDQQpl8FrnouDQ4wf20ZsU?purpose=inline)

## 1. Pretendard

가장 추천

무료 · SIL Open Font License

한글 UI에 적합하고, 굵기 선택 폭이 넓어 제목과 본문을 통일하기 좋아. 시안처럼 현대적이고 단정한 느낌을 구현하기에 적합해.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

GitHub

+1



[공식 다운로드 및 라이선스](https://github.com/orioncactus/pretendard?utm_source=chatgpt.com)

[브런치](https://images.openai.com/static-rsc-4/jqSMvU3wY2gczBVGPJAk_xxNp0trCa76GtgPOEOEGfM5k5rZ2GE1O6Cr5elU0r84jyjXtfyWRL6SIEK4PrZOzkZG0CPA1XT0AtHQfJjGLLPYleDB-eGob_1t7Fs4PjbO7gWr8elTj1tI8jnGvH1m53OK2b3p3GB0tIk0HFANpjg?purpose=inline)

## 2. SUIT

무료 · SIL Open Font License

UI 본문에 초점을 맞춘 서체야. Pretendard와 비슷한 계열이지만 글자 인상이 조금 다르므로, 실제 앱 화면에 적용해 비교할 가치가 있어.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

GitHub

+1



[공식 다운로드 및 라이선스](https://github.com/sun-typeface/SUIT?utm_source=chatgpt.com)

[브런치](https://images.openai.com/static-rsc-4/8x4JYqtzzFxFiDklnGDnLQEaQyN4ijJ22jcRUi4WP6INGrpYocN10sm0FQoYAV02lEG4gpaoK89s3Hx99utg3gY5wX-mY-TioN7YYLTeYQEYYtoWE1Y3VWLDzlrtHurQG5ceQQK6KYeNT2_Nm1RFvr6W4ad-GFLyOfAI1h4LlRk?purpose=inline)

## 3. Noto Sans KR

무료 · SIL Open Font License

다양한 한글 콘텐츠를 안정적으로 표현하기 좋은 선택지야. 브랜드 개성보다는 범용성과 일관성을 우선할 때 추천해.

[Google Fonts에서 보기](https://fonts.google.com/noto/specimen/Noto+Sans+KR?utm_source=chatgpt.com)

### 영문 로고는 UI 폰트와 별도로 다루자

시안의 `WAPLL`처럼 영문을 넓게 배치하는 스타일은 일반적인 UI 폰트를 그대로 쓰기보다, 영문 글꼴의 자간을 조절하는 방식이 좋아.

- 한글 UI: Pretendard
- 영문 메뉴·숫자·브랜드 보조 텍스트: Inter
- 로고의 `W A P L L`: Inter Medium 또는 SemiBold에 넓은 자간 적용

Inter는 [공식 GitHub](https://github.com/rsms/inter?utm_source=chatgpt.com)에서 확인할 수 있어. 한글과 영문을 반드시 서로 다른 폰트로 써야 하는 건 아니지만, 로고만 별도 규칙으로 관리하면 브랜드 인상이 더 선명해져.

주의: 앱에서는 외부 CDN에 의존하기보다 폰트 파일을 프로젝트에 포함하는 방식을 추천해. 오프라인에서도 동일한 글꼴을 보장하기 쉽고, 앱 실행 시 네트워크 상태에 영향을 덜 받아.

## 2. Flutter에 적용할 기본 디자인 시스템

현재 프로젝트 구조를 크게 바꾸기보다는, 기존 `ThemeData`를 중심으로 공통 색상과 텍스트 스타일을 통일하는 방식이 좋아. Flutter 공식 문서도 앱 전체의 색상과 텍스트를 테마로 관리하고, 개별 위젯에서는 필요한 부분만 재정의하는 방식을 안내하고 있어.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://docs.flutter.dev\&sz=32)

Flutter 문서

+1



추천 구조는 다음과 같아.

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_typography.dart
│       ├── app_theme.dart
│       └── app_spacing.dart
├── shared/
│   └── widgets/
│       ├── section_header.dart
│       ├── project_card.dart
│       ├── material_card.dart
│       ├── image_card.dart
│       └── status_badge.dart
└── features/
    ├── home_tab/
    ├── store_tab/
    └── project_tab/
```

이미 `core`, `shared` 또는 공통 위젯 폴더가 있다면 새로 만들 필요 없이 기존 구조에 맞춰 통합하면 돼.

### 2-1. 색상 토큰 정의

우선 시안의 방향에 맞춰 아래 값을 기준으로 시작하자.

| 용도          | 색상          | HEX       |
| ----------- | ----------- | --------- |
| 브랜드 메인      | Deep Navy   | `#0B1F38` |
| 주요 버튼 호버·눌림 | Dark Navy   | `#163650` |
| 본문 주요 텍스트   | Graphite    | `#252E34` |
| 보조 텍스트      | Slate Gray  | `#687280` |
| 앱 배경        | Ivory Gray  | `#F4F5F7` |
| 카드 배경       | White       | `#FFFFFF` |
| 구분선         | Border Gray | `#E5E7EB` |
| 보조 포인트      | Olive       | `#687A5E` |
| 오류          | Muted Red   | `#B94B45` |

`app_colors.dart` 예시야.

```
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0B1F38);
  static const primaryPressed = Color(0xFF163650);

  static const textPrimary = Color(0xFF252E34);
  static const textSecondary = Color(0xFF687280);

  static const background = Color(0xFFF4F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);

  static const accent = Color(0xFF687A5E);
  static const error = Color(0xFFB94B45);
}
```

색상을 각 화면에서 직접 지정하지 말고 `AppColors`를 통해 사용해. 나중에 메인 색을 변경하더라도 여러 화면을 일일이 수정할 필요가 줄어들어.

### 2-2. 폰트와 글자 크기 정의

`pubspec.yaml`에 Pretendard 폰트 파일을 등록한 뒤 전역 테마에서 사용하면 돼. 아래 경로는 예시이므로 실제로 내려받은 파일명과 일치시켜야 해.

```
flutter:
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
          weight: 400
        - asset: assets/fonts/Pretendard-Medium.ttf
          weight: 500
        - asset: assets/fonts/Pretendard-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

프로젝트에서 사용하는 파일이 가변 폰트라면 해당 파일에 맞는 등록 방식을 적용해야 해.

`app_typography.dart`에서는 글자 크기와 굵기를 다음처럼 통일하는 걸 추천해.

```
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 30,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static const headline = TextStyle(
    fontSize: 23,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
```

이 값들은 초기 기준값이야. 작은 화면에서 글자가 지나치게 작아지지 않는지, 긴 상호명이나 자재명이 잘리지 않는지 확인하면서 조정하면 돼.

### 2-3. 전역 테마 구성

`app_theme.dart`에서는 색상과 타이포그래피를 실제 Flutter 컴포넌트에 연결하면 돼.

```
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Pretendard',
      textTheme: const TextTheme(
        headlineLarge: AppTypography.display,
        headlineSmall: AppTypography.headline,
        titleMedium: AppTypography.title,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.border,
            width: 0.7,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.7,
        space: 1,
      ),
    );
  }
}
```

그리고 앱의 `MaterialApp`에 적용해.

```
MaterialApp(
  theme: AppTheme.light,
  home: const HomeTab(),
);
```

위 코드는 밝은 테마의 출발점이야. 프로젝트의 Flutter 버전에 따라 `CardThemeData` 등 일부 API가 다를 수 있으니 현재 SDK에 맞춰 조정해 줘.

여기서 중요한 점은 모든 카드에 테두리를 강제로 넣는 것이 아니라, 공통 기본값을 정하되 카드 종류별로 테두리를 없애거나 사진을 강조할 수 있도록 설계하는 것이야.

## 3. 카드 디자인을 고급스럽게 만드는 방법

카드는 단순히 모서리를 둥글게 만들고 그림자를 넣는다고 고급스러워지지 않아. 와플에서는 카드가 어떤 정보를 보여주는지에 따라 디자인을 구분하는 편이 좋아.

[Andō | Tatler Asia](https://images.openai.com/static-rsc-4/EtgBNHfvWFXVX9VnslbASe7kimNtO1TTh38HaJriUgK7zStRC2SVaU5Gu2AQkrDezZzJNepvcE_JY1ZRevBjQ_wv-LemvSitnxCTdds0HI2h0K2T01Mlr2PlOK9Ankq3wud_81U3qPIixBpB54XbjZR5O2Xgzr-2CzrAo-9EZK0?purpose=inline)

## A. 시공 사례 카드

사진 중심 · 감성보다 완성도

- 사진이 카드 면적의 65\~80%를 차지하도록 구성
- 사진 아래에는 프로젝트명, 공간 유형, 면적 등 핵심 정보만 배치
- 시공사와 상세 정보는 보조 텍스트로 표현
- 모서리는 8\~12px 정도로 절제

추천: 큰 대표 사진 하나를 먼저 보여주고, 세부 정보는 사진 아래에 분리하는 형태.

[Travertine Marble Tiles – Earthy, Textured & Timeless Beauty | Material Depot](https://images.openai.com/static-rsc-4/oLXlc8x--PmyHCZbqyiG-xh7_guUcRQ98xy93bJfJRYeKcGXeA50Vzi8ym54ukI_JlQEoiOGeLUU7bl61DGF5hoXmiY0xv5nLFrQ-9nTlBfHwGTUeJ_Toi6PoMLwnA2WNRAIW0W37BRRKoEIKqrSM706m3PMyqHtD4dekz39FG4?purpose=inline)

## B. 자재 상품 카드

제품 중심 · 규격과 가격의 명확성

- 제품 이미지는 동일한 비율과 배경으로 통일
- 제품명은 최대 2줄로 제한
- 규격, 단위, 가격을 일정한 위치에 배치
- 색상과 재질이 중요한 제품은 이미지 배경을 중립적으로 유지

추천: 장식적인 그림자보다 정렬과 정보 밀도로 전문성을 표현.

[Archvoyage: Crafting Your Dream Luxury Villa in Dubai by thefirstthelast.agency on Muzli](https://images.openai.com/static-rsc-4/w8qOW3pPJf7qCt06TgnXeY8a0HNzzXmEKKIH0CZISam46a4SoZg26ihAl2VhwGYkM9gJcmniLcgixlbpCUQBcfM6eecz-lIEyuJ8r440T88CKkuC9mHPyEnsdo1CfPokFHHzK_NtIKRu765GljywNeILq1ZapZkmlUaXpVkKW8s?purpose=inline)

## C. 업체·프로젝트 카드

정보 중심 · 신뢰와 비교 편의성

- 업체명, 전문 분야, 지역을 일정한 위계로 표시
- 대표 사진은 가로형으로 작게 배치하거나 상단 배너로 활용
- 평점, 시공 횟수 등은 검증된 데이터만 노출
- 진행 상태는 색상보다 명확한 텍스트와 작은 배지로 표현

추천: 사진과 정보가 경쟁하지 않도록 정보 영역을 깔끔하게 정돈.

### 카드의 공통 규칙

| 속성       | 권장 시작값                    |
| -------- | ------------------------- |
| 카드 모서리   | 8\~12px                   |
| 카드 내부 여백 | 12\~16px                  |
| 카드 사이 간격 | 12\~16px                  |
| 섹션 간 간격  | 28\~36px                  |
| 사진 비율    | 4:3, 3:2, 16:9 중 용도별 통일   |
| 테두리      | 아주 옅은 회색, 필요할 때만          |
| 그림자      | 기본적으로 없음, 떠 있는 요소에만 제한적으로 |

이 값들은 절대 규칙이 아니라 초기 디자인 토큰이야. 실제 화면 밀도와 기기 크기에 따라 조정하면 돼.

## 4. Flutter에서 공통 이미지 카드 만들기

이미지와 텍스트의 정렬을 통일하려면 개별 화면에서 매번 `Container`, `Image`, `Text`를 조합하지 말고 공통 위젯을 만드는 것이 좋아.

아래는 시공 사례용 카드의 기본 예시야.

```

import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.description,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String category;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE8EAED),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: Color(0xFF687280),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF687A5E),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

이 코드에서 특히 중요한 건 `AspectRatio`, `BoxFit.cover`, `Clip.antiAlias`야. 사진 비율이 일정하게 유지되고, 카드의 모서리에 맞게 사진이 잘리기 때문에 여러 프로젝트를 나열해도 정돈된 느낌이 나. Flutter에서도 이미지 크기와 비율을 명시하고 적절한 `fit`을 지정하는 방식이 권장돼.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://docs.flutter.dev\&sz=32)

Flutter 문서

+2



다만 실제 서비스에서는 다음도 추가하는 것이 좋아.

- 이미지 로딩 중에는 배경색이 있는 플레이스홀더 표시
- 로딩 실패 시 깨진 이미지 대신 기본 이미지 제공
- 썸네일 크기에 맞는 디코딩과 이미지 캐시 전략 적용
- 카드 전체가 클릭되는 영역임을 명확하게 표현
- 접근성을 위해 사진에 의미 있는 설명을 제공

## 5. 이미지 자체를 고급스럽게 관리하는 방법

여기가 특히 중요해. 디자인이 깔끔하더라도 사진의 품질과 구도가 제각각이면 전체 앱이 저렴해 보일 수 있어.

### 5-1. 이미지 유형마다 촬영·표현 규칙을 정해

[The Fifth Miami Beach | Gabellini Sheppard](https://images.openai.com/static-rsc-4/WUnB6HA0gU4ZhMdQVg6NN_qAi2frKCZIA2F0UhumpAu4il65qTTOBKfDDC7O9noVYpciK44ngsLopLqA0XGOXRkjIraV7C4GhqSjeShSQN-CEZ0ekywINhJNq6kZ1Th8brdQibZXOW-f-CfGPv2LwScRFwBqbsJ-QNmE44T4PiM?purpose=inline)

시공 사례

- 완성된 공간의 전체 구조가 드러나는 대표 사진
- 수직선이 기울어지지 않도록 촬영
- 가능하면 자연광과 실내 조명의 색을 균형 있게 조정
- 대표 사진과 세부 사진을 구분해 업로드

[Basis Furniture Designer 10 Materials: Professional approach to creating and managing a resource library | Company Stavros](https://images.openai.com/static-rsc-4/yLoSNX6xOiVR-eZd5HGIHWCucgJgXmDhNQCTGLl_-3UT8HhuD-MraBFcQTlHRant30zPlLK-AP_doYQUa2RPtroDBq8SHF4L9SsowkEmvgbITmFJg9qcjg3ucIkuDZlOYtE5hUCdFFxiSS4LTsermRf6q6FljPvBf_mqJZI852Y?purpose=inline)

자재 상품

- 배경과 조명을 통일
- 재질의 실제 색상과 질감이 왜곡되지 않도록 관리
- 제품마다 같은 프레임과 촬영 거리를 사용
- 색상 옵션은 별도 스와치로 표현

[Ébénisterie Architecturale haut de gamme à Montréal, Luxury Custom Wood Inc.](https://images.openai.com/static-rsc-4/_6FLcfF2C4ZU5o7jgRvPv3S1TEuDLSxaKqUCVcVfLKpSjOddvHx0c439N4U8W8L8golpmEmFd_BjhcO_1YbzxWU2lskOmpBub-1fy2Nx44Abe71ARfaVJ0rvD9AP-qGNDKRJnhHVS8J9q1WWWp6orZ9TeSPEVI8hTXbKetrXx48?purpose=inline)

디테일 사진

- 목공 마감, 금속 하드웨어, 타일 줄눈 등 소재의 특징을 보여주는 사진
- 전체 공간 사진과 별도로 분류
- 확대 사진을 무작정 섞지 말고 상세 페이지에서 순서 있게 제공

### 5-2. 업로드 규칙을 데이터 구조에 반영해

사진을 올리는 사용자마다 비율과 품질이 다를 테니, 업로드 단계에서부터 통제하는 것이 좋아.

예를 들어 프로젝트 이미지에 다음 메타데이터를 관리할 수 있어.

```
{
  "project_id": "project_001",
  "image_type": "cover",
  "aspect_ratio": "4:3",
  "sort_order": 0,
  "width": 1600,
  "height": 1200,
  "is_primary": true
}
```

이것은 데이터 구조의 예시이며, 실제 ID 형식은 현재 서버 스키마에 맞춰 적용하면 돼.

권장 이미지 파이프라인은 다음과 같아.

1. 원본 업로드
2. EXIF 방향 정보 보정
3. 이미지 크기와 파일 형식 검증
4. 썸네일·목록용·상세용 이미지 생성
5. 서버 또는 오브젝트 스토리지에 저장
6. 화면별 적절한 이미지 버전을 제공

특히 목록 화면에 원본 사진을 그대로 내려주면 네트워크와 메모리 사용량이 커질 수 있어. Flutter는 이미지 디코딩 크기를 지정할 수 있고, 큰 이미지는 화면 표시 크기에 맞춰 최적화하는 것이 유리해.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://api.flutter.dev\&sz=32)

Dart API

+1



### 5-3. 이미지를 예쁘게 보이게 하려고 전부 어둡게 만들지는 마

시안의 건축 사진은 어두운 톤이지만, 모든 자재 사진과 시공 사진에 같은 필터를 적용하면 실제 색상을 판단하기 어려워져.

- 브랜드 소개와 홈의 대표 배너: 어두운 톤을 제한적으로 활용
- 시공 사례: 실제 공간의 색상과 조명을 최대한 정확하게 표현
- 자재 상품: 실제 색상과 질감을 우선
- 업체 프로필: 자연스럽고 일관된 사진 톤 유지

사진 위에 텍스트를 올려야 한다면 검은색 그라데이션을 아래쪽에만 적용해 글자가 읽히도록 하는 편이 좋아. 사진 전체에 검은색 오버레이를 강하게 덮는 건 피하자.

## 6. 영역별 구분은 선보다 여백과 배경으로

고급스러운 앱을 만들 때 흔한 실수가 모든 영역을 테두리와 카드로 감싸는 거야. 화면이 작은 박스들의 집합처럼 보이면서 오히려 복잡해질 수 있어.

## 추천 화면 레이아웃

WAPLL / SPACE JOURNAL

## 공간의 새로운 기준

[Daily Provisions | Wallpaper\*](https://images.openai.com/static-rsc-4/LA6HTOYtH8DjVmCNEvLDY8R1_VAD7n7-3A5z2VOleKx8adgwF-Drt-TdLCYuUoLORZlpldOy8gD-qOVeqM7z--ZwMimjn0qxBdghIRdAstlPOV8u8e6Rn-s6CpBcxJFw0Il5s6_hp-Hc9hOJMWM_bqoQxHuendFNW0RWrrZDiLA?purpose=inline)

[wallpaper.com](https://www.wallpaper.com/travel/usa/new-york/restaurants/daily-provisions?utm_source=chatgpt.com)

### 추천 프로젝트

전체 보기 →

[Bekk](https://images.openai.com/static-rsc-4/XHo4KNSTjv5dmC-z1Hp_8FRoBNQPr6dDO4AyVFyVTf9MPhio_0LPBXb6wWsXYScUP3X40azZjQUDL-dZvIHvZ0JSlUn44pQRVH6pbevFk2F_qBoNKGa50xmhI4VJuFVeIYNSo-MJ0VbZJXaGlmkWfTtwT6jeviEiF6r7N6ItZFo?purpose=inline)

레스토랑 리뉴얼

상업공간 · 42평

[Our Locations – Songmont](https://images.openai.com/static-rsc-4/a5yUimrrqFPKN72Zb-0RofpyVBel2yttxhULtowmDmn5E9d4P9QSiXrK29_ltrG-ll05UB0hku6414tzULx-ZyJ5t94f4SONzC550YI-MT37U1DBcNjJwnn8rZnIFEy1QbiMzmEJT-XZJvKF2J6InIROEsyMlgZVu3c6tZnmRok?purpose=inline)

브랜드 매장

상업공간 · 28평

자재 · 전문가 · 공간 설계

레이아웃 개념 예시. 실제 서비스에서는 콘텐츠의 종류와 밀도에 맞춰 카드 크기와 섹션 간격을 조정해.

### 영역별로 적용할 규칙

| 영역       | 권장 방식                    |
| -------- | ------------------------ |
| 페이지 전체   | 밝은 회백색 배경을 기본으로 사용       |
| 페이지 헤더   | 배경과 같은 색, 불필요한 하단 그림자 제거 |
| 섹션 사이    | 28\~36px 정도의 여백으로 구분     |
| 카드 내부    | 12\~16px 패딩, 일정한 텍스트 정렬  |
| 콘텐츠 그룹   | 필요한 곳에만 얇은 구분선 적용        |
| 주요 액션    | 딥 네이비 배경 또는 명확한 텍스트 버튼   |
| 하단 내비게이션 | 흰색 또는 배경색, 얇은 상단 경계      |
| 상태 정보    | 색상만이 아니라 텍스트와 아이콘을 함께 사용 |

여기서 가장 중요한 건 같은 레벨의 콘텐츠는 같은 규칙으로 표현하고, 다른 성격의 콘텐츠는 다른 표현 방식을 허용하는 것이야.

예를 들어 자재 목록은 제품 정보와 가격 비교가 중요하지만, 시공 사례는 사진과 공간의 인상이 중요해. 두 영역을 같은 카드 디자인에 억지로 끼워 맞출 필요는 없어.

## 7. 와플의 앱 탭별 디자인 방향

현재 앱의 홈, 스토어, 공간 설계, 프로젝트 등의 기능을 기준으로 보면 다음과 같이 역할을 나누는 게 좋아.

[Realtà Magazine di Mapei diventa digitale | Articoli | Ingenio](https://images.openai.com/static-rsc-4/NikBUoEwxlrTklgU9rHAMr8Rvq_NskDbxTpRy9ZguJHpVc5_FvFCmRlorIYOLdVPHcFt807-PAGP7_GaAN-H3c4Shvxc4R0amT-8UYb7s_2O5LmSLuRLbxzvR8cDY9Z7LsupSaAXvSN_60uZgq6i6DuaAByBGPGLzgIYRkNcD40?purpose=inline)

홈 — 브랜드 경험

대표 공간 사진, 추천 프로젝트, 인기 자재 등으로 구성해. 홈에서 모든 기능을 한꺼번에 설명하기보다 핵심 콘텐츠를 선별해 보여줘.

[Roma Vein Silver - Travertino - MTR 5002 160x320 MATT 6 mm](https://images.openai.com/static-rsc-4/KuMbKm4PeVNP8Qy1HQwH0gstyb7X4R3aEbG6iwRWIfwl-exEFAzwIJfwTUV5L3UA9fQoXVW8XA5NeOCKof1rNykGZMbcgsJHqqTjA8OMqeQgtCAW4bxbPgq5qpdZC-m8Rhs1EnID5KGYhKrazyIHa56Q5r3LMyqzCuZQ60WsBG4?purpose=inline)

스토어 — 정보와 구매 효율

필터, 규격, 가격, 단위, 재고 같은 정보를 일관되게 배치해. 이미지의 크기와 배경을 통일하고 비교가 쉬운 목록을 제공해.

[平面図・断面図から3Dパースを生成してみる【Nano Banana Pro】｜SeaGate（繁戸和幸）](https://images.openai.com/static-rsc-4/oA7OZa8sImLL8wXTYvFjXjLnunmqP1Bt8dufRBHCa3SHVIgPACYyc8IZAD3Pb5bC5X1ptZ367dgyk9sfM8_zXQ5cvDfGzdx0OING-hxtatk490TEuS-0tbn-pmCsdwaQ2H6kl2Q0X3OlmaaEnkZLQNdCcKU5L9diOpN6PPjCWHk?purpose=inline)

공간 설계 — 도구 중심

3D 미리보기, 도면, 치수, 자재 설정을 우선해. 장식적인 카드보다 작업 영역을 넓게 확보하고 조작 요소의 위치를 고정하는 편이 좋아.

[BuildWize — AI Construction Management: Scheduling, Video, Client Communication](https://images.openai.com/static-rsc-4/tMk8UfgPwaXR55T7ZVine2aerh0E0J5-qYg0GCHBpfMwxMnlAtZ8F89p3Fn2ndpfMAytn2qKh0m531FjNMSE9JtHXVAfxRk0ngiPwIgE1l7vXntE0ZQJFhU_MKs5vge1_IXhc7XCP8buPvb5iJ_1y0QbwQvrEeexdfyQwBWEUmw?purpose=inline)

프로젝트 — 업무 효율

진행 상태, 일정, 담당자, 비용을 명확하게 표현해. 브랜드 컬러는 주요 액션에 집중하고 진행 상태는 별도의 의미 체계로 관리해.

## 8. 실제 개발 적용 순서

현재 만들어 놓은 화면을 한 번에 전부 수정하면 디자인 오류와 기능 오류가 섞여 원인을 파악하기 어려워질 수 있어. 아래 순서대로 진행하는 걸 추천해.

1. 디자인 토큰부터 적용 — 색상, 폰트, 글자 크기, 간격, 모서리 값을 공통 파일로 정리.
2. 공통 컴포넌트 수정 — 버튼, 검색창, 섹션 헤더, 배지, 카드부터 통일.
3. 홈 탭을 기준 화면으로 리뉴얼 — 대표 이미지, 콘텐츠 위계, 여백을 먼저 검증.
4. 스토어와 프로젝트 탭에 확장 — 같은 브랜드 규칙을 유지하되 정보 유형에 맞게 카드 변형.
5. 이미지 시스템 정비 — 업로드 규격, 썸네일 생성, 로딩 상태, 실패 상태를 구현.
6. 기기별 검수 — 작은 화면, 긴 텍스트, 네트워크 지연, 접근성 글자 크기까지 확인.

내가 특히 권하는 것은 첫 번째 단계에서 디자인 토큰을 먼저 확정하는 거야. 그래야 이후에 디자인을 수정할 때 각 화면을 개별적으로 고치는 대신 공통 규칙을 변경할 수 있어.

## 9. 최종 체크리스트

## 디자인 적용 체크리스트

0/8

Pretendard 또는 SUIT 적용 및 글자 굵기 통일

브랜드·배경·텍스트 색상 토큰 중앙 관리

카드 유형별 공통 위젯 구현

사진 비율과 썸네일 규격 통일

이미지 로딩·실패 플레이스홀더 처리

영역별 여백과 구분선 규칙 통일

버튼·배지·내비게이션 상태 통일

작은 화면과 접근성 글자 크기 검수

마지막으로, 현재 개발 중인 앱을 실제로 리뉴얼할 때는 전체 화면을 새로 만드는 것보다 현재 홈 탭 하나를 기준으로 완성도를 높인 뒤 공통 디자인 시스템을 다른 탭으로 확장하는 방식이 가장 효율적일 거야.

특히 지금의 Flutter 프로젝트에서 홈·스토어·공간 설계의 구조와 기존 위젯을 확인할 수 있다면, 다음 단계에서는 이 가이드를 바탕으로 실제 파일 구조에 맞춘 `app_theme.dart`, `app_colors.dart`, 공통 카드 위젯과 적용 순서까지 구체화할 수 있어.