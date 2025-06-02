import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/pdf_sign/controllers/pdf_sign_controller.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';

AppBar pdfAppBar(String pdfName, BuildContext context, String? pdfPath) {
  final controller = Get.find<PdfSignController>();
    return AppBar(
      title: Text(
        'Sign: $pdfName',
        style: TextStyle(
          fontWeight: AppFontWeight.font7,
          color: AppColorList.WhiteText,
          fontSize: AppFontSize.size4,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColorList.AppButtonColor,
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(
            Icons.save,
            color: AppColorList.WhiteText,
            size: AppFontSize.sizeLarge,
          ),
          onPressed: () async {
            !controller.isPortalUser.value ? 
            await controller.saveAndUploadSignedPdf(context, pdfPath ?? '', pdfName)
            : await controller.uploadSignedPdf(pdfPath ?? '');
          },
        ),
      ],
    );
  }