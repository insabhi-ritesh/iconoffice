
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart' show SfPdfViewer;
import 'package:intl/intl.dart';

import '../../../models/input_field.dart';
import '../controllers/pdf_sign_controller.dart';

class PdfSignView extends GetView<PdfSignController> {
  const PdfSignView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PdfSignController());
    final args = Get.arguments as Map<String, dynamic>?;
    final String? pdfPath = args?['pdfPath'] ?? controller.pdfPath.value;
    final String pdfName = args?['pdfName'] ?? 'Document';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign: $pdfName',
          style: TextStyle(
            fontWeight: AppFontWeight.font7,
            color: AppColorList.WhiteText,
            fontSize: AppFontSize.size4,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColorList.AppButtonColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: AppColorList.WhiteText,
              size: AppFontSize.sizeLarge,
            ),
            onPressed: () async {
              await controller.saveAndUploadSignedPdf(context, pdfPath ?? '', pdfName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FieldSelectionRow(controller: controller),
          Obx(() => controller.isEditingField.value
            ? Flexible(
                child: SingleChildScrollView(
                  child: _FieldInputContainer(controller: controller),
                ),
              )
            : const SizedBox.shrink()),
          Expanded(
            child: Obx(() => GestureDetector(
                  onTapUp: controller.isPlacingField.value
                      ? (details) => controller.placeFieldAt(details.localPosition)
                      : null,
                  child: Stack(
                    children: [
                      _PdfWidget(pdfPath: pdfPath, controller: controller),
                      ..._buildPlacedFields(controller),
                      if (controller.isPlacingField.value)
                        _InstructionOverlay(),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlacedFields(PdfSignController controller) {
    return [
      ...controller.placedTextFields
          .map((field) => _DraggableField(
                controller: controller,
                field: field,
                type: FieldType.text,
                color: AppColorList.OpacityBlue,
                borderColor: AppColorList.blue,
                child: Text(
                  field.value as String,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
      ...controller.placedDateFields
          .map((field) => _DraggableField(
                controller: controller,
                field: field,
                type: FieldType.date,
                color: AppColorList.OpacityGreen,
                borderColor: AppColorList.Star1,
                child: Text(
                  field.value as String,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
      ...controller.placedDateTimeFields
          .map((field) => _DraggableField(
                controller: controller,
                field: field,
                type: FieldType.dateTime,
                color: AppColorList.OpacityPurple,
                borderColor: AppColorList.Purple,
                child: Text(
                  field.value as String,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
      ...controller.placedSignatureFields
          .map((field) => _DraggableField(
                controller: controller,
                field: field,
                type: FieldType.signature,
                color: AppColorList.OpacityRed,
                borderColor: AppColorList.Star3,
                child: Image.memory(field.value as Uint8List),
              )),
    ];
  }
}

class _PdfWidget extends StatelessWidget {
  final String? pdfPath;
  final PdfSignController controller;
  const _PdfWidget({required this.pdfPath, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (pdfPath == null || pdfPath!.isEmpty) {
      return const Center(child: Text('No PDF path provided'));
    } else if (pdfPath!.startsWith('http')) {
      return SfPdfViewer.network(
        pdfPath!,
        controller: controller.pdfViewerController,
        onPageChanged: (details) => controller.currentPage.value = details.newPageNumber,
      );
    } else {
      final file = File(pdfPath!);
      return file.existsSync()
          ? SfPdfViewer.file(file, controller: controller.pdfViewerController)
          : Center(child: Text('PDF not found: $pdfPath'));
    }
  }
}

class _FieldSelectionRow extends StatelessWidget {
  final PdfSignController controller;
  const _FieldSelectionRow({required this.controller});

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
          _FieldButton(
            controller: controller,
            icon: Icons.edit,
            label: 'Text',
            fieldType: FieldType.text,
            color: AppColorList.blue,
          ),
          _FieldButton(
            controller: controller,
            icon: Icons.calendar_today,
            label: 'Date',
            fieldType: FieldType.date,
            color: AppColorList.Star1,
          ),
          _FieldButton(
            controller: controller,
            icon: Icons.access_time,
            label: 'Date & Time',
            fieldType: FieldType.dateTime,
            color: AppColorList.Purple,
          ),
          _FieldButton(
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

class _FieldButton extends StatelessWidget {
  final PdfSignController controller;
  final IconData icon;
  final String label;
  final FieldType fieldType;
  final Color color;

  const _FieldButton({
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

class _FieldInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const _FieldInputContainer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.selectedFieldType.value) {
        case FieldType.text:
          return _TextInputContainer(controller: controller);
        case FieldType.date:
          return _DateInputContainer(controller: controller);
        case FieldType.dateTime:
          return _DateTimeInputContainer(controller: controller);
        case FieldType.signature:
          return _SignatureInputContainer(controller: controller);
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

class _TextInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const _TextInputContainer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _inputContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Text',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.textController,
            decoration: InputDecoration(
              hintText: 'Enter your text here',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: controller.textError.value.isEmpty ? null : controller.textError.value,
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
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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

class _DateInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const _DateInputContainer({required this.controller});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.dateError.value = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _inputContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.dateError.value.isEmpty ? Colors.grey : Colors.red,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedDate.value != null
                          ? DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!)
                          : 'Select a date',
                      style: TextStyle(
                        color: controller.selectedDate.value != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.green),
                ],
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

class _DateTimeInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const _DateTimeInputContainer({required this.controller});

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
        controller.dateTimeError.value = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _inputContainerDecoration(),
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
              child: Row(
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
          if (controller.dateTimeError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                controller.dateTimeError.value,
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
                  controller.dateTimeError.value = '';
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
                'Add to Document',
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

class _SignatureInputContainer extends StatelessWidget {
  final PdfSignController controller;
  const _SignatureInputContainer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _inputContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Draw Signature', style: TextStyle(fontWeight: AppFontWeight.font6, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppColorList.MainShadow),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Signature(
                controller: controller.signatureController,
                backgroundColor: AppColorList.WhiteText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => controller.signatureController.clear(),
                icon: Icon(Icons.refresh, color: AppColorList.Star1),
                label: Text('Clear', style: TextStyle(color: AppColorList.Star1)),
              ),
              Row(
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
        ],
      ),
    );
  }
}

class _DraggableField extends StatelessWidget {
  final PdfSignController controller;
  final PlacedField field;
  final FieldType type;
  final Color color;
  final Color borderColor;
  final Widget child;

  const _DraggableField({
    required this.controller,
    required this.field,
    required this.type,
    required this.color,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // If field.size is not observable, remove Obx here
    final Size size = field.size;
    return Positioned(
      left: field.position.dx,
      top: field.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          controller.updateFieldPosition(field, details.delta);
        },
        onLongPress: () {
          controller.removeField1(field, type);
        },
        child: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: child,
            ),
            // Resize handle (bottom-right corner)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  // Minimum size
                  const double minWidth = 40;
                  const double minHeight = 24;
                  // Maximum size (optional)
                  const double maxWidth = 400;
                  const double maxHeight = 200;
                  final newWidth = math.max(minWidth, math.min(size.width + details.delta.dx, maxWidth));
                  final newHeight = math.max(minHeight, math.min(size.height + details.delta.dy, maxHeight));
                  controller.updateFieldSize(field, Size(newWidth, newHeight));
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColorList.WhiteText,
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Icon(Icons.open_in_full, size: 14, color: AppColorList.MainShadow),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionOverlay extends StatelessWidget {
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

BoxDecoration _inputContainerDecoration() => BoxDecoration(
      color: AppColorList.WhiteText,
      boxShadow: [
        BoxShadow(
          color: AppColorList.OpacityBlack,
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
