import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/app_color.dart';
import '../../../pdf_sign/views/pdf_sign_view.dart';

Container tickerFloatActionButton(String id) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 5,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      shape: BoxShape.circle,
    ),
    child: FloatingActionButton(
      backgroundColor: AppColorList.AppButtonColor,
      elevation: 0,
      onPressed: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final pdfPath = pickedFile.path;
        final pdfName = pickedFile.name;

        await Get.to(
          () => const PdfSignView(),
          arguments: {
            'pdfPath' : pdfPath,
            'pdfName' : pdfName,
            "ticket_number" : id,
          },
        );

        // if(signedResult != null && signedResult['signedPdfPath'] != null){
        //   // final signedPdfPath = signedResult['signedPdfPath'];
        //   // final signedPdfName = signedResult['signedPdfName'];

        //   // await controller.uploadSignedPdf( 
        //   //   signedPdfPath,
        //   //   pdfName,
        //   //   context,
        //   // );

        //   Get.snackbar("Success", "THe pdf is successfully upoaded",
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: AppColorList.AppButtonColor,
        //     colorText: AppColorList.WhiteText,
        //   );
        // } else {
        //   Get.snackbar("Error", "Failed to sign the PDF",
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: AppColorList.AppButtonColor,
        //     colorText: AppColorList.WhiteText,  );
        //   );
        // }

        // await controller.previewFile(context, result.files.first);
        // fabSelectedFiles.addAll(result.files);
        // showAttachmentBottomSheet(context);
      }
    },
      child: Icon(
        Icons.attach_file,
        color: AppColorList.WhiteText,
        size: 32, 
      ),
    ),
  );
}