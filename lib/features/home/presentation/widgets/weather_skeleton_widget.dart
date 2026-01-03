// Widget skeleton loading toàn màn hình khi đang tải thời tiết.
// Mô phỏng layout thực với shimmer cho nhiệt độ, dự báo giờ/ngày, và grid.

import 'package:flutter/material.dart';
import '../../../../shared/widgets/skeleton_widgets.dart';

class WeatherSkeletonWidget extends StatelessWidget {
  const WeatherSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildMainWeatherSkeleton(context),
              const SizedBox(height: 24),
              _buildHourlyForecastSkeleton(),
              const SizedBox(height: 24),
              _buildDailyForecastSkeleton(),
              const SizedBox(height: 24),
              _buildEnvironmentalSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainWeatherSkeleton(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SkeletonCircle(size: 80),
          const SizedBox(height: 16),
          const SkeletonBox(width: 150, height: 60, borderRadius: 12),
          const SizedBox(height: 12),
          const SkeletonText(width: 120, height: 18),
          const SizedBox(height: 8),
          const SkeletonText(width: 100, height: 14),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonText(width: 140, height: 18),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SkeletonText(width: 40, height: 12),
                    SkeletonCircle(size: 30),
                    SkeletonText(width: 35, height: 14),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonText(width: 160, height: 18),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonText(width: 60, height: 14),
                SkeletonCircle(size: 30),
                SkeletonText(width: 80, height: 14),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEnvironmentalSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonText(width: 120, height: 18),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: List.generate(4, (index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonText(width: 60, height: 12),
                  SkeletonText(width: 50, height: 24),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
