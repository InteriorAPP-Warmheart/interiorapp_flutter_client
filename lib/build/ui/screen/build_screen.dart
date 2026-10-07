import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/finished_space_tile.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/interior_prep_card.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/ongoing_space_pager.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class BuildScreen extends StatelessWidget {
  const BuildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<SpaceProject> finished = SpaceCatalog.finished;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: Padding(
        padding: EdgeInsets.fromLTRB(padding.left, 12, padding.right, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OngoingSpacePager(
                projects: SpaceCatalog.ongoing,
                onTap: (SpaceProject project) {
                  context.push(SpaceRoutes.detail(project.id));
                },
              ),
            ),
            if (finished.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '마친 공간',
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 112,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    const double gap = 10;
                    final int count = finished.length;
                    final double width = count <= 2
                        ? (constraints.maxWidth - gap * (count - 1)) / count
                        : (constraints.maxWidth - gap) / 2.2;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: count <= 2
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: count,
                      separatorBuilder: (context, index) => const SizedBox(width: gap),
                      itemBuilder: (BuildContext context, int index) {
                        final SpaceProject project = finished[index];
                        return SizedBox(
                          width: width,
                          child: FinishedSpaceTile(
                            project: project,
                            onTap: () => context.push(SpaceRoutes.detail(project.id)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            InteriorPrepEntry(
              prep: SpaceCatalog.prep,
              onTap: () => context.push(SpaceRoutes.prep),
            ),
          ],
        ),
      ),
    );
  }
}
