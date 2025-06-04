import 'package:flutter/material.dart';

import '../../../../common/app_color.dart';

AppBar PortalAppBar() {
  return AppBar(
    title: Text('Create Support Ticket', 
        style: TextStyle(color: AppColorList.WhiteText)
      ),
      backgroundColor: AppColorList.AppButtonColor,
      iconTheme: IconThemeData(color: AppColorList.WhiteText),
    centerTitle: true,
    elevation: 2,
  );
}