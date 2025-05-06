import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;


class PdfSignController extends GetxController {
  final RxString pdfPath = ''.obs;
  final box = GetStorage();
  late String ticketNumber;
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  final Rxn<Offset> signaturePosition = Rxn<Offset>();
  final PdfViewerController pdfViewerController = PdfViewerController();
  final RxInt currentPage = 1.obs;
  final Size signatureBoxSize = const Size(150, 60);

  void setSignaturePosition(Offset position) {
    signaturePosition.value = position;
  }

  void moveSignature(Offset delta) {
    if (signaturePosition.value != null) {
      signaturePosition.value = signaturePosition.value! + delta;
    }
  }

  Future<void> saveAndUploadSignedPdf(
    BuildContext context,
    String pdfPath,
    String pdfName, {
    Size? pdfViewSize,
  }) async {
    try {
      if (signaturePosition.value == null || !signatureController.isNotEmpty) {
        Get.snackbar('Error', 'Please place and draw your signature.');
        return;
      }

      final Uint8List? signatureImage = await signatureController.toPngBytes();
      if (signatureImage == null) {
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
      if (pageIndex < 0 || pageIndex >= document.pages.count) {
        Get.snackbar('Error', 'Invalid page number.');
        document.dispose();
        return;
      }

      final PdfPage page = document.pages[pageIndex];
      final PdfBitmap signatureBitmap = PdfBitmap(signatureImage);

      final Size pdfPageSize = Size(page.getClientSize().width, page.getClientSize().height);
      final Size widgetSize = pdfViewSize ?? pdfPageSize;
      final double scaleX = pdfPageSize.width / widgetSize.width;
      final double scaleY = pdfPageSize.height / widgetSize.height;

      final double x = signaturePosition.value!.dx * scaleX;
      final double y = pdfPageSize.height - ((signaturePosition.value!.dy + signatureBoxSize.height) * scaleY);
      final double signatureWidth = signatureBoxSize.width * scaleX;
      final double signatureHeight = signatureBoxSize.height * scaleY;

      page.graphics.drawImage(
        signatureBitmap,
        Rect.fromLTWH(x, y, signatureWidth, signatureHeight),
      );

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = pdfName.isNotEmpty ? pdfName : 'signed_pdf_${DateTime.now().millisecondsSinceEpoch}';
      final String signedPdfPath = '${tempDir.path}/$fileName.pdf';
      final File signedPdfFile = File(signedPdfPath);
      await signedPdfFile.writeAsBytes(await document.save());
      document.dispose();

      final bool uploadSuccess = await _uploadSignedPdf(signedPdfPath);
      if (uploadSuccess) {
        Get.snackbar('Success', 'Signed PDF uploaded successfully!');
      } else {
        Get.snackbar('Upload Failed', 'Upload failed. PDF saved locally.');
      }

      Get.snackbar('PDF Saved', 'Signed PDF saved at $signedPdfPath');
      Get.back();
    } catch (e, stack) {
      Get.snackbar('Exception', 'Failed: $e');
      log('Exception: $e\n$stack');
    }
  }

  Future<bool> _uploadSignedPdf(String filePath) async {

    final partnerId = box.read('partnerId');
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${Constant.BASE_URL}${ApiEndPoints.UPLOAD_PDF}?partner_id=$partnerId&ticket_number=$ticketNumber'));
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
    super.onClose();
  }

  void onInit(){
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    ticketNumber = args['ticketNumber'] ?? '';
    pdfPath.value = args['pdfPath'] ?? '';
  }
}
