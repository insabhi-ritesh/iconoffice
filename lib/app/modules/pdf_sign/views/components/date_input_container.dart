import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../controllers/pdf_sign_controller.dart';
import 'input_container.dart';

class DateInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const DateInputContainer({super.key, required this.controller});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formattedDate = DateFormat('dd.MM.yyyy').format(picked);
      controller.selectedDate.value = formattedDate;
      controller.dateError.value = '';
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
          const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              constraints: const BoxConstraints(minWidth: 200), // Ensure enough width for full date
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.dateError.value.isEmpty ? Colors.grey : Colors.red,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() =>
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedDate.value.isNotEmpty
                            ? controller.selectedDate.value
                            : 'Select a date',
                        style: TextStyle(
                          color: controller.selectedDate.value.isNotEmpty ? Colors.black : Colors.grey,
                          overflow: TextOverflow.visible,
                          fontSize: AppFontSize.size5, // Ensure consistent font size for full date display
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.green),
                  ],
                ),
              ),
            ),
          ),
          if (controller.dateError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                controller.dateError.value,
                style: TextStyle(color: AppColorList.Star3, fontSize: AppFontSize.size5),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.clearFieldSelection(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => controller.prepareToPlaceField(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorList.Star1,
                  foregroundColor: AppColorList.WhiteText,
                ),
                child: const Text('Place on Document'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}