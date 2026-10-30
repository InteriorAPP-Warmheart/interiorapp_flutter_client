import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

class ShowroomWriteScreen extends ConsumerWidget {
  const ShowroomWriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final List<SpaceProject> active = <SpaceProject>[
      ...board.received,
      ...board.ongoing,
    ];
    final List<SpaceProject> finished = board.finished;
    final bool hasSpace = active.isNotEmpty || finished.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('쇼룸 글쓰기')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              children: [
                const Text(
                  '시공한 공간으로 시작해요',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 1.25,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '진행 중이거나 마친 공간이 있으면 조건과 현장 사진을 가져와 쓸 수 있어요. 본문은 글과 사진을 원하는 순서대로 쌓아요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (!hasSpace)
                  const _EmptySpaces()
                else ...[
                  if (active.isNotEmpty) ...[
                    const _SectionLabel('진행 중인 공간'),
                    for (final SpaceProject project in active) ...[
                      _SpaceCard(
                        project: project,
                        photoCount:
                            board
                                .constructionFor(project.id)
                                ?.recentPhotos
                                .length ??
                            0,
                        onTap:
                            () => context.push(
                              '/showroom-write/first-write?buildId=${project.id}',
                            ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                  ],
                  if (finished.isNotEmpty) ...[
                    const _SectionLabel('마친 공간'),
                    for (final SpaceProject project in finished) ...[
                      _SpaceCard(
                        project: project,
                        photoCount:
                            board
                                .constructionFor(project.id)
                                ?.recentPhotos
                                .length ??
                            0,
                        onTap:
                            () => context.push(
                              '/showroom-write/first-write?buildId=${project.id}',
                            ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ],
            ),
          ),
          const _DirectWriteBar(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.project,
    required this.photoCount,
    required this.onTap,
  });

  final SpaceProject project;
  final int photoCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: AppNetworkImage(url: project.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.statusLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (photoCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '현장 사진 $photoCount장',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySpaces extends StatelessWidget {
  const _EmptySpaces();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.apartment_outlined,
            size: 28,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            '아직 시공한 공간이 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '조건과 사진만으로도 쇼룸을 쓸 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectWriteBar extends StatelessWidget {
  const _DirectWriteBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => context.push('/showroom-write/first-write'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '직접 작성하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
