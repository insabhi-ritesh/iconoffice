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
    // You can get the PDF path from your controller or pass it as an argument
    final String pdfPath = controller.pdfPath.value; // Make sure your controller provides this

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign PDF'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await controller.saveSignedPdf(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            GestureDetector(
              onTapUp: (details) {
                controller.setSignaturePosition(details.localPosition);
              },
              child: SfPdfViewer.file(
                File(pdfPath),
                controller: controller.pdfViewerController,
                onPageChanged: (details) {
                  controller.currentPage.value = details.newPageNumber;
                },
              ),
            ),
            if (controller.signaturePosition.value != null)
              Positioned(
                left: controller.signaturePosition.value!.dx,
                top: controller.signaturePosition.value!.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    controller.moveSignature(details.delta);
                  },
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
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}
