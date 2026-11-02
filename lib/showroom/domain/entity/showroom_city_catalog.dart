class ShowroomCityGroup {
  const ShowroomCityGroup({required this.name, required this.cities});

  final String name;
  final List<String> cities;
}

/// 시 단위 동네. 특별·광역시는 시 이름만 쓴다.
const List<ShowroomCityGroup> showroomCityGroups = <ShowroomCityGroup>[
  ShowroomCityGroup(
    name: '특별·광역시',
    cities: <String>['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종'],
  ),
  ShowroomCityGroup(
    name: '경기',
    cities: <String>[
      '수원시',
      '성남시',
      '고양시',
      '용인시',
      '화성시',
      '부천시',
      '안산시',
      '안양시',
      '남양주시',
      '평택시',
      '의정부시',
      '시흥시',
      '파주시',
      '김포시',
      '광명시',
      '광주시',
      '군포시',
      '하남시',
      '오산시',
      '이천시',
      '구리시',
      '안성시',
      '양주시',
      '포천시',
      '의왕시',
      '여주시',
      '동두천시',
      '과천시',
    ],
  ),
  ShowroomCityGroup(
    name: '강원',
    cities: <String>['춘천시', '원주시', '강릉시', '동해시', '태백시', '속초시', '삼척시'],
  ),
  ShowroomCityGroup(name: '충북', cities: <String>['청주시', '충주시', '제천시']),
  ShowroomCityGroup(
    name: '충남',
    cities: <String>['천안시', '공주시', '보령시', '아산시', '서산시', '논산시', '계룡시', '당진시'],
  ),
  ShowroomCityGroup(
    name: '전북',
    cities: <String>['전주시', '군산시', '익산시', '정읍시', '남원시', '김제시'],
  ),
  ShowroomCityGroup(
    name: '전남',
    cities: <String>['목포시', '여수시', '순천시', '나주시', '광양시'],
  ),
  ShowroomCityGroup(
    name: '경북',
    cities: <String>[
      '포항시',
      '경주시',
      '김천시',
      '안동시',
      '구미시',
      '영주시',
      '영천시',
      '상주시',
      '문경시',
      '경산시',
    ],
  ),
  ShowroomCityGroup(
    name: '경남',
    cities: <String>['창원시', '진주시', '통영시', '사천시', '김해시', '밀양시', '거제시', '양산시'],
  ),
  ShowroomCityGroup(name: '제주', cities: <String>['제주시', '서귀포시']),
];

bool isShowroomCity(String city) {
  for (final ShowroomCityGroup group in showroomCityGroups) {
    if (group.cities.contains(city)) return true;
  }
  return false;
}

bool isShowroomRegion(String name) {
  for (final ShowroomCityGroup group in showroomCityGroups) {
    if (group.name == name) return true;
  }
  return false;
}

/// 시 이름 또는 도 이름.
bool isShowroomPlace(String place) {
  return isShowroomCity(place) || isShowroomRegion(place);
}

/// [place]가 시면 그 시만, 도면 그 도에 속한 시인지.
bool showroomPlaceIncludes(String place, String city) {
  if (city.isEmpty) return false;
  if (place == city) return true;
  for (final ShowroomCityGroup group in showroomCityGroups) {
    if (group.name == place) return group.cities.contains(city);
  }
  return false;
}

List<ShowroomCityGroup> showroomCitiesMatching(String query) {
  final String needle = query.trim();
  if (needle.isEmpty) return showroomCityGroups;
  return <ShowroomCityGroup>[
    for (final ShowroomCityGroup group in showroomCityGroups)
      if (group.name.contains(needle))
        group
      else if (group.cities.any((String city) => city.contains(needle)))
        ShowroomCityGroup(
          name: group.name,
          cities: <String>[
            for (final String city in group.cities)
              if (city.contains(needle)) city,
          ],
        ),
  ];
}
