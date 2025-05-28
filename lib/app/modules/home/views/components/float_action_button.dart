import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';

import '../../../../routes/app_pages.dart';

Container FloatActionButton() {
    return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColorList.OpacityBlack7,
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
              Get.toNamed(Routes.PROFILE_PAGE);
            },
            child: Icon(
              Icons.person_2_rounded,
              color: AppColorList.WhiteText,
              size: 32,
            ),
          ),
        );
  }