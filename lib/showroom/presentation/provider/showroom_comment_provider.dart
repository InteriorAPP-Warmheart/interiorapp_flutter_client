import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/data/repository/showroom_comment_repository_impl.dart';
import 'package:interiorapp_flutter_client/showroom/data/source/showroom_comment_api.dart';
import 'package:interiorapp_flutter_client/showroom/domain/use_case/showroom_comment_use_case.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_comment_vm.dart';

final showroomCommentApiProvider = Provider((ref) => ShowroomCommentApi());

final showroomCommentRepositoryProvider = Provider((ref) {
  return ShowroomCommentRepositoryImpl(ref.read(showroomCommentApiProvider));
});

final showroomCommentUseCaseProvider = Provider((ref) {
  return ShowroomCommentUseCase(ref.read(showroomCommentRepositoryProvider));
});

final showroomCommentProvider =
    NotifierProvider<ShowroomCommentVm, ShowroomCommentBoard>(
      ShowroomCommentVm.new,
    );
