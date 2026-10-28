import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';

/// develop_data의 견적서 본문을 앱에서 보기 위한 표본.
/// 공사항목은 견적서에 고정된 공종이고, 그 안의 품목은 그 파일의 줄이다.
const WorkQuote sampleWorkQuote = WorkQuote(
  documentTitle: '동탄 부동산 인테리어 공사',
  company: '디자인웜하트',
  statusLabel: '확인 전',
  sheet: EstimateSheet(
    conditions: [
      '견적에 없는 공사는 따로 청구해요',
      '디자인이 바뀌면 공사 금액이 달라질 수 있어요',
      '사인, 가구, 주방기구, 도시가스, 에어컨, 소품은 포함하지 않아요',
      '전기 증설은 별도예요',
    ],
    trades: [
      EstimateTrade(
        name: '철거',
        lines: [
          EstimateLine(name: '내외부 기본철거', material: 150000, labor: 550000),
          EstimateLine(name: '폐기물 차대비', material: 350000),
        ],
      ),
      EstimateTrade(
        name: '목공공사',
        lines: [
          EstimateLine(
            name: '가벽신설 및 룸구성',
            unit: '식',
            material: 2450000,
            labor: 2150000,
          ),
          EstimateLine(
            name: '경량철골구조자재',
            unit: '식',
            material: 1950000,
            labor: 1850000,
          ),
          EstimateLine(
            name: '카운터제작',
            material: 550000,
            labor: 950000,
            materials: [
              EstimateMaterial(name: '내부 수납장'),
              EstimateMaterial(name: '유리'),
              EstimateMaterial(name: '조명'),
            ],
          ),
          EstimateLine(
            name: '매립박스시공',
            material: 450000,
            labor: 850000,
            materials: [
              EstimateMaterial(name: '합판', quantity: '5', unit: '개소'),
              EstimateMaterial(name: 'MDF', quantity: '5', unit: '개소'),
            ],
          ),
          EstimateLine(
            name: '바테이블제작',
            labor: 450000,
            materials: [
              EstimateMaterial(
                name: '바테이블',
                spec: '8670×600×750',
                unit: '식',
                amount: 850000,
              ),
            ],
          ),
          EstimateLine(
            name: '룸 도어 제작',
            labor: 750000,
            materials: [
              EstimateMaterial(
                name: '룸 도어',
                quantity: '6',
                unit: '개',
                amount: 850000,
              ),
            ],
          ),
          EstimateLine(
            name: '셀프바 장 제작',
            unit: '식',
            material: 450000,
            labor: 350000,
          ),
          EstimateLine(
            name: '슬라이딩 레일 설치',
            unit: '식',
            material: 1250000,
            labor: 450000,
          ),
          EstimateLine(
            name: '룸 벽체 외 전체 쫄대 마감',
            unit: '식',
            material: 420000,
            labor: 650000,
          ),
          EstimateLine(
            name: '천장마감시공',
            spec: '석고 시공',
            unit: '식',
            material: 1250000,
            labor: 1850000,
          ),
          EstimateLine(name: '각종 도어 손잡이 액세서리', material: 450000, labor: 200000),
        ],
      ),
      EstimateTrade(
        name: '필름시공',
        lines: [
          EstimateLine(
            name: '가벽설치 및 룸구성',
            spec: '벽체 필름 마감',
            unit: '식',
            material: 1150000,
            labor: 1450000,
          ),
          EstimateLine(
            name: '가구 및 기타',
            spec: '필름 기타 전체 마감',
            unit: '식',
            material: 450000,
            labor: 550000,
          ),
          EstimateLine(
            name: '폴딩도어',
            unit: '식',
            material: 4850000,
            labor: 850000,
          ),
          EstimateLine(name: '폴딩 유리 마감', unit: '식', material: 850000),
          EstimateLine(
            name: '금속 바테이블',
            unit: '식',
            material: 400000,
            labor: 350000,
          ),
        ],
      ),
      EstimateTrade(
        name: '전기공사',
        lines: [
          EstimateLine(
            name: '전기 인입',
            spec: '내부 신설 전기 배선',
            unit: '식',
            material: 2750000,
            labor: 2450000,
          ),
          EstimateLine(
            name: '통신 네트워크',
            unit: '식',
            material: 350000,
            labor: 200000,
          ),
          EstimateLine(
            name: '내부 콘센트 및 스위치',
            spec: '스위치 회로 분리',
            unit: '식',
            material: 750000,
            labor: 550000,
          ),
          EstimateLine(
            name: '조명 설치',
            labor: 1150000,
            materials: [
              EstimateMaterial(
                name: 'COB 조명',
                spec: '3인치 주백색',
                unit: '식',
                amount: 1650000,
              ),
            ],
          ),
          EstimateLine(
            name: '조명 기구부품 외',
            labor: 650000,
            materials: [
              EstimateMaterial(
                name: '조명 기구부품',
                quantity: '16',
                unit: 'EA',
                amount: 850000,
              ),
            ],
          ),
          EstimateLine(
            name: '분전함 신규 및 정리',
            unit: '식',
            material: 1350000,
            labor: 750000,
          ),
          EstimateLine(name: '기타 잡비', unit: '식', material: 350000),
        ],
      ),
      EstimateTrade(name: '소방공사'),
      EstimateTrade(
        name: '위생설비',
        lines: [
          EstimateLine(
            name: '수도배수인입',
            spec: '13평',
            unit: '식',
            material: 1450000,
            labor: 1250000,
          ),
          EstimateLine(
            name: '바닥몰탈단올림',
            spec: '150',
            unit: '식',
            material: 2750000,
            labor: 1250000,
          ),
          EstimateLine(
            name: '방수액 및 도막방수',
            spec: '13평',
            unit: '식',
            material: 850000,
            labor: 700000,
          ),
          EstimateLine(
            name: '그리스트랩 및 트렌치',
            spec: '3EA',
            unit: '식',
            material: 1150000,
            labor: 650000,
          ),
          EstimateLine(name: '기타 잡비 및 양중', material: 350000, labor: 550000),
        ],
      ),
      EstimateTrade(
        name: '타일공사',
        lines: [
          EstimateLine(
            name: '홀 데코타일',
            labor: 950000,
            materials: [
              EstimateMaterial(
                name: '데코타일',
                spec: '600×600',
                quantity: '45',
                unit: '평',
                amount: 1950000,
              ),
            ],
          ),
          EstimateLine(
            name: '주방 바닥 타일',
            labor: 950000,
            materials: [
              EstimateMaterial(
                name: '바닥 타일',
                spec: '300×300',
                quantity: '10',
                unit: '평',
                amount: 1250000,
              ),
            ],
          ),
          EstimateLine(
            name: '주방 벽타일',
            labor: 1150000,
            materials: [
              EstimateMaterial(
                name: '벽타일',
                spec: '300×300',
                quantity: '40',
                unit: '평',
                amount: 1550000,
              ),
            ],
          ),
          EstimateLine(
            name: '주방 바닥 주꾸미 시공',
            labor: 550000,
            materials: [
              EstimateMaterial(
                name: '바닥 타일',
                spec: '300×300',
                quantity: '5',
                unit: '평',
                amount: 450000,
              ),
            ],
          ),
        ],
      ),
      EstimateTrade(
        name: '도장공사',
        lines: [
          EstimateLine(
            name: '퍼티 작업',
            spec: '높이 3000',
            unit: '식',
            material: 650000,
            labor: 1550000,
          ),
          EstimateLine(
            name: '내부 전체 스타코 도장',
            spec: '높이 3000',
            unit: '식',
            material: 750000,
            labor: 850000,
          ),
          EstimateLine(name: '천장 및 벽체 수성도료', material: 1850000, labor: 1250000),
          EstimateLine(
            name: '기타 부재료',
            spec: '퍼티, 프라이머, 장비',
            unit: '식',
            material: 350000,
            labor: 500000,
          ),
          EstimateLine(name: '기타 보양', spec: '스프링클러 등 소방', unit: '식'),
        ],
      ),
      EstimateTrade(
        name: '경비',
        lines: [
          EstimateLine(name: '각종 철물 및 부재료', unit: '식', material: 750000),
          EstimateLine(name: '식대 및 경비', unit: '식', material: 2450000),
          EstimateLine(name: '자재 운반비', unit: '식', material: 750000),
          EstimateLine(
            name: '현장 정리 및 폐기물',
            spec: '2.5t',
            unit: '식',
            material: 850000,
            labor: 350000,
          ),
        ],
      ),
      EstimateTrade(
        name: '기타시공',
        lines: [
          EstimateLine(
            name: '룸 넘버 아크릴 스카시',
            unit: '식',
            material: 280000,
            labor: 100000,
          ),
          EstimateLine(
            name: '카운터 로고 스카시',
            unit: '식',
            material: 150000,
            labor: 700000,
          ),
          EstimateLine(
            name: '주방 벽 천장 단 로고 스카시',
            unit: '식',
            material: 380000,
            labor: 100000,
          ),
          EstimateLine(name: '외부 잔디', spec: '1롤 2미터, 부재료 포함'),
          EstimateLine(name: '외부 어닝', spec: '4개', material: 1850000),
          EstimateLine(name: '외부 간판', spec: '파나플렉스', material: 1650000),
          EstimateLine(
            name: '덕트 시공',
            spec: '옥외 인입, 후드 포함, 주방',
            material: 2850000,
          ),
          EstimateLine(
            name: '외부 유리창 시트',
            spec: '외부 창문',
            material: 1250000,
            labor: 850000,
          ),
        ],
      ),
    ],
  ),
  judgments: [
    QuoteJudgment(
      conclusion: '전기 증설은 따로 청구해요',
      customerNote: '조명과 장비를 지금보다 늘리고 싶어요.',
      staffNote: '증설은 검사 대상이라 이번 전기공사 금액에 넣지 않았어요. 용량이 정해지면 금액을 다시 적어요.',
      effect: PriceEffect.extra,
      tradeName: '전기공사',
    ),
    QuoteJudgment(
      conclusion: '도면이 바뀌면 공사비도 다시 봐요',
      customerNote: '시안을 보고 방 구성과 마감을 고르고 싶어요.',
      staffNote: '배치나 마감이 바뀌면 목공, 필름, 도장 수량이 달라져요. 고친 뒤 견적을 다시 맞춰요.',
      effect: PriceEffect.mayChange,
    ),
    QuoteJudgment(
      conclusion: '사인·가구·에어컨은 이번 금액에 없어요',
      customerNote: '간판이랑 에어컨도 같이 보면 좋겠어요.',
      staffNote: '사인, 가구, 주방기구, 도시가스, 에어컨, 소품은 이번 견적에서 빼 뒀어요. 진행하면 항목이 추가돼요.',
      effect: PriceEffect.leftOut,
    ),
    QuoteJudgment(
      conclusion: '룸과 카운터는 목공에 포함해요',
      customerNote: '룸을 나누고 카운터에서 주문이 보이게 하고 싶어요.',
      staffNote: '가벽, 룸 도어, 카운터, 바테이블을 목공공사로 잡았어요. 상담에서 말한 배치가 이 금액의 기준이에요.',
      effect: PriceEffect.included,
      tradeName: '목공공사',
    ),
  ],
  documents: [
    ProjectDocument(
      kind: ProjectDocumentKind.estimate,
      title: '견적서',
      note: '공사항목과 금액',
      fileName: '화성 중식당 견적서 최종.xlsx',
      ready: true,
    ),
    ProjectDocument(
      kind: ProjectDocumentKind.proposal,
      title: '제안서',
      note: '평면도 4안 · 10장',
      fileName: '동탄 영어학원_제안서_1016.pdf',
      ready: true,
    ),
    ProjectDocument(
      kind: ProjectDocumentKind.model,
      title: '3D 도면',
      note: '도착하면 여기에서 봐요',
    ),
    ProjectDocument(
      kind: ProjectDocumentKind.draft,
      title: '공사시안',
      note: '도착하면 여기에서 봐요',
    ),
  ],
  proposalPages: [
    ProposalPage(title: '표지', caption: '제안서'),
    ProposalPage(title: '평면도 1', caption: '첫 번째 배치'),
    ProposalPage(title: '아이소 1', caption: '첫 번째 공간'),
    ProposalPage(title: '평면도 2', caption: '두 번째 배치'),
    ProposalPage(title: '아이소 2', caption: '두 번째 공간'),
    ProposalPage(title: '평면도 3', caption: '세 번째 배치'),
    ProposalPage(title: '아이소 3', caption: '세 번째 공간'),
    ProposalPage(title: '평면도 4', caption: '네 번째 배치'),
    ProposalPage(title: '아이소 4', caption: '네 번째 공간'),
    ProposalPage(title: '마무리', caption: '디자인웜하트'),
  ],
);
