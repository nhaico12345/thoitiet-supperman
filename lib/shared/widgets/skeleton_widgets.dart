// Các widget skeleton loading với hiệu ứng shimmer.
// Bao gồm SkeletonBox, SkeletonText và SkeletonCircle cho placeholder.

import 'package:flutter/material.dart';

// Base skeleton box widget with shimmer animation
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFF3A3A3A),
                Color(0xFF4A4A4A),
                Color(0xFF5A5A5A),
                Color(0xFF4A4A4A),
                Color(0xFF3A3A3A),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// Skeleton text placeholder with configurable lines
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final int lines;
  final double spacing;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.lines = 1,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return SkeletonBox(width: width, height: height, borderRadius: 4);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        // Last line is usually shorter
        final lineWidth = index == lines - 1 ? width * 0.7 : width;
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: SkeletonBox(width: lineWidth, height: height, borderRadius: 4),
        );
      }),
    );
  }
}

// Skeleton circle for avatars/icons
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SkeletonBox(width: size, height: size, borderRadius: size / 2),
    );
  }
}
