import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/components/components_widget/app_searchbar.dart';

class CombineSearchbarWidget extends ConsumerWidget {
  const CombineSearchbarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSearchBar();
  }
}
