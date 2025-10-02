import 'dart:math';
import 'package:flutter/material.dart';

enum CategoryType { self, outsourcing }

class CategoryCardWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;
  final CategoryType type;
  final bool isExpanded;
  final VoidCallback? onTap;

  const CategoryCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.type,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  State<CategoryCardWidget> createState() => _CategoryCardWidgetState();
}

class _CategoryCardWidgetState extends State<CategoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(CategoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward(from: 0); // 회전 시작
      } else {
        _controller.reset();
      }
    }
  }

  void _onTap() {
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Hero(
        tag: 'category_${widget.type}',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * pi; // 0 ~ π
            final isFront = angle < pi / 2;

            Widget cardContent = Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isFront
                  ? _buildFront()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBack(),
                    ),
            );

            // 확장된 카드일 때는 화면 중앙에 배치
            if (widget.isExpanded) {
              return Stack(
                children: [
                  // 원래 위치의 투명한 플레이스홀더 (그리드 레이아웃 유지)
                  Opacity(
                    opacity: 0.0,
                    child: cardContent,
                  ),
                  // 화면 중앙에 표시되는 확장된 카드
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Transform.scale(
                          scale: 1.3, // 다이얼로그 크기로 확대
                          child: cardContent,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // 일반 상태에서는 그리드 내에서 표시
            return cardContent;
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 48, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Card(
      color: Colors.blueGrey,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
