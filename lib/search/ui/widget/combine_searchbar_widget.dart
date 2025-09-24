import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/components/components_widget/app_searchbar.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/search_provider.dart';

class CombineSearchbarWidget extends ConsumerWidget {
  const CombineSearchbarWidget({
    super.key,
    this.focusNode,
  });

  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSearchBar(
      widthRatio: 0.75,  // 화면 너비의 75%
      heightRatio: 0.05, // 화면 높이의 5%
      controller: ref.watch(searchProvider.notifier).searchController,
      focusNode: focusNode,
      onSubmitted: (value) {
        context.push('/search/result?q=$value');
      },
      hintText: '검색어를 입력하세요',
      onClear: () => ref.read(searchProvider.notifier).clear(),
    );
  }
}
