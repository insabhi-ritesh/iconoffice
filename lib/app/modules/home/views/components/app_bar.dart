import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';

import '../../../../common/fontSize.dart';
import '../../../../routes/app_pages.dart';

AppBar homeAppBar() {
    return AppBar(
          backgroundColor: AppColorList.AppButtonColor,
          elevation: 0,
          title: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColorList.AppButtonColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'Ticket List',
              style: TextStyle(
                fontSize: AppFontSize.size1,
                fontWeight: AppFontWeight.font3,
                color: AppColorList.WhiteText,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.notification_important_sharp, color: AppColorList.WhiteText),
              onPressed: () {
                Get.toNamed(Routes.NOTIFY_PAGE);
              },
            ),
          ],
        );
  }