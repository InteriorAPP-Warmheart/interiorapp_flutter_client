import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/space_project_card.dart';

class OngoingSpacePager extends StatefulWidget {
  const OngoingSpacePager({
    super.key,
    required this.projects,
    required this.onTap,
  });

  final List<SpaceProject> projects;
  final ValueChanged<SpaceProject> onTap;

  @override
  State<OngoingSpacePager> createState() => _OngoingSpacePagerState();
}

class _OngoingSpacePagerState extends State<OngoingSpacePager> {
  PageController? _controller;
  int _index = 0;

  bool get _canSwipe => widget.projects.length > 1;

  @override
  void initState() {
    super.initState();
    if (_canSwipe) {
      _controller = PageController(viewportFraction: 0.9);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projects.isEmpty) return const SizedBox.shrink();

    if (!_canSwipe) {
      final SpaceProject project = widget.projects.first;
      return SpaceProjectCard(
        project: project,
        onTap: () => widget.onTap(project),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.projects.length,
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (BuildContext context, int index) {
              final SpaceProject project = widget.projects[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.projects.length - 1 ? 0 : 12,
                ),
                child: SpaceProjectCard(
                  project: project,
                  onTap: () => widget.onTap(project),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.projects.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFD5D5D5),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
