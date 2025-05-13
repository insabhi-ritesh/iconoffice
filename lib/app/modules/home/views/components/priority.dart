
import 'package:flutter/material.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';

class PriorityStars extends StatelessWidget {
  final int priority; 

  const PriorityStars({super.key, required this.priority});

  Color _getStarColor(int clampedPriority) {
    switch (clampedPriority) {
      case 0:
        return AppColorList.Star1;
      case 1:
        return AppColorList.Star2;
      case 2:
        return AppColorList.Star3;
      default:
        return AppColorList.MainShadow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clamp priority between 0 and 2
    final int clampedPriority = priority.clamp(0, 2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < clampedPriority + 1 ? Icons.star : Icons.star_border,
          color: _getStarColor(clampedPriority),
          size: 18,
        );
      }),
    );
  }
}
