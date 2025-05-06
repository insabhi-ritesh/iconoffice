import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart' show SfPdfViewer;

import '../controllers/pdf_sign_controller.dart';

class PdfSignView extends GetView<PdfSignController> {
  const PdfSignView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PdfSignController());
    final args = Get.arguments as Map<String, dynamic>?;
    final String? pdfPath = args?['pdfPath'] ?? controller.pdfPath.value;
    final String pdfName = args?['pdfName'] ?? 'Document';
    final String ticketNumber = args? ['ticketNumber'] ?? '';

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
        title: Text('Sign: $pdfName'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await controller.saveAndUploadSignedPdf(context, pdfPath ?? '', pdfName);
            },
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            getPdfWidget(),

            Positioned.fill(
              child: IgnorePointer(
                ignoring: controller.signaturePosition.value != null,
                child: GestureDetector(
                  onTapUp: (details) => controller.setSignaturePosition(details.localPosition),
                ),
              ),
            ),

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
                    child: Signature(
                      controller: controller.signatureController,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),

            if (controller.signaturePosition.value != null)
              Positioned(
                right: 16,
                bottom: 16,
                child: ElevatedButton(
                  child: const Text('Clear Signature'),
                  onPressed: () {
                    controller.signatureController.clear();
                    controller.signaturePosition.value = null;
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}
