
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfSignController extends GetxController {
  final RxString pdfPath = ''.obs;

  // Signature controller for drawing
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  // Position of the signature box (null if not placed)
  final Rxn<Offset> signaturePosition = Rxn<Offset>();

  // PDF viewer controller
  final PdfViewerController pdfViewerController = PdfViewerController();

  // Current page (for future multi-page support)
  final RxInt currentPage = 1.obs;

  // Set the position of the signature box
  void setSignaturePosition(Offset position) {
    signaturePosition.value = position;
  }

  // Move the signature box by a delta (drag)
  void moveSignature(Offset delta) {
    if (signaturePosition.value != null) {
      signaturePosition.value = signaturePosition.value! + delta;
    }
  }

  // Save the signed PDF
  Future<void> saveSignedPdf(BuildContext context) async {
    if (signaturePosition.value == null || !signatureController.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please place and draw your signature.')),
      );
      return;
    }

    // Export signature as image
    final Uint8List? signatureImage = await signatureController.toPngBytes();
    if (signatureImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export signature.')),
      );
      return;
    }

    // Load the original PDF
    final File originalPdfFile = File(pdfPath.value);
    final Uint8List originalPdfBytes = await originalPdfFile.readAsBytes();

    // Create a new PDF document
    final pdfDoc = pw.Document();

    // Add the original PDF as an image background (for demonstration)
    // In production, use a PDF editing library to add to the actual PDF page
    final signatureImg = pw.MemoryImage(signatureImage);

    pdfDoc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // You may want to use a PDF rasterizer to render the original PDF as an image here.
              // For now, this is a placeholder for the original PDF background.
              // pw.Image(pw.MemoryImage(originalPdfBytes), fit: pw.BoxFit.contain),
              // Place the signature at the selected position
              pw.Positioned(
                left: signaturePosition.value!.dx,
                top: signaturePosition.value!.dy,
                child: pw.Image(signatureImg, width: 150, height: 60),
              ),
            ],
          );
        },
      ),
    );

    // Save the signed PDF to a temporary directory
    final outputDir = await getTemporaryDirectory();
    final outputPath = '${outputDir.path}/signed_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(await pdfDoc.save());

    // Show a snackbar (ensure context is still valid)
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed PDF saved at $outputPath')),
      );
    }
  }

  @override
  void onClose() {
    signatureController.dispose();
    pdfViewerController.dispose();
    super.onClose();
  }
}
