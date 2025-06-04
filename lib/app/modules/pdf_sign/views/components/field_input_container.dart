
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pdf_sign_controller.dart';
import 'date_input_container.dart';
import 'date_time_input_container.dart';
import 'signture_container.dart';
import 'text_input_container.dart';

class FieldInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const FieldInputContainer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.selectedFieldType.value) {
        case FieldType.text:
          return TextInputContainer(controller: controller);
        case FieldType.date:
          return DateInputContainer(controller: controller);
        case FieldType.dateTime:
          return DateTimeInputContainer(controller: controller);
        case FieldType.signature:
          return SignatureInputContainer(controller: controller);
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

