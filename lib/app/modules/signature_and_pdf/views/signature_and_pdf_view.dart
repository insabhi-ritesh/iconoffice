import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../controllers/signature_and_pdf_controller.dart';

class SignatureAndPdfView extends GetView<SignatureAndPdfController> {
  SignatureAndPdfView({super.key});

  final Rx<Uint8List?> signatureBytes = Rx<Uint8List?>(null);
  final GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();
  final dynamic ticket = Get.arguments;

  // Persistent folder inside Downloads — survives reinstall
  static const _saveFolder = '/storage/emulated/0/Download/SignedDocuments';

  @override
  Widget build(BuildContext context) {
    final ticketNo = ticket?.ticketNo1?.toString() ?? 'unknown';
    controller.loadSavedPdf(ticketNo);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Signature to Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── PDF Picker ──────────────────────────────────────────────
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Obx(
                () => Text(
                  controller.selectedPdf.value == null
                      ? 'Select PDF Document'
                      : 'Attached: ${_fileName(controller.selectedPdf.value!.path)}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              onPressed: _pickPdf,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),

            // Remove PDF button — only shows when PDF is selected
            Obx(
              () =>
                  controller.selectedPdf.value != null
                      ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Remove PDF',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: _deletePdf,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── Signature Pad ────────────────────────────────────────────
            const Text(
              'Draw your signature below:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SfSignaturePad(
                  key: signatureKey,
                  backgroundColor: Colors.transparent,
                  strokeColor: Colors.black,
                  minimumStrokeWidth: 1.8,
                  maximumStrokeWidth: 5.0,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Action Buttons ───────────────────────────────────────────
            OutlinedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear Signature'),
              onPressed: _clearSignature,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text('Sign & Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _signAndSave,
            ),
          ],
        ),
      ),
    );
  }

  String _fileName(String path) => path.split(Platform.pathSeparator).last;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      controller.selectedPdf.value = file;
      final ticketNo = ticket?.ticketNo1?.toString() ?? 'unknown';
      await controller.savePdfPath(file.path, ticketNo);
    }
  }

  Future<void> _deletePdf() async {
    final ticketNo = ticket?.ticketNo1?.toString() ?? 'unknown';
    await controller.clearSavedPdf(ticketNo);
  }

  Future<void> _clearSignature() async {
    signatureKey.currentState?.clear();
    signatureBytes.value = null;
  }

  Future<void> _signAndSave() async {
    if (controller.selectedPdf.value == null) {
      Get.snackbar('Error', 'Please select a PDF first');
      return;
    }

    try {
      // 1. Capture signature as PNG bytes
      final img = await signatureKey.currentState!.toImage(pixelRatio: 3.0);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        Get.snackbar('Error', 'Could not capture signature');
        return;
      }
      signatureBytes.value = byteData.buffer.asUint8List();

      // 2. Open PDF
      final document = PdfDocument(
        inputBytes: await controller.selectedPdf.value!.readAsBytes(),
      );

      // 3. Search ALL pages for "Technician Signature" text
      Rect? sigRect;
      int targetPageIndex = document.pages.count - 1;

      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        final extractor = PdfTextExtractor(document);
        final lines = extractor.extractTextLines(
          startPageIndex: pageIndex,
          endPageIndex: pageIndex,
        );

        for (final line in lines) {
          final text = line.text.trim().toLowerCase();

          if (text.contains('technician signature') ||
              text.contains('technician') && text.contains('signature')) {
            double labelRight = line.bounds.right;
            double labelTop = line.bounds.top;
            double labelBottom = line.bounds.bottom;
            double labelHeight = labelBottom - labelTop;

            const double sigWidth = 160.0;
            final double sigHeight = (labelHeight * 2.5).clamp(40.0, 60.0);
            final double x = labelRight + 8;
            final double y = labelTop - ((sigHeight - labelHeight) / 2);

            final pageSize = document.pages[pageIndex].getClientSize();
            final clampedX = x.clamp(0.0, pageSize.width - sigWidth);
            final clampedY = y.clamp(0.0, pageSize.height - sigHeight);

            sigRect = Rect.fromLTWH(clampedX, clampedY, sigWidth, sigHeight);
            targetPageIndex = pageIndex;
            break;
          }
        }
        if (sigRect != null) break;
      }

      // 4. Fallback position if text not found
      if (sigRect == null) {
        final pageSize = document.pages[targetPageIndex].getClientSize();
        sigRect = Rect.fromLTWH(200, pageSize.height - 80, 160, 50);
      }

      // 5. Draw signature image on the target page
      final pdfImage = PdfBitmap(signatureBytes.value!);
      document.pages[targetPageIndex].graphics.drawImage(pdfImage, sigRect!);

      // 6. Save to Downloads/SignedDocuments — survives reinstall, no permission plugin needed
      final ticketNo = ticket?.ticketNo1?.toString() ?? 'doc';
      final fileName =
          'signed_${ticketNo}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final saveDir = Directory(_saveFolder);
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final file = File('${saveDir.path}/$fileName');
      await file.writeAsBytes(await document.save());
      document.dispose();

      // 7. Save path then go back to ticket detail page
      await controller.saveSignedPdfPath(file.path, ticketNo);
      Navigator.of(Get.context!).pop();
    } catch (e, s) {
      debugPrint('Error signing PDF: $e\n$s');
      Get.snackbar('Error', 'Failed to sign PDF');
    }
  }
}
