import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../controllers/signature_and_pdf_controller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SignatureAndPdfView extends GetView<SignatureAndPdfController> {
  SignatureAndPdfView({super.key});

  final Rx<Uint8List?> signatureBytes = Rx<Uint8List?>(null);
  final GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

  final dynamic ticket = Get.arguments;

  @override
  Widget build(BuildContext context) {
    // Load PDF for this specific ticket (runs once when page builds)
    final ticketNo = ticket?.ticketNo1?.toString() ?? 'unknown';
    controller.loadSavedPdf(ticketNo);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Signature to Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Obx(() => Text(
                    controller.selectedPdf.value == null
                        ? 'Select PDF Document'
                        : 'Attached PDF: ${controller.selectedPdf.value!.path.split(Platform.pathSeparator).last}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )),
              onPressed: _pickPdf,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                alignment: Alignment.centerLeft,
              ),
            ),

            Obx(() => controller.selectedPdf.value != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      label: const Text('Delete Attached PDF',
                          style: TextStyle(color: Colors.red)),
                      onPressed: _deletePdf,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 12),

            Obx(() => controller.selectedPdf.value != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Selected: ${controller.selectedPdf.value!.path.split(Platform.pathSeparator).last}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 32),

            const Text('Draw your signature below:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Container(
              height: 240,
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

            const SizedBox(height: 24),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Signature'),
                    onPressed: clearSignature,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Sign & Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _signAndDownload,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Obx(() => signatureBytes.value != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Signature Preview (scaled):'),
                      const SizedBox(height: 8),
                      Center(child: Image.memory(signatureBytes.value!, height: 70, fit: BoxFit.contain)),
                    ],
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
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
    Get.snackbar('Removed', 'PDF cleared for this ticket', duration: const Duration(seconds: 3));
  }

  Future<void> clearSignature() async {
    signatureKey.currentState?.clear();
    signatureBytes.value = null;
  }

  Future<String?> _signPdf() async {
    if (controller.selectedPdf.value == null) {
      Get.snackbar('Error', 'Please select a PDF first');
      return null;
    }

    try {
      final image = await signatureKey.currentState!.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return null;

      signatureBytes.value = byteData.buffer.asUint8List();

      final document = PdfDocument(inputBytes: await controller.selectedPdf.value!.readAsBytes());
      final page = document.pages[document.pages.count - 1];
      final graphics = page.graphics;

      Rect rect = const Rect.fromLTWH(320, 720, 140, 45);

      final extractor = PdfTextExtractor(document);
      final lines = extractor.extractTextLines(
        startPageIndex: document.pages.count - 1,
        endPageIndex: document.pages.count - 1,
      );

      bool found = false;
      String log = '=== SIGNATURE DEBUG ===\n';

      for (final line in lines) {
        final text = line.text.trim().toLowerCase();
        log += 'Line: "$text" | ${line.bounds}\n';

        if (text.contains('signature:') || (text.contains('signature') && text.endsWith(':'))) {
          found = true;

          TextWord? word;
          for (final w in line.wordCollection.reversed) {
            if (w.text.toLowerCase().contains('signature') || w.text.toLowerCase() == 'signature:') {
              word = w;
              break;
            }
          }

          if (word != null) {
            double x = word.bounds.right + 20;
            double y = word.bounds.top - 12;
            const w = 140.0;
            const h = 45.0;

            final size = page.getClientSize();
            x = x.clamp(0.0, size.width - w);
            y = y.clamp(0.0, size.height - h);

            rect = Rect.fromLTWH(x, y, w, h);

            log += 'MATCH → x:${x.toStringAsFixed(1)}, y:${y.toStringAsFixed(1)}\n';
          }
          break;
        }
      }

      extractor.dispose();

      print(log);
      print('Found: $found');
      print('Rect: ${rect.left.toStringAsFixed(1)}, ${rect.top.toStringAsFixed(1)}, ${rect.width}×${rect.height}');

      if (signatureBytes.value != null) {
        final image = PdfBitmap(signatureBytes.value!);
        graphics.drawImage(image, rect);
      }

      final dir = await getApplicationDocumentsDirectory();
      final name = 'signed_${ticket?.ticketNo1 ?? 'doc'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(await document.save());
      document.dispose();

      return file.path;
    } catch (e, s) {
      print('Error: $e\n$s');
      Get.snackbar('Error', 'PDF processing failed');
      return null;
    }
  }

  Future<void> _signAndDownload() async {
    final path = await _signPdf();
    if (path == null) return;

    try {
      String savePath;
      String loc = 'Downloads';

      const downloads = '/storage/emulated/0/Download';
      final dir = Directory(downloads);

      if (await dir.exists()) {
        savePath = '$downloads/${path.split(Platform.pathSeparator).last}';
      } else {
        final fallback = await getApplicationDocumentsDirectory();
        savePath = '${fallback.path}/${path.split(Platform.pathSeparator).last}';
        loc = 'App Documents';
      }

      await Directory(savePath.substring(0, savePath.lastIndexOf(Platform.pathSeparator))).create(recursive: true);
      await File(path).copy(savePath);

      Get.snackbar('Success', 'Saved to $loc', duration: const Duration(seconds: 5));

      const android = AndroidNotificationDetails(
        'downloads',
        'Downloads',
        channelDescription: 'PDF saves',
        importance: Importance.high,
        priority: Priority.high,
      );

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        'PDF Saved',
        'File: ${savePath.split(Platform.pathSeparator).last}',
        const NotificationDetails(android: android),
      );
    } catch (e) {
      Get.snackbar('Error', 'Save failed');
    }
  }
}

extension on PdfTextExtractor {
  void dispose() {}
}