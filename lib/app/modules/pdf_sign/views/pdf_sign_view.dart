import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart' show SfPdfViewer;
import '../controllers/pdf_sign_controller.dart';
import 'components/field_input_container.dart';
import 'components/field_selection_row.dart';
import 'components/instruction_overlay.dart';
import 'components/pdf_app_bar.dart';

class PdfSignView extends GetView<PdfSignController> {
  const PdfSignView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PdfSignController());
    final args = Get.arguments as Map<String, dynamic>?;
    final String? pdfPath = args?['pdfPath'] ?? controller.pdfPath.value;
    final String pdfName = args?['pdfName'] ?? 'Document';

    // Add a GlobalKey to get the PDF widget's size
    final GlobalKey pdfKey = GlobalKey();

    return Scaffold(
      appBar: pdfAppBar(pdfName, context, pdfPath),
      body: Column(
        children: [
          !controller.isPortalUser.value
              ? FieldSelectionRow(controller: controller)
              : const SizedBox.shrink(),
          Obx(() => controller.isEditingField.value
              ? Flexible(
                  child: SingleChildScrollView(
                    child: FieldInputContainer(controller: controller),
                  ),
                )
              : const SizedBox.shrink()),
          Expanded(
            child:
            // Obx(() {
              LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(() => 
                    GestureDetector(
                      onTapUp: controller.isPlacingField.value
                          ? (details) {
                              // Get the PDF widget's size and position
                              final RenderBox box = pdfKey.currentContext?.findRenderObject() as RenderBox;
                              final Offset localPosition = box.globalToLocal(details.globalPosition);
                              final Size pdfSize = box.size;
                    
                              // Store as percentage
                              final double percentX = localPosition.dx / pdfSize.width;
                              final double percentY = localPosition.dy / pdfSize.height;
                    
                              controller.placeFieldAtPercent(percentX, percentY);
                            }
                          : null,
                      child: Stack(
                        children: [
                          PdfWidget(
                            key: pdfKey,
                            pdfPath: pdfPath,
                            controller: controller,
                          ),
                          ...buildPlacedFields(controller, pdfKey),
                          if (controller.isPlacingField.value) InstructionOverlay(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            // }
            // ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPlacedFields(PdfSignController controller, GlobalKey pdfKey) {
    const double baseFontSize = 14.0; // Base font size for text fields
    final RenderBox? box = pdfKey.currentContext?.findRenderObject() as RenderBox?;
    final Size pdfSize = box?.size ?? Size.zero;

    List<Widget> widgets = [];

    for (final field in controller.placedTextFields) {
      widgets.add(_buildDraggableField(
        controller: controller,
        field: field,
        type: FieldType.text,
        color: AppColorList.OpacityBlue,
        borderColor: AppColorList.blue,
        pdfSize: pdfSize,
        child: Text(
          field.value as String,
          style: TextStyle(fontSize: baseFontSize * controller.zoomLevel.value),
        ),
      ));
    }
    for (final field in controller.placedDateFields) {
      widgets.add(_buildDraggableField(
        controller: controller,
        field: field,
        type: FieldType.date,
        color: AppColorList.OpacityGreen,
        borderColor: AppColorList.Star1,
        pdfSize: pdfSize,
        child: Text(
          field.value as String,
          style: TextStyle(fontSize: baseFontSize * controller.zoomLevel1.value),
        ),
      ));
    }
    for (final field in controller.placedDateTimeFields) {
      widgets.add(_buildDraggableField(
        controller: controller,
        field: field,
        type: FieldType.dateTime,
        color: AppColorList.OpacityPurple,
        borderColor: AppColorList.Purple,
        pdfSize: pdfSize,
        child: Text(
          field.value as String,
          style: TextStyle(fontSize: baseFontSize * controller.zoomLevel2.value),
        ),
      ));
    }
    for (final field in controller.placedSignatureFields) {
      widgets.add(_buildDraggableField(
        controller: controller,
        field: field,
        type: FieldType.signature,
        color: AppColorList.OpacityRed,
        borderColor: AppColorList.Star3,
        pdfSize: pdfSize,
        child: Image.memory(field.value as Uint8List),
      ));
    }
    return widgets;
  }

  Widget _buildDraggableField({
    required PdfSignController controller,
    required PlacedField field,
    required FieldType type,
    required Color color,
    required Color borderColor,
    required Size pdfSize,
    required Widget child,
  }) {
    // Calculate position and size based on PDF size and stored percentages
    final double left = field.percentX * pdfSize.width;
    final double top = field.percentY * pdfSize.height;
    final double width = field.percentWidth * pdfSize.width;
    final double height = field.percentHeight * pdfSize.height;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Update percent position
          final double newPercentX = ((left + details.delta.dx) / pdfSize.width).clamp(0.0, 1.0);
          final double newPercentY = ((top + details.delta.dy) / pdfSize.height).clamp(0.0, 1.0);
          controller.updateFieldPercentPosition(field, newPercentX, newPercentY);
        },
        onLongPress: () {
          controller.removeField1(field, type);
        },
        child: Stack(
          children: [
            Container(
              width: width,
              height: height,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: child,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  const double minWidth = 40;
                  const double minHeight = 24;
                  const double maxWidth = 400;
                  const double maxHeight = 200;
                  final double newWidth = (width + details.delta.dx).clamp(minWidth, maxWidth);
                  final double newHeight = (height + details.delta.dy).clamp(minHeight, maxHeight);
                  final double newPercentWidth = newWidth / pdfSize.width;
                  final double newPercentHeight = newHeight / pdfSize.height;
                  controller.updateFieldPercentSize(field, newPercentWidth, newPercentHeight);
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
class PdfWidget extends StatelessWidget {
  final String? pdfPath;
  final PdfSignController controller;
  const PdfWidget({super.key, required this.pdfPath, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (pdfPath == null || pdfPath!.isEmpty) {
      return const Center(child: Text('No PDF path provided'));
    } else if (pdfPath!.startsWith('http')) {
      return SfPdfViewer.network(
        pdfPath!,
        controller: controller.pdfViewerController,
        onZoomLevelChanged: (details) {
          controller.zoomLevel.value = details.newZoomLevel;
        },
        onPageChanged: (details) => controller.currentPage.value = details.newPageNumber,
      );
    }else {
      final file = File(pdfPath!);
      log('PDF Path: $pdfPath');
      log('File exists: ${file.existsSync()}');
      return file.existsSync()
          ? SfPdfViewer.file(
            file, 
            controller: controller.pdfViewerController,
            onZoomLevelChanged: (details) {
              controller.zoomLevel.value = details.newZoomLevel;
            }
          )
          : Center(child: Text('PDF not found: $pdfPath'));
    }
  }
}
