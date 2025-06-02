
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/app_color.dart';
import '../../controllers/pdf_sign_controller.dart';

class FieldSelectionRow extends StatelessWidget {
  final PdfSignController controller;
  const FieldSelectionRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColorList.WhiteText,
        boxShadow: [
          BoxShadow(
            color: AppColorList.OpacityBlack,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FieldButton(
            controller: controller,
            icon: Icons.edit,
            label: 'Text',
            fieldType: FieldType.text,
            color: AppColorList.blue,
          ),
          FieldButton(
            controller: controller,
            icon: Icons.calendar_today,
            label: 'Date',
            fieldType: FieldType.date,
            color: AppColorList.Star1,
          ),
          FieldButton(
            controller: controller,
            icon: Icons.access_time,
            label: 'Date & Time',
            fieldType: FieldType.dateTime,
            color: AppColorList.Purple,
          ),
          FieldButton(
            controller: controller,
            icon: Icons.draw,
            label: 'Signature',
            fieldType: FieldType.signature,
            color: AppColorList.Star3,
          ),
        ],
      ),
    );
  }
}


class FieldButton extends StatelessWidget {
  final PdfSignController controller;
  final IconData icon;
  final String label;
  final FieldType fieldType;
  final Color color;

  const FieldButton({super.key, 
    required this.controller,
    required this.icon,
    required this.label,
    required this.fieldType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedFieldType.value == fieldType;
      return InkWell(
        onTap: () => controller.selectFieldType(fieldType),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
