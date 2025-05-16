
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common/app_color.dart';

class TicketDetailSkeleton extends StatelessWidget {
  const TicketDetailSkeleton({super.key});

  Widget skeletonBox({double height = 20, double width = double.infinity, BorderRadius? borderRadius}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColorList.Skeleton_color,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorList.Skeleton_color,
      highlightColor: AppColorList.Skeleton_color1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColorList.WhiteText,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  skeletonBox(height: 24, width: 120),
                  const SizedBox(height: 8),
                  skeletonBox(height: 18, width: 200),
                ],
              ),
            ),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColorList.WhiteText,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: skeletonBox(height: 16, width: double.infinity),
                  );
                }),
              ),
            ),

            // Expandable Sections
            ...List.generate(3, (_) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorList.WhiteText,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    skeletonBox(height: 18, width: 150),
                    const SizedBox(height: 8),
                    skeletonBox(height: 14, width: double.infinity),
                    const SizedBox(height: 6),
                    skeletonBox(height: 14, width: double.infinity),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}