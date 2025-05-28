import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../../../routes/app_pages.dart';

AppBar portalAppBar() {
    return AppBar(
        backgroundColor: AppColorList.AppButtonColor,
          elevation: 0,
        title: const Text('Ticket Support',
          style: TextStyle(
                  fontSize: AppFontSize.size1,
                  fontWeight: AppFontWeight.font3,
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        actions: [
            IconButton(
              icon: Icon(Icons.person_2_rounded, color: AppColorList.WhiteText),
              onPressed: () {
                Get.toNamed(Routes.PROFILE_PAGE);
              },
            ),
          ],
      );
  }