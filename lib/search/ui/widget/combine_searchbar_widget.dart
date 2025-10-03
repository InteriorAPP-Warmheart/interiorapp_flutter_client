import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/components/components_widget/app_searchbar.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/search_provider.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/recent_search_history_provider.dart';

class CombineSearchbarWidget extends ConsumerStatefulWidget {
  const CombineSearchbarWidget({
    super.key,
    this.focusNode,
    this.initialValue,
    this.useGlobalController = false,
    this.onQueryChanged,
  });

  final FocusNode? focusNode;
  final String? initialValue;
  final bool useGlobalController; // 전역 컨트롤러 사용 여부
  final void Function(String query)? onQueryChanged;

  @override
  ConsumerState<CombineSearchbarWidget> createState() => _CombineSearchbarWidgetState();
}

class _CombineSearchbarWidgetState extends ConsumerState<CombineSearchbarWidget> {
  TextEditingController? _localController;

  @override
  void initState() {
    super.initState();
    // 전역 컨트롤러를 사용하지 않는 경우에만 로컬 컨트롤러 생성
    if (!widget.useGlobalController) {
      _localController = TextEditingController();
      
      // 초기값이 있으면 컨트롤러에 설정
      if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
        _localController!.text = widget.initialValue!;
      }
      
      // 로컬 컨트롤러에 리스너 추가
      _localController!.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    final controller = widget.useGlobalController 
        ? ref.read(searchProvider.notifier).searchController
        : _localController!;
    
    widget.onQueryChanged?.call(controller.text);
  }

  @override
  void didUpdateWidget(CombineSearchbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // initialValue가 변경되었을 때 컨트롤러 업데이트
    if (widget.initialValue != oldWidget.initialValue && 
        widget.initialValue != null && 
        widget.initialValue!.isNotEmpty) {
      if (!widget.useGlobalController && _localController != null) {
        _localController!.text = widget.initialValue!;
      }
    }
  }

  @override
  void dispose() {
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 선택
    final controller = widget.useGlobalController 
        ? ref.watch(searchProvider.notifier).searchController
        : _localController!;

    // 전역 컨트롤러를 사용하는 경우 텍스트 변경 감지
    if (widget.useGlobalController) {
      ref.listen(searchProvider, (previous, next) {
        widget.onQueryChanged?.call(next);
      });
    }

    return AppSearchBar(
      widthRatio: 0.75,  // 화면 너비의 75%
      heightRatio: 0.05, // 화면 높이의 5%
      controller: controller,
      focusNode: widget.focusNode,
      onSubmitted: (value) async {
        if (value.trim().isNotEmpty) {
          // 최근 검색어에 저장
          await ref.read(recentSearchHistoryUseCaseProvider).saveSearchKeyword(value.trim());
          // 검색 결과 페이지로 이동
          if(context.mounted) {
            context.push('/search/result?q=$value');
          }
        }
      },
      hintText: '검색어를 입력하세요',
      onClear: () {
        if (widget.useGlobalController) {
          ref.read(searchProvider.notifier).clear();
        } else {
          _localController?.clear();
        }
      },
    );
  }
}
