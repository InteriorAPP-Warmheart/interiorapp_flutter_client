import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';

/// 서버 연동 전까지 쇼룸 한 편의 이야기를 돌려주는 목 API.
class ShowroomStoryApi {
  static const Map<String, ShowroomStoryModel> _stories =
      <String, ShowroomStoryModel>{
        'showroom1': ShowroomStoryModel(
          id: 'showroom1',
          title: '동탄 횟집',
          themeName: '모던 라이트',
          thumbnailUrl: 'assets/images/showroom/01.jpg',
          userName: '신짱구',
          userProfileUrl: 'https://i.pravatar.cc/100?img=1',
          likeCount: 128,
          favoriteStatus: false,
          situation: ShowroomSituation(
            industry: '횟집',
            area: '32평',
            budget: '8,400만원',
            period: '6주',
          ),
          beforeAfter: ShowroomBeforeAfter(
            beforeUrl: 'assets/images/showroom/16.jpg',
            afterUrl: 'assets/images/showroom/01.jpg',
            caption: '홀 중앙 수조와 객석',
          ),
          cost: ShowroomCost(
            total: '8,400만원',
            lines: <ShowroomCostLine>[
              ShowroomCostLine(name: '철거 · 설비', amount: '1,800만원'),
              ShowroomCostLine(name: '홀 가구', amount: '2,400만원'),
              ShowroomCostLine(name: '조명', amount: '960만원'),
              ShowroomCostLine(name: '주방 마감', amount: '3,240만원'),
            ],
          ),
          process: <ShowroomProcessFrame>[
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/17.jpg',
              caption: '배수 경사를 먼저 잡았습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/05.jpg',
              caption: '수조 위치를 홀 중앙에 고정했습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/06.jpg',
              caption: '진열 조명을 선어 높이에 맞췄습니다.',
            ),
          ],
          guide: <String>[
            '횟집은 배수와 환기를 마감보다 먼저 정합니다.',
            '진열 조명은 색이 탁해지지 않게 4000K 아래로 맞춥니다.',
            '객석과 수조 사이에는 두 사람이 스칠 폭을 남깁니다.',
          ],
        ),
        'showroom2': ShowroomStoryModel(
          id: 'showroom2',
          title: '봉담 성심당',
          themeName: '내추럴 우드',
          thumbnailUrl: 'assets/images/showroom/02.jpg',
          userName: '봉미선',
          userProfileUrl: 'https://i.pravatar.cc/100?img=2',
          likeCount: 1239,
          favoriteStatus: true,
          situation: ShowroomSituation(
            industry: '베이커리',
            area: '18평',
            budget: '5,200만원',
            period: '4주',
          ),
          beforeAfter: ShowroomBeforeAfter(
            beforeUrl: 'assets/images/showroom/05.jpg',
            afterUrl: 'assets/images/showroom/02.jpg',
            caption: '계산대에서 보이는 진열대',
          ),
          cost: ShowroomCost(
            total: '5,200만원',
            lines: <ShowroomCostLine>[
              ShowroomCostLine(name: '철거', amount: '900만원'),
              ShowroomCostLine(name: '우드 가구', amount: '1,600만원'),
              ShowroomCostLine(name: '진열대', amount: '1,400만원'),
              ShowroomCostLine(name: '오븐실 마감', amount: '1,300만원'),
            ],
          ),
          process: <ShowroomProcessFrame>[
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/11.jpg',
              caption: '오븐 열기가 홀로 새지 않게 벽을 막았습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/06.jpg',
              caption: '진열대 높이를 손님 시선에 맞췄습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/08.jpg',
              caption: '계산 동선과 포장대를 분리했습니다.',
            ),
          ],
          guide: <String>[
            '베이커리는 오븐 열과 홀 냉방을 한 공간에 두지 않습니다.',
            '진열대 조명은 빵 색이 노랗게 뜨지 않는 쪽으로 고릅니다.',
          ],
        ),
        'showroom3': ShowroomStoryModel(
          id: 'showroom3',
          title: '인천 야간공격센터',
          themeName: '미니멀 화이트',
          thumbnailUrl: 'assets/images/showroom/03.jpg',
          userName: '신형만',
          userProfileUrl: 'https://i.pravatar.cc/100?img=3',
          likeCount: 342,
          favoriteStatus: true,
          situation: ShowroomSituation(
            industry: '엔터테인먼트',
            area: '45평',
            budget: '1억 2,000만원',
            period: '8주',
          ),
          beforeAfter: ShowroomBeforeAfter(
            beforeUrl: 'assets/images/showroom/15.jpg',
            afterUrl: 'assets/images/showroom/03.jpg',
            caption: '좌석 열과 중앙 통로',
          ),
          cost: ShowroomCost(
            total: '1억 2,000만원',
            lines: <ShowroomCostLine>[
              ShowroomCostLine(name: '흡음 · 칸막이', amount: '2,800만원'),
              ShowroomCostLine(name: '좌석', amount: '4,200만원'),
              ShowroomCostLine(name: '조명', amount: '2,100만원'),
              ShowroomCostLine(name: '전기 · 네트워크', amount: '2,900만원'),
            ],
          ),
          process: <ShowroomProcessFrame>[
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/07.jpg',
              caption: '좌석 열의 간격을 먼저 그었습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/09.jpg',
              caption: '통로 쪽 소음이 새지 않게 벽을 보강했습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/04.jpg',
              caption: '야간 조명은 화면 밖으로만 두었습니다.',
            ),
          ],
          guide: <String>[
            '밤 영업 공간은 화면 밝기와 실내 조명을 같이 봅니다.',
            '좌석 뒤 통로는 의자를 빼도 한 사람이 지나갈 폭입니다.',
          ],
        ),
        'showroom4': ShowroomStoryModel(
          id: 'showroom4',
          title: '차돈이 동탄역점',
          themeName: '미니멀 화이트',
          thumbnailUrl: 'assets/images/showroom/04.jpg',
          userName: '흰둥이',
          userProfileUrl: 'https://i.pravatar.cc/100?img=4',
          likeCount: 477,
          favoriteStatus: false,
          situation: ShowroomSituation(
            industry: '고깃집',
            area: '28평',
            budget: '7,600만원',
            period: '5주',
          ),
          beforeAfter: ShowroomBeforeAfter(
            beforeUrl: 'assets/images/showroom/09.jpg',
            afterUrl: 'assets/images/showroom/04.jpg',
            caption: '테이블과 배기 후드',
          ),
          cost: ShowroomCost(
            total: '7,600만원',
            lines: <ShowroomCostLine>[
              ShowroomCostLine(name: '배기 · 덕트', amount: '2,100만원'),
              ShowroomCostLine(name: '테이블', amount: '1,800만원'),
              ShowroomCostLine(name: '바닥 · 벽', amount: '2,200만원'),
              ShowroomCostLine(name: '주방 설비', amount: '1,500만원'),
            ],
          ),
          process: <ShowroomProcessFrame>[
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/03.jpg',
              caption: '후드 위치를 불판 중심에 맞췄습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/07.jpg',
              caption: '기름이 남는 바닥 마감을 골랐습니다.',
            ),
            ShowroomProcessFrame(
              imageUrl: 'assets/images/showroom/15.jpg',
              caption: '테이블 사이를 서빙 폭으로 벌렸습니다.',
            ),
          ],
          guide: <String>[
            '고깃집은 후드 흡입이 자리 배치보다 우선입니다.',
            '테이블 간격은 의자를 뺀 뒤의 통로로 계산합니다.',
          ],
        ),
      };

  Future<ShowroomStoryModel?> getStory(String id) async {
    return _stories[id];
  }
}
