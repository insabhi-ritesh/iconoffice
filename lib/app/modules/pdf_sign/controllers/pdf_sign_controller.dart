import 'dart:developer';
import 'dart:io';
// import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/modules/ticket_detail_page/controllers/ticket_detail_page_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../Constants/constant.dart';
import '../../../common/app_color.dart';
import '../../../common/fontSize.dart';
import '../../../routes/app_pages.dart';
import 'package:intl/intl.dart';
// import '../../../routes/app_pages.dart';
// import '../../../routes/app_pages.dart';

enum FieldType {
  none,
  signature,
  text,
  date,
  dateTime
}

class PdfSignController extends GetxController {
  final RxString pdfPath = ''.obs;
  final box = GetStorage();
  late String ticketNumber;
  var isPortalUser = false.obs;

  final PdfViewerController pdfViewerController = PdfViewerController();
  final RxInt currentPage = 1.obs;
  final RxDouble zoomLevel = 1.0.obs;
  final RxDouble zoomLevel1 = 1.0.obs;
  final RxDouble zoomLevel2 = 1.0.obs;


    final Rx<FieldType> selectedFieldType = Rx<FieldType>(FieldType.none);
  final RxBool isPlacingField = false.obs;
  final RxBool isEditingField = false.obs;

  final TextEditingController textController = TextEditingController();
  final RxString textError = ''.obs;

  var selectedDate = ''.obs;
  final RxString dateError = ''.obs;

  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  final RxString dateTimeError = ''.obs;
  final Rx<Offset> dateTimePosition = Rx<Offset>(Offset.zero);

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  final RxString signatureError = ''.obs;
  final Rx<Uint8List?> signatureImage = Rx<Uint8List?>(null);



  final RxList<PlacedField> placedTextFields = <PlacedField>[].obs;
  final RxList<PlacedField> placedDateFields = <PlacedField>[].obs;
  final RxList<PlacedField> placedDateTimeFields = <PlacedField>[].obs;
  final RxList<PlacedField> placedSignatureFields = <PlacedField>[].obs;


  final Size signatureBoxSize = const Size(150, 60);
  final Size textBoxSize = const Size(150, 40);
  final Size dateBoxSize = const Size(150, 40);
  final Size dateTimeBoxSize = const Size(240, 40);


  Future<void> placeFieldAtPercent(double percentX, double percentY) async {
    if (!isPlacingField.value) return;

    switch (selectedFieldType.value) {
      case FieldType.text:
        placedTextFields.add(
          PlacedField(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            position: Offset.zero, 
            value: textController.text,
            size: textBoxSize,
            type: FieldType.text,
            percentX: percentX,
            percentY: percentY,
            percentWidth: textBoxSize.width / 400, 
            percentHeight: textBoxSize.height / 600, 
            pageIndex: currentPage.value - 1,
          ),
        );
        textController.clear();
        break;
      case FieldType.date:
        if (selectedDate.value != '') {
          placedDateFields.add(
            PlacedField(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              position: Offset.zero,
              value: selectedDate.value.toString(),
              size: dateBoxSize,
              type: FieldType.date,
              percentX: percentX,
              percentY: percentY,
              percentWidth: dateBoxSize.width / 400,
              percentHeight: dateBoxSize.height / 600,
              pageIndex: currentPage.value - 1,
            ),
          );
          selectedDate.value = '';
        }
        break;
      case FieldType.dateTime:
        if (selectedDateTime.value != null) {
          final formatted = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime.value!);
          placedDateTimeFields.add(
            PlacedField(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              position: Offset.zero,
              // value: selectedDateTime.value.toString(),
              value: formatted,
              size: dateTimeBoxSize,
              type: FieldType.dateTime,
              percentX: percentX,
              percentY: percentY,
              percentWidth: dateTimeBoxSize.width / 400,
              percentHeight: dateTimeBoxSize.height / 600,
              pageIndex: currentPage.value - 1,
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
              position: Offset.zero,
              value: signatureImg,
              size: signatureBoxSize,
              type: FieldType.signature,
              percentX: percentX,
              percentY: percentY,
              percentWidth: signatureBoxSize.width / 400,
              percentHeight: signatureBoxSize.height / 600,
              pageIndex: currentPage.value - 1,
            ),
          );
          signatureController.clear();
          signatureImage.value = null;
        }
        break;
      default:
        break;
    }

    isPlacingField.value = false;
    selectedFieldType.value = FieldType.none;
    clearFieldSelection();
  }

  /// Update percent-based position for a field
  void updateFieldPercentPosition(PlacedField field, double percentX, double percentY) {
    switch (field.type) {
      case FieldType.text:
        final index = placedTextFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedTextFields[index] = field.copyWith(
            percentX: percentX, 
            percentY: percentY,
            pageIndex: currentPage.value - 1
          );
        }
        break;
      case FieldType.date:
        final index = placedDateFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedDateFields[index] = field.copyWith(
            percentX: percentX, 
            percentY: percentY,
            pageIndex: currentPage.value - 1
          );
        }
        break;
      case FieldType.dateTime:
        final index = placedDateTimeFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedDateTimeFields[index] = field.copyWith(
            percentX: percentX, 
            percentY: percentY,
            pageIndex: currentPage.value - 1
          );
        }
        break;
      case FieldType.signature:
        final index = placedSignatureFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedSignatureFields[index] = field.copyWith(
            percentX: percentX, 
            percentY: percentY,
            pageIndex: currentPage.value - 1
          );
        }
        break;
      default:
        break;
    }
  }

  /// Update percent-based size for a field
  void updateFieldPercentSize(PlacedField field, double percentWidth, double percentHeight) {
    switch (field.type) {
      case FieldType.text:
        final index = placedTextFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedTextFields[index] = field.copyWith(percentWidth: percentWidth, percentHeight: percentHeight);
          zoomLevel.value = 1 + (percentWidth + percentHeight);
        }
        break;
      case FieldType.date:
        final index = placedDateFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedDateFields[index] = field.copyWith(percentWidth: percentWidth, percentHeight: percentHeight);
          zoomLevel1.value = 1 + (percentWidth + percentHeight);
        }
        break;
      case FieldType.dateTime:
        final index = placedDateTimeFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedDateTimeFields[index] = field.copyWith(percentWidth: percentWidth, percentHeight: percentHeight);
          zoomLevel2.value = 1 + (percentWidth + percentHeight);
        }
        break;
      case FieldType.signature:
        final index = placedSignatureFields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          placedSignatureFields[index] = field.copyWith(percentWidth: percentWidth, percentHeight: percentHeight);
        }
        break;
      default:
        break;
    }
  }

  // Select field type
  void selectFieldType(FieldType type) {
    selectedFieldType.value = type;
    isEditingField.value = true;
    isPlacingField.value = false;
  }

  // Clear current field selection
  void clearFieldSelection() {
    selectedFieldType.value = FieldType.none;
    isEditingField.value = false;
    isPlacingField.value = false;
    textError.value = '';
    dateError.value = '';
    dateTimeError.value = '';
    signatureError.value = '';
  }

  void prepareToPlaceField() {
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
        if (selectedDate.value == '') {
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

  void resizeField(String id, FieldType type, Size newSize) {
    switch (type) {
      case FieldType.text:
        final index = placedTextFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedTextFields[index];
          placedTextFields[index] = field.copyWith(size: newSize);
        }
        break;
      case FieldType.date:
        final index = placedDateFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedDateFields[index];
          placedDateFields[index] = field.copyWith(size: newSize);
        }
        break;
      case FieldType.dateTime:
        final index = placedDateTimeFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedDateTimeFields[index];
          placedDateTimeFields[index] = field.copyWith(size: newSize);
        }
        break;
      case FieldType.signature:
        final index = placedSignatureFields.indexWhere((field) => field.id == id);
        if (index != -1) {
          final field = placedSignatureFields[index];
          placedSignatureFields[index] = field.copyWith(size: newSize);
        }
        break;
      default:
        break;
    }
  }

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

  bool validateInputs() {
    return placedTextFields.isNotEmpty ||
        placedDateFields.isNotEmpty ||
        placedDateTimeFields.isNotEmpty ||
        placedSignatureFields.isNotEmpty;
  }

  void updateFieldPosition(PlacedField field, Offset delta) {
    moveField(field.id, field.type, delta);
  }

  void removeField1(PlacedField field, FieldType type) {
    removeField(field.id, type);
  }

  void updateFieldSize(PlacedField field, Size newSize) {
    resizeField(field.id, field.type, newSize);
  }

  Future<void> savePdfWithFields() async {
    final File file = File(pdfPath.value);
    log('this is the file path $file');
    if (!file.existsSync()) {
      print('PDF not found');
      return;
    }

    final Uint8List originalBytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: originalBytes);

    final Size pageSize = Size(
      document.pages[0].size.width,
      document.pages[0].size.height,
    );

    // Helper to draw on any page
    void drawTextOnPage({
      required int pageIndex,
      required String text,
      required double percentX,
      required double percentY,
      required double percentWidth,
      required double percentHeight,
    }) {
      final page  = document.pages[pageIndex];
      final x     = percentX     * pageSize.width;
      final y     = percentY     * pageSize.height;
      final boxW  = percentWidth * pageSize.width;
      final boxH  = percentHeight* pageSize.height;

      // font size ≈ 80 % of the rectangle height; clamp to sane bounds
      final fontSize = (boxH * .80).clamp(6, 48).toDouble();
      final font     = PdfStandardFont(PdfFontFamily.helvetica, fontSize);

      page.graphics.drawString(
        text,
        font,
        bounds: Rect.fromLTWH(x, y, boxW, boxH),
      );
    }


    // final font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    // Draw Text fields
    for (final field in placedTextFields) {
      drawTextOnPage(
        pageIndex    : field.pageIndex ?? 0,
        text         : field.value as String,
        percentX     : field.percentX,
        percentY     : field.percentY,
        percentWidth : field.percentWidth,
        percentHeight: field.percentHeight,
      );
    }


    // Draw Date fields
    for (var field in placedDateFields) {
      drawTextOnPage(
        pageIndex    : field.pageIndex ?? 0,
        text         : field.value as String,
        percentX     : field.percentX,
        percentY     : field.percentY,
        percentWidth : field.percentWidth,
        percentHeight: field.percentHeight,
      );
    }

    // Draw DateTime fields
    for (var field in placedDateTimeFields) {
      drawTextOnPage(
        pageIndex    : field.pageIndex ?? 0,
        text         : field.value as String,
        percentX     : field.percentX,
        percentY     : field.percentY,
        percentWidth : field.percentWidth,
        percentHeight: field.percentHeight,
      );
    }

    // Draw Signature fields
    for (var field in placedSignatureFields) {
      final page = document.pages[field.pageIndex ?? 0];
      final double x = field.percentX * pageSize.width;
      final double y = field.percentY * pageSize.height;
      final double width = field.percentWidth * pageSize.width;
      final double height = field.percentHeight * pageSize.height;

      final signature = PdfBitmap(field.value as Uint8List);
      page.graphics.drawImage(signature, Rect.fromLTWH(x, y, width, height));
    }
    showPopUp1();

    try {

    // Save to new file
      final List<int> modifiedBytes = await document.save();
      document.dispose();

      // final Directory parentDir = file.parent;
      // final String randomSuffix = getRandomString(2);
      final String baseName = '${file.uri.pathSegments.last}';
      log(baseName.toString());
      // final String outputPath = await getUniquePdfFilePath(parentDir, baseName);
      final outputPath = '${file.parent.path}/${file.uri.pathSegments.last}';
      final File output = File(outputPath);
      await output.writeAsBytes(modifiedBytes);
      pdfPath.value = output.path;

      // await OpenFilex.open(outputPath);


      final bool uploadSuccess = await uploadSignedPdf(output.path);

      if (uploadSuccess) {
        try {
          // Get.back(); // Close the upload dialog
          // if (await output.exists()) {
          //   await output.delete();
          // }
          // showPopUp2();
          // Get.offNamed(Routes.TICKET_DETAIL_PAGE, arguments: ticketNumber);
          Get.until((route){
            return route.settings.name == Routes.TICKET_DETAIL_PAGE;
          });

          final ticketController = Get.find<TicketDetailPageController>();
          ticketController.GetTicketData(ticketNumber);         
        } catch (e) {
          // log('Failed to delete signed PDF: $e');
        }
        clearAllFields();
        Get.snackbar('Success', 'PDF uploaded successfully!');
        
        // Get.back();
      } else {
        Get.snackbar('Upload Failed', 'Upload failed. PDF saved locally.');
      }
    } catch(e){
      // log("Error saving PDF: $e");
      Get.snackbar('Error', 'Failed to save PDF. Please try again.');
    }
  }
  Future<bool> uploadSignedPdf(String filePath) async {
    final partnerId = box.read('partnerId');
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constant.BASE_URL}${ApiEndPoints.UPLOAD_PDF}?partner_id=$partnerId&ticket_number=$ticketNumber'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();

      if(isPortalUser.value) {
        if (response.statusCode == 200) {
          // log('PDF uploaded successfully: $response.');
        }
      }
      if (response.statusCode != 200) {
        // log('Failed to upload PDF: ${response.statusCode}');
        Get.snackbar("Error", "Failed to upload PDF: ${response.statusCode}");
        return false;
      }else {
        log('PDF uploaded successfully: $response.');
        // Get.snackbar("Success", "PDF uploaded successfully.");
        // Get.back();
      }
      return response.statusCode == 200;
    } catch (e) {
      // log('Upload failed: $e');
      Get.snackbar("Error", "Cannot able to upload PDF, please try again later.");
      return false;
    }
  }

  // String getRandomString(int length) {
  //   const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  //   final rand = Random();
  //   return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  // }

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
    ticketNumber = args['ticket_number'] ?? '';
    pdfPath.value = args['pdfPath'] ?? '';
    listenToZoom();  // <<--- Start listening to zoom changes
  }

  //Listen to zoom changes (call this in your view's initState)
  void listenToZoom() {
    pdfViewerController.addListener(() {
      zoomLevel.value = pdfViewerController.zoomLevel;
    });
  }

  void showPopUp1() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Please wait...\nPreparing PDF for uploading',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.size3,
              fontWeight: AppFontWeight.font3),
              
            ),

            const SizedBox(height: 20),

            // Loader at the bottom
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColorList.AppColor, size: AppFontSize.sizeLarge
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    Future.delayed(const Duration(seconds: 2), () {
      // Get.back(); // Close the dialog after 2 seconds
    });
  }

  void showPopUp2() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PDF uploaded successfully',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.size3,
              fontWeight: AppFontWeight.font3),
              
            ),

            const SizedBox(height: 20),

            // Loader at the bottom
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColorList.AppColor, size: AppFontSize.sizeLarge
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    Future.delayed(const Duration(seconds: 2), () {
      // Get.back(); // Close the dialog after 2 seconds
    });

  }


  void clearAllFields() {
    placedTextFields.clear();
    placedDateFields.clear();
    placedDateTimeFields.clear();
    placedSignatureFields.clear();
    textController.clear();
    selectedDate.value = '';
    selectedDateTime.value = null;
    signatureController.clear();
    signatureImage.value = null;
  }
}

Future<String> getUniquePdfFilePath(Directory directory, String baseName) async {
  String sanitizedBaseName = baseName.trim().replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
  String fileName = '$sanitizedBaseName.pdf';
  String filePath = '${directory.path}/$fileName';
  // int counter = 1;

  while (await File(filePath).exists()) {
    fileName = '$sanitizedBaseName.pdf';
    filePath = '${directory.path}/$fileName';
    // counter++;
  }
  return filePath;
}

class PlacedField {
  final String id;
  final Offset position;
  final dynamic value;
  final Size size;
  final FieldType type;
  int? pageIndex;

  // Percent-based fields
  final double percentX;
  final double percentY;
  final double percentWidth;
  final double percentHeight;

  PlacedField({
    required this.id,
    required this.position,
    required this.value,
    required this.size,
    required this.type,
    required this.percentX,
    required this.percentY,
    required this.percentWidth,
    required this.percentHeight,
    this.pageIndex,
  });

  PlacedField copyWith({
    String? id,
    Offset? position,
    dynamic value,
    Size? size,
    FieldType? type,
    double? percentX,
    double? percentY,
    double? percentWidth,
    double? percentHeight,
    int? pageIndex,
  }) {
    return PlacedField(
      id: id ?? this.id,
      position: position ?? this.position,
      value: value ?? this.value,
      size: size ?? this.size,
      type: type ?? this.type,
      percentX: percentX ?? this.percentX,
      percentY: percentY ?? this.percentY,
      percentWidth: percentWidth ?? this.percentWidth,
      percentHeight: percentHeight ?? this.percentHeight,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}