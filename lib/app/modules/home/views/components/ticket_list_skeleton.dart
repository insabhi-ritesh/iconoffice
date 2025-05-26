import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../common/app_color.dart';

class TicketListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const TicketListSkeleton({
    super.key, 
    this.itemCount = 5,
    this.shrinkWrap = false,
    this.physics  
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColorList.Skeleton_color,
          highlightColor: AppColorList.Skeleton_color1,
          direction: ShimmerDirection.ltr,
          period: const Duration(milliseconds: 1200),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ticket number skeleton
                    Container(
                      width: 80,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColorList.WhiteText,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Priority stars skeleton
                    Container(
                      width: 63,
                      height: 25,
                      decoration: BoxDecoration(
                        color: AppColorList.WhiteText,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 0.5, color: AppColorList.Skeleton_color),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Ticket Title
                    Row(
                      children: [
                        Container(
                          width: 90,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColorList.WhiteText,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColorList.WhiteText,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Partner Name
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColorList.WhiteText,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(
                          width: 8
                        ),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColorList.WhiteText,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Status
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColorList.WhiteText,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColorList.WhiteText,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}