import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart' show SfPdfViewer;
import 'package:intl/intl.dart';

import '../controllers/pdf_sign_controller.dart';

class PdfSignView extends GetView<PdfSignController> {
  const PdfSignView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PdfSignController());
    final args = Get.arguments as Map<String, dynamic>?;
    final String? pdfPath = args?['pdfPath'] ?? controller.pdfPath.value;
    final String pdfName = args?['pdfName'] ?? 'Document';

    Widget getPdfWidget() {
      if (pdfPath == null || pdfPath.isEmpty) {
        return const Center(child: Text('No PDF path provided'));
      } else if (pdfPath.startsWith('http')) {
        return SfPdfViewer.network(
          pdfPath,
          controller: controller.pdfViewerController,
          onPageChanged: (details) => controller.currentPage.value = details.newPageNumber,
        );
      } else {
        final file = File(pdfPath);
        return file.existsSync()
            ? SfPdfViewer.file(file, controller: controller.pdfViewerController)
            : Center(child: Text('PDF not found: $pdfPath'));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign: $pdfName',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white, size: 26),
            onPressed: () async {
              if (controller.validateInputs()) {
                await controller.saveAndUploadSignedPdf(context, pdfPath ?? '', pdfName);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top input section
          Obx(() {
            if (controller.isPortalUser.value || !controller.showInputFields.value) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Signature field
                  _buildInputField(
                    label: 'Signature',
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controller.signatureError.value.isEmpty
                              ? Colors.grey.shade400
                              : Colors.redAccent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Signature(
                            controller: controller.signatureController,
                            backgroundColor: Colors.transparent,
                            width: double.infinity,
                            height: 110,
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: ElevatedButton(
                              onPressed: () => controller.signatureController.clear(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(0.9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    errorText: controller.signatureError.value,
                  ),
                  const SizedBox(height: 16),
                  // Text Message and Date
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Text Message',
                          child: TextField(
                            controller: controller.textController,
                            decoration: InputDecoration(
                              hintText: 'Enter text',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              errorText: controller.textError.value.isEmpty
                                  ? null
                                  : controller.textError.value,
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          label: 'Date',
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: controller.dateError.value.isEmpty
                                      ? Colors.grey.shade400
                                      : Colors.redAccent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedDate.value != null
                                        ? DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!)
                                        : 'Select date',
                                    style: TextStyle(
                                      color: controller.selectedDate.value != null
                                          ? Colors.black87
                                          : Colors.grey.shade500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          errorText: controller.dateError.value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date & Time and Add Fields Button
                  _buildInputField(
                    label: 'Date & Time',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _selectDateTime(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 12, right: 8, top: 14, bottom: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: controller.dateTimeError.value.isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.redAccent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade100,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.selectedDateTime.value != null
                                        ? DateFormat('yyyy-MM-dd HH:mm').format(controller.selectedDateTime.value!)
                                        : 'Select date & time',
                                    style: TextStyle(
                                      color: controller.selectedDateTime.value != null
                                          ? Colors.black87
                                          : Colors.grey.shade500,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.access_time,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () => controller.addFieldsToPdf(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                              child: const Text(
                                'Add Data to PDF',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    errorText: controller.dateTimeError.value,
                  ),
                ],
              ),
            );
          }),
          // PDF viewer section
          Expanded(
            child: Obx(() {
              return Stack(
                children: [
                  getPdfWidget(),
                  // Text field position
                  if (controller.textPosition.value != null)
                    Positioned(
                      left: controller.textPosition.value!.dx,
                      top: controller.textPosition.value!.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) => controller.moveTextField(details.delta),
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: Text(controller.textController.text),
                        ),
                      ),
                    ),
                  // Date field position
                  if (controller.datePosition.value != null)
                    Positioned(
                      left: controller.datePosition.value!.dx,
                      top: controller.datePosition.value!.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) => controller.moveDateField(details.delta),
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: Text(
                            controller.selectedDate.value != null
                                ? DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!)
                                : 'Date',
                          ),
                        ),
                      ),
                    ),
                  // DateTime field position
                  if (controller.dateTimePosition.value != null)
                    Positioned(
                      left: controller.dateTimePosition.value!.dx,
                      top: controller.dateTimePosition.value!.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) => controller.moveDateTimeField(details.delta),
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple),
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: Text(
                            controller.selectedDateTime.value != null
                                ? DateFormat('yyyy-MM-dd HH:mm').format(controller.selectedDateTime.value!)
                                : 'Date & Time',
                          ),
                        ),
                      ),
                    ),
                  // Signature position
                  if (controller.signaturePosition.value != null)
                    Positioned(
                      left: controller.signaturePosition.value!.dx,
                      top: controller.signaturePosition.value!.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) => controller.moveSignature(details.delta),
                        child: Container(
                          width: 150,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: controller.signatureImage.value != null
                              ? Image.memory(controller.signatureImage.value!)
                              : const Center(child: Text('Signature')),
                        ),
                      ),
                    ),
                  // Instruction overlay when placing fields
                  if (controller.isPlacingFields.value)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Tap on the document to place fields',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required Widget child, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 10),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

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
        initialTime: TimeOfDay.fromDateTime(controller.selectedDateTime.value ?? DateTime.now()),
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
}