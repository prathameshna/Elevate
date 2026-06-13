import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton loading state for the dashboard.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShimmerBox(width: 180, height: 28, radius: 8),
                _ShimmerBox(width: 36, height: 36, radius: 18),
              ],
            ),
            const SizedBox(height: 20),
            _ShimmerBox(width: double.infinity, height: 80, radius: 16),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 90, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _ShimmerBox(height: 90, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 90, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _ShimmerBox(height: 90, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(flex: 3, child: _ShimmerBox(height: 140, radius: 16)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _ShimmerBox(height: 140, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            _ShimmerBox(width: double.infinity, height: 110, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({
    this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
