import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// High-performance lightweight Shimmer Skeleton loader for instant perceptual speed
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shapeBorder;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.shapeBorder,
  });

  const ShimmerLoading.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shapeBorder = const CircleBorder();

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
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
            borderRadius: widget.shapeBorder == null ? BorderRadius.circular(widget.borderRadius) : null,
            shape: widget.shapeBorder is CircleBorder ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                AppColors.borderLight.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.9),
                AppColors.borderLight.withValues(alpha: 0.8),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pre-composed skeleton card for list views
class ComplaintCardSkeleton extends StatelessWidget {
  const ComplaintCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 110, height: 22, borderRadius: 6),
              ShimmerLoading(width: 80, height: 22, borderRadius: 6),
            ],
          ),
          SizedBox(height: 14),
          ShimmerLoading(width: double.infinity, height: 16, borderRadius: 4),
          SizedBox(height: 8),
          ShimmerLoading(width: 220, height: 14, borderRadius: 4),
          SizedBox(height: 16),
          Row(
            children: [
              ShimmerLoading.circular(size: 24),
              SizedBox(width: 8),
              ShimmerLoading(width: 100, height: 12, borderRadius: 4),
              Spacer(),
              ShimmerLoading(width: 60, height: 12, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
