import 'dart:developer';
import 'dart:io';
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

    // controller.pdfViewerController.addListener(() {
    //   controller.zoomLevel.value = controller.pdfViewerController.zoomLevel;
    // });

    return Scaffold(
      appBar: pdfAppBar( pdfName, context, pdfPath),
      body: Column(
        children: [
          !controller.isPortalUser.value ?
          FieldSelectionRow(controller: controller)
          : const SizedBox.shrink(),
          Obx(() => controller.isEditingField.value
            ? Flexible(
                child: SingleChildScrollView(
                  child: FieldInputContainer(controller: controller),
                ),
              )
            : const SizedBox.shrink()),
          Expanded(
            child: Obx(() {
              final zoom = controller.zoomLevel.value;
              if (kDebugMode) {
                print(zoom);
              }
              return GestureDetector(
                  onTapUp: controller.isPlacingField.value
                      ? (details) => controller.placeFieldAt(details.localPosition / zoom)
                      : null,
                  child: Stack(
                    children: [
                      PdfWidget(pdfPath: pdfPath, controller: controller),
                      ...buildPlacedFields(controller, zoom),
                      if (controller.isPlacingField.value)
                        InstructionOverlay(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  

  List<Widget> buildPlacedFields(PdfSignController controller, double zoom) {
    const double baseFontSize = 14.0; // Base font size for text fields
    return [
      ...controller.placedTextFields
          .map((field) => DraggableField(
            controller: controller,
            field: field,
            type: FieldType.text,
            color: AppColorList.OpacityBlue,
            borderColor: AppColorList.blue,
            zoom: zoom,
            child: Text(
              field.value as String,
              style: TextStyle(fontSize: baseFontSize * zoom),
            ),
          )),
      ...controller.placedDateFields
          .map((field) => DraggableField(
            controller: controller,
            field: field,
            type: FieldType.date,
            color: AppColorList.OpacityGreen,
            borderColor: AppColorList.Star1,
            zoom: zoom,
            child: Text(
              field.value as String,
              style: TextStyle(fontSize: baseFontSize * zoom),
            ),
          )),
      ...controller.placedDateTimeFields
          .map((field) => DraggableField(
            controller: controller,
            field: field,
            type: FieldType.dateTime,
            color: AppColorList.OpacityPurple,
            borderColor: AppColorList.Purple,
            zoom: zoom,
            child: Text(
              field.value as String,
              style: TextStyle(fontSize: baseFontSize * zoom),
            ),
          )),
      ...controller.placedSignatureFields
          .map((field) => DraggableField(
            controller: controller,
              field: field,
              type: FieldType.signature,
              color: AppColorList.OpacityRed,
              borderColor: AppColorList.Star3,
              zoom: zoom,
              child: Image.memory(field.value as Uint8List
            ),
          )),
    ];
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

class DraggableField extends StatelessWidget {
  final PdfSignController controller;
  final PlacedField field;
  final FieldType type;
  final Color color;
  final Color borderColor;
  final Widget child;
  final double zoom;

  const DraggableField({super.key, 
    required this.controller,
    required this.field,
    required this.type,
    required this.color,
    required this.borderColor,
    required this.child, 
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = field.size * zoom;
    return Positioned(
      left: field.position.dx * zoom,
      top: field.position.dy * zoom,
      child: GestureDetector(
        onPanUpdate: (details) {
          controller.updateFieldPosition(field, details.delta / zoom);
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
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  const double minWidth = 40;
                  const double minHeight = 24;
                  const double maxWidth = 400;
                  const double maxHeight = 200;
                  final newWidth = (field.size.width + details.delta.dx / zoom)
                      .clamp(minWidth, maxWidth);
                  final newHeight = (field.size.height + details.delta.dy / zoom)
                      .clamp(minHeight, maxHeight);
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

