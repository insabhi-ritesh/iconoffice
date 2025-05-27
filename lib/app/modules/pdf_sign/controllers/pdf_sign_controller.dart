import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/modules/ticket_detail_page/controllers/ticket_detail_page_controller.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../Constants/constant.dart';
import '../../../models/input_field.dart';

enum FieldType {
  none,
  signature,
  text,
  date,
  dateTime
}

class PdfSignController extends GetxController {
  // PDF and signature
  final RxString pdfPath = ''.obs;
  final box = GetStorage();
  late String ticketNumber;
  var isPortalUser = false.obs;

  final PdfViewerController pdfViewerController = PdfViewerController();
  final RxInt currentPage = 1.obs;

  // Selected field type
  final Rx<FieldType> selectedFieldType = Rx<FieldType>(FieldType.none);
  final RxBool isPlacingField = false.obs;
  final RxBool isEditingField = false.obs;

  // Text field
  final TextEditingController textController = TextEditingController();
  final RxString textError = ''.obs;
  final RxList<PlacedField> placedTextFields = <PlacedField>[].obs;

  // Date field
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString dateError = ''.obs;
  final RxList<PlacedField> placedDateFields = <PlacedField>[].obs;

  // DateTime field
  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxString dateTimeError = ''.obs;
  final RxList<PlacedField> placedDateTimeFields = <PlacedField>[].obs;
  final Rx<Offset> dateTimePosition = Rx<Offset>(Offset.zero);

  // Signature field
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  final RxString signatureError = ''.obs;
  final RxList<PlacedField> placedSignatureFields = <PlacedField>[].obs;
  final Rx<Uint8List?> signatureImage = Rx<Uint8List?>(null);

  // Sizes for fields
  final Size signatureBoxSize = const Size(150, 60);
  final Size textBoxSize = const Size(150, 40);
  final Size dateBoxSize = const Size(150, 40);
  final Size dateTimeBoxSize = const Size(180, 40);

  // Select field type
  void selectFieldType(FieldType  type) {
    selectedFieldType.value = type;
    isEditingField.value = true;
    isPlacingField.value = false;
  }

  // Clear current field selection
  void clearFieldSelection() {
    selectedFieldType.value = FieldType.none;
    isEditingField.value = false;
    isPlacingField.value = false;
  }

  // Prepare to place field on PDF
  void prepareToPlaceField() {
    // Validate the current field data before placing
    bool isValid = true;
    
    switch (selectedFieldType.value) {
      case FieldType.text:
        if (textController.text.trim().isEmpty) {
          textError.value = 'Text is required';
          isValid = false;
        } else {
          textError.value = '';
        }
        break;
      case FieldType.date:
        if (selectedDate.value == null) {
          dateError.value = 'Date is required';
          isValid = false;
        } else {
          dateError.value = '';
        }
        break;
      case FieldType.dateTime:
        if (selectedDateTime.value == null) {
          dateTimeError.value = 'Date & Time is required';
          isValid = false;
        } else {
          dateTimeError.value = '';
        }
        break;
      case FieldType.signature:
        if (!signatureController.isNotEmpty) {
          signatureError.value = 'Signature is required';
          isValid = false;
        } else {
          signatureError.value = '';
          // Export signature image for preview
          signatureController.toPngBytes().then((value) {
            signatureImage.value = value;
          });
        }
        break;
      default:
        break;
    }

    if (isValid) {
      isEditingField.value = false;
      isPlacingField.value = true;
    }
  }

  // Place field at the tapped position
  Future<void> placeFieldAt(Offset position) async {
    if (!isPlacingField.value) return;

    switch (selectedFieldType.value) {
      case FieldType.text:
        placedTextFields.add(
          PlacedField(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            position: position,
            value: textController.text,
            size: textBoxSize,
          ),
        );
        textController.clear();
        break;
      case FieldType.date:
        if (selectedDate.value != null) {
          placedDateFields.add(
            PlacedField(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              position: position,
              value: DateFormat('yyyy-MM-dd').format(selectedDate.value!),
              size: dateBoxSize,
            ),
          );
          selectedDate.value = null;
        }
        break;
      case FieldType.dateTime:
        if (selectedDateTime.value != null) {
          placedDateTimeFields.add(
            PlacedField(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              position: position,
              value: DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime.value!),
              size: dateTimeBoxSize,
            ),
          );
          selectedDateTime.value = null;
        }
        break;
      case FieldType.signature:
        final Uint8List? signatureImg = await signatureController.toPngBytes();
        if (signatureImg != null) {
          placedSignatureFields.add(
            PlacedField(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              position: position,
              value: signatureImg,
              size: signatureBoxSize,
            ),
          );
          signatureController.clear();
          signatureImage.value = null;
        }
        break;
      default:
        break;
    }

    // Reset state after placing
    isPlacingField.value = false;
    selectedFieldType.value = FieldType.none;
  }

  // Move a placed field
  void moveField(String id, FieldType type, Offset delta) {
    switch (type) {
      case FieldType.text:
        final index = placedTextFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedTextFields[index];
          placedTextFields[index] = field.copyWith(
            position: field.position + delta,
          );
        }
        break;
      case FieldType.date:
        final index = placedDateFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedDateFields[index];
          placedDateFields[index] = field.copyWith(
            position: field.position + delta,
          );
        }
        break;
      case FieldType.dateTime:
        final index = placedDateTimeFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedDateTimeFields[index];
          placedDateTimeFields[index] = field.copyWith(
            position: field.position + delta,
          );
        }
        break;
      case FieldType.signature:
        final index = placedSignatureFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedSignatureFields[index];
          placedSignatureFields[index] = field.copyWith(
            position: field.position + delta,
          );
        }
        break;
      default:
        break;
    }
  }

  // Remove a placed field
  void removeField(String id, FieldType type) {
    switch (type) {
      case FieldType.text:
        placedTextFields.removeWhere((field) => field.id == id);
        break;
      case FieldType.date:
        placedDateFields.removeWhere((field) => field.id == id);
        break;
      case FieldType.dateTime:
        placedDateTimeFields.removeWhere((field) => field.id == id);
        break;
      case FieldType.signature:
        placedSignatureFields.removeWhere((field) => field.id == id);
        break;
      default:
        break;
    }
  }

  // Validation
  bool validateInputs() {
    return placedTextFields.isNotEmpty || 
           placedDateFields.isNotEmpty || 
           placedDateTimeFields.isNotEmpty || 
           placedSignatureFields.isNotEmpty;
  }
  Future<void> saveAndUploadSignedPdf(
    BuildContext context,
    String pdfPath,
    String pdfName, {
    Size? pdfViewSize,
  }) async {
    File? signedPdfFile;
    bool uploadSuccess = false;
    try {
      if (!validateInputs()) {
        Get.snackbar('Error', 'Please add at least one field to the document.');
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
      final Size pdfPageSize = Size(page.getClientSize().width, page.getClientSize().height);
      final Size widgetSize = pdfViewSize ?? Size(Get.width, Get.height - 200); // Approximate PDF viewer size

      // Helper to scale positions
      Offset scaleOffset(Offset widgetOffset, Size widgetBoxSize, Size pdfBoxSize) {
        final double scaleX = pdfBoxSize.width / widgetSize.width;
        final double scaleY = pdfBoxSize.height / widgetSize.height;
        return Offset(
          widgetOffset.dx * scaleX, 
          pdfBoxSize.height - ((widgetOffset.dy + widgetBoxSize.height) * scaleY)
        );
      }

      // Draw text fields
      for (final field in placedTextFields) {
        final Offset pos = scaleOffset(field.position, field.size, pdfPageSize);
        page.graphics.drawString(
          field.value as String,
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pos.dx, pos.dy, field.size.width, field.size.height),
        );
      }

      // Draw date fields
      for (final field in placedDateFields) {
        final Offset pos = scaleOffset(field.position, field.size, pdfPageSize);
        page.graphics.drawString(
          field.value as String,
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pos.dx, pos.dy, field.size.width, field.size.height),
        );
      }

      // Draw datetime fields
      for (final field in placedDateTimeFields) {
        final Offset pos = scaleOffset(field.position, field.size, pdfPageSize);
        page.graphics.drawString(
          field.value as String,
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pos.dx, pos.dy, field.size.width, field.size.height),
        );
      }

      // Draw signature fields
      for (final field in placedSignatureFields) {
        final Offset pos = scaleOffset(field.position, field.size, pdfPageSize);
        final PdfBitmap signatureBitmap = PdfBitmap(field.value as Uint8List);
        page.graphics.drawImage(
          signatureBitmap,
          Rect.fromLTWH(pos.dx, pos.dy, field.size.width, field.size.height),
        );
      }

      // Save PDF
      final Directory tempDir = await getTemporaryDirectory();
      // final String fileName = pdfName.isNotEmpty ? pdfName : 'signed_pdf_${DateTime.now().millisecondsSinceEpoch}';
      // final String signedPdfPath = '${tempDir.path}/$fileName.pdf';
      final String baseName = pdfName.isNotEmpty ? pdfName : 'signed_pdf_${DateTime.now().millisecondsSinceEpoch}';
      final String signedPdfPath = await getUniquePdfFilePath(tempDir, baseName);
      final File signedPdfFile = File(signedPdfPath);

      await signedPdfFile.writeAsBytes(await document.save());
      document.dispose();

      final bool uploadSuccess = await _uploadSignedPdf(signedPdfPath);

      if (uploadSuccess) {
        try {
          if (await signedPdfFile.exists()) {
            await signedPdfFile.delete();
          }
          // Get.offAllNamed(Routes.TICKET_DETAIL_PAGE);
          Get.back();
          Get.find<TicketDetailPageController>().GetTicketData(ticketNumber);
        } catch (e) {
          log('Failed to delete signed PDF: $e');
        }
        clearAllFields();
        Get.snackbar('Success', 'Signed PDF uploaded successfully!');
        Get.back();
      } else {
        Get.snackbar('Upload Failed', 'Upload failed. PDF saved locally.');
      }

      Get.back();
    } catch (e, stack) {
      Get.snackbar('Exception', 'Failed: to upload signed pdf');
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
    isPortalUser.value = box.read('is_portal_user') ?? false;
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    ticketNumber = args['ticketNumber'] ?? '';
    pdfPath.value = args['pdfPath'] ?? '';
  }


  void clearAllFields() {
    placedTextFields.clear();
    placedDateFields.clear();
    placedDateTimeFields.clear();
    placedSignatureFields.clear();
    textController.clear();
    selectedDate.value = null;
    selectedDateTime.value = null;
    signatureController.clear();
    signatureImage.value = null;

    // Optionally clear the PDF path if you want to reset the state
    // pdfPath.value = '';
  }

  
  // Add this method to your PdfSignController class
  void updateFieldPosition(PlacedField field, Offset delta) {
    // Update the field's position by adding the delta from the drag gesture
    field.position = Offset(
      field.position.dx + delta.dx,
      field.position.dy + delta.dy,
    );
    
    // Trigger UI update
    update();
    
    // If you're using specific lists for different field types, you may need to update
    // the specific list that contains this field
    if (placedTextFields.contains(field)) {
      placedTextFields.refresh();
    } else if (placedDateFields.contains(field)) {
      placedDateFields.refresh();
    } else if (placedDateTimeFields.contains(field)) {
      placedDateTimeFields.refresh();
    } else if (placedSignatureFields.contains(field)) {
      placedSignatureFields.refresh();
    }
  }

  // You might also need the removeField method if it's not already implemented
  void removeField1(PlacedField field, FieldType type) {
    switch (type) {
      case FieldType.text:
        placedTextFields.remove(field);
        break;
      case FieldType.date:
        placedDateFields.remove(field);
        break;
      case FieldType.dateTime:
        placedDateTimeFields.remove(field);
        break;
      case FieldType.signature:
        placedSignatureFields.remove(field);
        break;
      case FieldType.none:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
    update();
  }
  void updateFieldSize(PlacedField field, Size newSize) {
    field.size = newSize; // If Rx<Size>, use field.size.value = newSize;
    placedTextFields.refresh();
    placedDateFields.refresh();
    placedDateTimeFields.refresh();
    placedSignatureFields.refresh();
  }
}


// Helper function to generate unique PDF file paths
Future<String> getUniquePdfFilePath(Directory directory, String baseName) async {
  String sanitizedBaseName = baseName.trim().replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
  String fileName = '$sanitizedBaseName.pdf';
  String filePath = '${directory.path}/$fileName';
  int counter = 1;

  while (await File(filePath).exists()) {
    fileName = '$sanitizedBaseName($counter).pdf';
    filePath = '${directory.path}/$fileName';
    counter++;
  }
  return filePath;
}



extension on PdfDocument {
  get ready => null;
}