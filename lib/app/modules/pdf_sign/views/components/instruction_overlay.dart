
import 'package:flutter/material.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';

class InstructionOverlay extends StatelessWidget {
  const InstructionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColorList.OpacityBlack,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColorList.OpacityBlack7,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tap anywhere to place the field',
              style: TextStyle(
                color: AppColorList.WhiteText,
                fontSize: 16,
                fontWeight: AppFontWeight.font6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
