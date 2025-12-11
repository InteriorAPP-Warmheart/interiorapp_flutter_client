class ShowroomApi {
  // 예비 데이터

      final List<Map<String, dynamic>> recentBuildings = [
      {
        'id': '15',
        'buildName': '강원 평창군 펜션 턴키공사',
        'buildImage': 'https://picsum.photos/200/315',
        'buildPeriod': '2025.12.15',
      },
      {
        'id': '14',
        'buildName': '서울 강남구 아파트 화장실',
        'buildImage': 'https://picsum.photos/200/314',
        'buildPeriod': '2025.11.20',
      },
      {
        'id': '13',
        'buildName': '서울 종로구 오피스 턴키공사',
        'buildImage': 'https://picsum.photos/200/313',
        'buildPeriod': '2025.10.08',
      },
      {
        'id': '12',
        'buildName': '부산 해운대구 호텔 주방',
        'buildImage': 'https://picsum.photos/200/312',
        'buildPeriod': '2025.09.03',
      },
      {
        'id': '11',
        'buildName': '서울 서초구 학원 턴키공사',
        'buildImage': 'https://picsum.photos/200/311',
        'buildPeriod': '2025.08.18',
      },
      {
        'id': '10',
        'buildName': '대전 유성구 병원 화장실',
        'buildImage': 'https://picsum.photos/200/310',
        'buildPeriod': '2025.07.25',
      },
      {
        'id': '9',
        'buildName': '인천 연수구 상가 주방',
        'buildImage': 'https://picsum.photos/200/309',
        'buildPeriod': '2025.06.10',
      },
      {
        'id': '8',
        'buildName': '경기 성남시 주택 턴키공사',
        'buildImage': 'https://picsum.photos/200/308',
        'buildPeriod': '2025.05.22',
      },
      {
        'id': '1',
        'buildName': '서울 마포구 카페 화장실',
        'buildImage': 'https://picsum.photos/200/301',
        'buildPeriod': '2025.04.12',
      },
      {
        'id': '7',
        'buildName': '서울 송파구 원룸 주방',
        'buildImage': 'https://picsum.photos/200/307',
        'buildPeriod': '2025.03.28',
      },
      {
        'id': '6',
        'buildName': '경기 수원시 아파트 턴키공사',
        'buildImage': 'https://picsum.photos/200/306',
        'buildPeriod': '2025.02.14',
      },
      {
        'id': '0',
        'buildName': '서울 강동구 아파트 화장실',
        'buildImage': 'https://picsum.photos/200/300',
        'buildPeriod': '2025.01.04',
      },
      {
        'id': '5',
        'buildName': '부산 강서구 레스토랑 주방',
        'buildImage': 'https://picsum.photos/200/305',
        'buildPeriod': '2024.12.20',
      },
      {
        'id': '4',
        'buildName': '대구 수성구 오피스 턴키공사',
        'buildImage': 'https://picsum.photos/200/304',
        'buildPeriod': '2024.11.15',
      },
      {
        'id': '3',
        'buildName': '광주 광산구 상가 화장실',
        'buildImage': 'https://picsum.photos/200/303',
        'buildPeriod': '2024.10.05',
      },
    ];
    final List<Map<String, dynamic>> recentBuildings1 = [];

  Future<List<Map<String, dynamic>>> getRecentBuildingsApi(bool hasData) async {
    await Future.delayed(const Duration(milliseconds: 350));
    
    // 스위치 상태에 따라 데이터 반환 (true = 데이터 있음, false = 빈 리스트)
    if (hasData) {
      // 날짜 기준 내림차순 정렬 (최신 데이터가 먼저)
      final sorted = List<Map<String, dynamic>>.from(recentBuildings);
      sorted.sort((a, b) {
        return b['buildPeriod'].compareTo(a['buildPeriod']);
      });
      return sorted;
    } else {
      return recentBuildings1;
    }
  }

}