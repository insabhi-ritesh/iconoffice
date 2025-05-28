import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/app_color.dart';
import '../../../../routes/app_pages.dart';

Container floatActionButton() {
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
      onPressed: () {
        Get.toNamed(Routes.PORTAL_TICKET_FORM);
      },
      child: Icon(
        Icons.add_sharp,
        color: AppColorList.WhiteText,
        size: 32, // <-- increase this value for a bigger icon
      ),
    ),
  );
}