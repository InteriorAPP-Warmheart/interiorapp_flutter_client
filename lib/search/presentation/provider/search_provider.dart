import 'package:flutter_riverpod/legacy.dart';
import 'package:interiorapp_flutter_client/search/presentation/vm/search_vm.dart';

final searchProvider = StateNotifierProvider<SearchNotifier, String>((ref) => SearchNotifier());