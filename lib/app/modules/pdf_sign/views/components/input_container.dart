import 'package:flutter/material.dart';

import '../../../../common/app_color.dart';

BoxDecoration inputContainerDecoration() => BoxDecoration(
      color: AppColorList.WhiteText,
      boxShadow: [
        BoxShadow(
          color: AppColorList.OpacityBlack,
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
