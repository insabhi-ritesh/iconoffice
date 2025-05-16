import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import '../../../Constants/constant.dart';

class PdfSignController extends GetxController {
  // PDF and signature
  final RxString pdfPath = ''.obs;
  final box = GetStorage();
  late String ticketNumber;
  var isPortalUser = false.obs;

  final PdfViewerController pdfViewerController = PdfViewerController();
  final RxInt currentPage = 1.obs;

  // Text field
  final TextEditingController textController = TextEditingController();
  final RxString textError = ''.obs;
  final Rxn<Offset> textPosition = Rxn<Offset>();

  // Date field
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString dateError = ''.obs;
  final Rxn<Offset> datePosition = Rxn<Offset>();

  // DateTime field
  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxString dateTimeError = ''.obs;
  final Rxn<Offset> dateTimePosition = Rxn<Offset>();

  // Signature field
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  final RxString signatureError = ''.obs;
  final Rxn<Offset> signaturePosition = Rxn<Offset>();
  final Rx<Uint8List?> signatureImage = Rx<Uint8List?>(null);

  // Placement state
  final RxBool isPlacingFields = false.obs;

  // New variable to control input container visibility
  final RxBool showInputFields = true.obs;

  // Sizes for fields
  final Size signatureBoxSize = const Size(150, 60);
  final Size textBoxSize = const Size(150, 40);
  final Size dateBoxSize = const Size(150, 40);
  final Size dateTimeBoxSize = const Size(180, 40);

  // Field placement logic
  void addFieldsToPdf() async {
    // Hide the input fields
    showInputFields.value = false;

    // Start placing fields
    isPlacingFields.value = true;

    // Wait for user to tap on PDF to place each field
    // For demo: Place all fields at default positions if not already placed
    if (textPosition.value == null) {
      textPosition.value = const Offset(100, 100);
    }
    if (datePosition.value == null) {
      datePosition.value = const Offset(100, 160);
    }
    if (dateTimePosition.value == null) {
      dateTimePosition.value = const Offset(100, 220);
    }
    if (signaturePosition.value == null) {
      signaturePosition.value = const Offset(100, 300);
    }

    // Export signature image for preview
    if (signatureController.isNotEmpty) {
      signatureImage.value = await signatureController.toPngBytes();
    }

    isPlacingFields.value = false;
  }

  // Move fields
  void moveTextField(Offset delta) {
    if (textPosition.value != null) {
      textPosition.value = textPosition.value! + delta;
    }
  }

  void moveDateField(Offset delta) {
    if (datePosition.value != null) {
      datePosition.value = datePosition.value! + delta;
    }
  }

  void moveDateTimeField(Offset delta) {
    if (dateTimePosition.value != null) {
      dateTimePosition.value = dateTimePosition.value! + delta;
    }
  }

  void moveSignature(Offset delta) {
    if (signaturePosition.value != null) {
      signaturePosition.value = signaturePosition.value! + delta;
    }
  }

  // Validation
  bool validateInputs() {
    bool valid = true;
    if (textController.text.trim().isEmpty) {
      textError.value = 'Text is required';
      valid = false;
    } else {
      textError.value = '';
    }
    if (selectedDate.value == null) {
      dateError.value = 'Date is required';
      valid = false;
    } else {
      dateError.value = '';
    }
    if (selectedDateTime.value == null) {
      dateTimeError.value = 'Date & Time is required';
      valid = false;
    } else {
      dateTimeError.value = '';
    }
    if (!signatureController.isNotEmpty) {
      signatureError.value = 'Signature is required';
      valid = false;
    } else {
      signatureError.value = '';
    }
    return valid;
  }

  // Save and upload PDF with fields
  Future<void> saveAndUploadSignedPdf(
    BuildContext context,
    String pdfPath,
    String pdfName, {
    Size? pdfViewSize,
  }) async {
    try {
      if (!validateInputs()) {
        Get.snackbar('Error', 'Please fill all required fields and place them.');
        return;
      }

      final Uint8List? signatureImg = await signatureController.toPngBytes();
      if (signatureImg == null) {
        Get.snackbar('Error', 'Failed to export signature.');
        return;
      }

      final File pdfFile = File(pdfPath);
      if (!pdfFile.existsSync()) {
        Get.snackbar('Error', 'PDF not found.');
        return;
      }

      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final int pageIndex = currentPage.value - 1;
      if (pageIndex <0 || pageIndex >= document.pages.count) {
        Get.snackbar('Error', 'Invalid page number.');
        document.ready;
        return;
      }

      final PdfPage page = document.pages[pageIndex];
      final Size pdfPageSize = Size(page.getClientSize().width, page.getClientSize().height);
      final Size widgetSize = pdfViewSize ?? pdfPageSize;

      // Helper to scale positions
      Offset scaleOffset(Offset widgetOffset, Size widgetBoxSize, Size pdfBoxSize) {
        final double scaleX = pdfBoxSize.width / widgetSize.width;
        final double scaleY = pdfBoxSize.height / widgetSize.height;
        return Offset(widgetOffset.dx * scaleX, pdfBoxSize.height - ((widgetOffset.dy + widgetBoxSize.height) * scaleY));
      }

      // Draw text
      if (textPosition.value != null) {
        final Offset pos = scaleOffset(textPosition.value!, textBoxSize, pdfPageSize);
        page.graphics.drawString(
          textController.text,
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pos.dx, pos.dy, textBoxSize.width, textBoxSize.height),
        );
      }

      // Draw date
      if (datePosition.value != null && selectedDate.value != null) {
        final Offset pos = scaleOffset(datePosition.value!, dateBoxSize, pdfPageSize);
        page.graphics.drawString(
          DateFormat('yyyy-MM-dd').format(selectedDate.value!),
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pos.dx, pos.dy, dateBoxSize.width, dateBoxSize.height),
        );
      }

      // Draw datetime
      if (dateTimePosition.value != null && selectedDateTime.value != null) {
        final Offset pos = scaleOffset(dateTimePosition.value!, dateTimeBoxSize, pdfPageSize);
        page.graphics.drawString(
          DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime.value!),
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pos.dx, pos.dy, dateTimeBoxSize.width, dateTimeBoxSize.height),
        );
      }

      // Draw signature
      if (signaturePosition.value != null && signatureImg != null) {
        final Offset pos = scaleOffset(signaturePosition.value!, signatureBoxSize, pdfPageSize);
        final PdfBitmap signatureBitmap = PdfBitmap(signatureImg);
        page.graphics.drawImage(
          signatureBitmap,
          Rect.fromLTWH(pos.dx, pos.dy, signatureBoxSize.width, signatureBoxSize.height),
        );
      }

      // Save PDF
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = pdfName.isNotEmpty ? pdfName : 'signed_pdf_${DateTime.now().millisecondsSinceEpoch}';
      final String signedPdfPath = '${tempDir.path}/$fileName.pdf';
      final File signedPdfFile = File(signedPdfPath);

      await signedPdfFile.writeAsBytes(await document.save());
      document.dispose();

      final bool uploadSuccess = await _uploadSignedPdf(signedPdfPath);

      if (uploadSuccess) {
        try {
          if (await signedPdfFile.exists()) {
            await signedPdfFile.delete();
          }
        } catch (e) {
          log('Failed to delete signed PDF: $e');
        }
        Get.snackbar('Success', 'Signed PDF uploaded successfully!');
      } else {
        Get.snackbar('Upload Failed', 'Upload failed. PDF saved locally.');
      }

      // Get.snackbar('PDF Saved', 'Signed PDF saved at $signedPdfPath');
      Get.back();
    } catch (e, stack) {
      Get.snackbar('Exception', 'Failed: $e');
      log('Exception: $e\n$stack');
    }
  }

  Future<bool> _uploadSignedPdf(String filePath) async {
    final partnerId = box.read('partnerId');
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constant.BASE_URL}${ApiEndPoints.UPLOAD_PDF}?partner_id=$partnerId&ticket_number=$ticketNumber'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      log('Upload failed: $e');
      return false;
    }
  }

  @override
  void onClose() {
    signatureController.dispose();
    pdfViewerController.dispose();
    textController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    isPortalUser.value = box.read('is_portal_user');
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    ticketNumber = args['ticketNumber'] ?? '';
    pdfPath.value = args['pdfPath'] ?? '';
  }
}

extension on PdfDocument {
  get ready => null;
}