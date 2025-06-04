import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../controllers/pdf_sign_controller.dart';
import 'input_container.dart';

class DateTimeInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const DateTimeInputContainer({super.key, required this.controller});

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          controller.selectedDateTime.value ?? DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        controller.selectedDateTime.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        log('Selected DateTime: ${controller.selectedDateTime.value}');
        controller.dateTimeError.value = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: inputContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDateTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.dateTimeError.value.isEmpty ? AppColorList.MainShadow : AppColorList.Star3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(()
                => Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedDateTime.value != null
                            ? DateFormat('yyyy-MM-dd HH:mm').format(controller.selectedDateTime.value!)
                            : 'Select date and time',
                        style: TextStyle(
                          color: controller.selectedDateTime.value != null ? AppColorList.AppText : AppColorList.MainShadow,
                        ),
                      ),
                    ),
                    Icon(Icons.access_time, color: AppColorList.Purple),
                  ],
                ),
              ),
            ),
          ),
          if (controller.dateTimeError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                controller.selectedDateTime.value != null ?
                controller.dateTimeError.value
                : controller.dateTimeError.value,
                style: TextStyle(color: AppColorList.Star3, fontSize: AppFontSize.size5),
              ),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (controller.selectedDateTime.value != null) {
                  controller.dateTimePosition.value = Offset(
                    MediaQuery.of(context).size.width / 2 - 90,
                    MediaQuery.of(context).size.height / 2 - 20,
                  );
                  controller.prepareToPlaceField();
                } else {
                  controller.dateTimeError.value = 'Please select a date and time';
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorList.Purple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Place on Document',
                style: TextStyle(
                  color: AppColorList.WhiteText,
                  fontWeight: AppFontWeight.font6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}