import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/showroom_tab/presentation/provider/showroom_write_provider.dart';

class ShowroomWriteScreen extends ConsumerWidget {
  const ShowroomWriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentBuildings = ref.watch(showroomWriteProvider);
    final hasData = ref.watch(showroomDataToggleProvider);
    final scrollController = ref.watch(showroomScrollControllerProvider);
    final selectedBuildId = ref.watch(selectedBuildIdProvider);

    // 데이터가 변경될 때만 스크롤을 맨 위로 이동
    ref.listen(showroomWriteProvider, (previous, next) {
      next.whenData((data) {
        if (data.isNotEmpty) {
          // ListView가 완전히 렌더링된 후 스크롤 이동
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                // reverse: true일 때는 최대 스크롤 위치가 맨 위 (최신 데이터)
                final maxScroll = scrollController.position.maxScrollExtent;
                scrollController.jumpTo(maxScroll);
              }
            });
          });
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(hasData ? '쇼룸 글쓰기(시공했던 데이터O)' : '쇼룸 글쓰기(시공했던 데이터X)'),
        actions: [
          // 스위치로 데이터 표시 상태 토글
          Switch(
            value: hasData,
            onChanged: (value) {
              ref.read(showroomDataToggleProvider.notifier).setValue(value);
            },
          ),
        ],
      ),
      body:
      // 쇼룸 데이터가 있을때와 없을 때 조건 처리
      recentBuildings.when(
        data: (data) {
          print(
            '데이터 상태: ${data.length}개, isEmpty: ${data.isEmpty}, hasData: $hasData',
          );

          return data.isNotEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '최근 시공한 내역들이에요',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: data.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 5,
                              ),
                              child: Container(
                                height: 72,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Radio<String?>(
                                      value: data[index]['id'],
                                      groupValue: selectedBuildId,
                                      onChanged: (value) {
                                        ref
                                            .read(
                                              selectedBuildIdProvider.notifier,
                                            )
                                            .select(value);
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.network(
                                            data[index]['buildImage'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      color: Colors.grey[300]!,
                                                      child: Icon(
                                                        Icons.broken_image,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          data[index]['buildName'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          data[index]['buildPeriod'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // button section
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: (selectedBuildId?.isNotEmpty ?? false)
                                ? () => context.push(
                                      '/showroom-write/first-write?buildId=$selectedBuildId',
                                    )
                                : null,
                            child: const Text(
                              '선택된 데이터로 쇼룸 작성하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 30),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                () =>
                                    context.push('/showroom-write/first-write'),
                            child: const Text(
                              '직접 작성하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '최근 시공한 내역이\n없어요',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build),
                            SizedBox(height: 10),
                            Text('그래픽 들어갈 영역'),
                          ],
                        ),
                      ),
                      // button section
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  side: BorderSide(color: Colors.grey[200]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  '시공 예상 견적 확인하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 30),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed:
                                    () => context.push(
                                      '/showroom-write/first-write',
                                    ),

                                child: const Text(
                                  '직접 작성하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
        },
        error: (error, stackTrace) {
          return Center(child: Text('쇼룸 데이터 로딩 중 오류가 발생했습니다.'));
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
