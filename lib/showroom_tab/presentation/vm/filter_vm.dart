import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/entity/filter_entity.dart';

class FilterVm extends Notifier<FilterState> {
  @override
  FilterState build() {
    final categoryItems = <String, List<FilterItem>>{
      '스타일': [
        FilterItem(id: 'minimal', name: '미니멀'),
        FilterItem(id: 'modern', name: '모던'),
        FilterItem(id: 'northern', name: '북유럽'),
        FilterItem(id: 'natural', name: '내추럴'),
        FilterItem(id: 'industrial', name: '인더스트리얼'),
        FilterItem(id: 'classic', name: '클래식'),
        FilterItem(id: 'vintage', name: '빈티지'),
        FilterItem(id: 'korean', name: '한옥스타일'),
      ],
      
      // 공간 형태 - 상위
      '공간 형태': [
        FilterItem(id: 'residential', name: '주거 공간'),
        FilterItem(id: 'commercial', name: '상업 공간'),
      ],
      
      // 주거 공간 하위 항목
      '주거_공간': [
        FilterItem(id: 'apartment', name: '아파트', parentId: 'residential'),
        FilterItem(id: 'villa', name: '빌라(투룸/쓰리룸)', parentId: 'residential'),
        FilterItem(id: 'studio', name: '단독주택', parentId: 'residential'),
        FilterItem(id: 'officetel', name: '오피스텔', parentId: 'residential'),
        FilterItem(id: 'one_room', name: '원룸', parentId: 'residential'),
        FilterItem(id: 'shared_house', name: '고시원/셰어하우스', parentId: 'residential'),
      ],
      
      // 상업 공간 하위 항목
      '상업_공간': [
        FilterItem(id: 'store', name: '상가/매장', parentId: 'commercial'),
        FilterItem(id: 'restaurant', name: '음식점/카페', parentId: 'commercial'),
        FilterItem(id: 'office', name: '사무실/오피스', parentId: 'commercial'),
        FilterItem(id: 'other_commercial', name: '기타 상업시설', parentId: 'commercial'),
      ],
      
      // 주거 공간 세부 항목
      '주거_세부': [
        FilterItem(id: 'living_room', name: '거실', parentId: 'residential'),
        FilterItem(id: 'bedroom', name: '주방', parentId: 'residential'),
        FilterItem(id: 'kitchen', name: '욕실/화장실', parentId: 'residential'),
        FilterItem(id: 'bathroom', name: '침실', parentId: 'residential'),
        FilterItem(id: 'kids_room', name: '자녀방', parentId: 'residential'),
        FilterItem(id: 'dress_room', name: '드레스룸', parentId: 'residential'),
        FilterItem(id: 'multi_room', name: '다용도실', parentId: 'residential'),
        FilterItem(id: 'entrance', name: '현관', parentId: 'residential'),
        FilterItem(id: 'veranda', name: '베란다/발코니', parentId: 'residential'),
        FilterItem(id: 'interior_garden', name: '실내복도', parentId: 'residential'),
        FilterItem(id: 'study', name: '서재/작업실', parentId: 'residential'),
        FilterItem(id: 'storage', name: '창고/수납공간', parentId: 'residential'),
        FilterItem(id: 'attic', name: '마당', parentId: 'residential'),
        FilterItem(id: 'rooftop', name: '천장/루팅', parentId: 'residential'),
      ],
      
      // 상업 공간 세부 항목
      '상업_세부': [
        FilterItem(id: 'store_hall', name: '매장 홀', parentId: 'commercial'),
        FilterItem(id: 'counter', name: '카운터/리셉션', parentId: 'commercial'),
        FilterItem(id: 'work_space', name: '주방/작업공간', parentId: 'commercial'),
        FilterItem(id: 'meeting_room', name: '화장실', parentId: 'commercial'),
        FilterItem(id: 'conference', name: '회의실', parentId: 'commercial'),
        FilterItem(id: 'lounge', name: '휴게실', parentId: 'commercial'),
        FilterItem(id: 'open_lounge', name: '오픈라운지', parentId: 'commercial'),
        FilterItem(id: 'corridor', name: '복도/출입구', parentId: 'commercial'),
        FilterItem(id: 'warehouse', name: '창고', parentId: 'commercial'),
        FilterItem(id: 'garden', name: '진열대', parentId: 'commercial'),
        FilterItem(id: 'terrace', name: '테라스', parentId: 'commercial'),
        FilterItem(id: 'exterior', name: '외부존', parentId: 'commercial'),
      ],
      
      '예산': [], // 슬라이더로 처리 예정
      
      '톤앤매너': [
        FilterItem(id: 'red', name: '레드'),
        FilterItem(id: 'orange', name: '오렌지'),
        FilterItem(id: 'yellow', name: '옐로우'),
        FilterItem(id: 'green', name: '그린'),
        FilterItem(id: 'blue', name: '블루'),
        FilterItem(id: 'purple', name: '퍼플'),
        FilterItem(id: 'pink', name: '핑크'),
        FilterItem(id: 'brown', name: '브라운'),
        FilterItem(id: 'white', name: '화이트'),
        FilterItem(id: 'gray', name: '그레이'),
        FilterItem(id: 'black', name: '블랙'),
      ],
      
      '소재': [
        FilterItem(id: 'steel_floor', name: '강마루'),
        FilterItem(id: 'tile', name: '타일'),
        FilterItem(id: 'wallpaper', name: '벽지'),
        FilterItem(id: 'paint', name: '도장'),
        FilterItem(id: 'lighting', name: '조명'),
        FilterItem(id: 'partition', name: '파티션'),
        FilterItem(id: 'glass', name: '유리'),
        FilterItem(id: 'window', name: '창호'),
        FilterItem(id: 'ceiling', name: '천장'),
        FilterItem(id: 'wood', name: '우드'),
      ],
    };

    return FilterState(categoryItems: categoryItems);
  }

 
}
