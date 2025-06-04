import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';

Container appBar() {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: AppColorList.AppButtonColor,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        const SizedBox(width: 8),
        Text(
          'Notifications',
          style: TextStyle(
            fontSize: AppFontSize.size1,
            fontWeight: AppFontWeight.font3,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}