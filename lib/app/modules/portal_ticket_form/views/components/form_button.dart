import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';

SizedBox SubmitButton(controller, GlobalKey<FormState> formKey) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      label: Text('Submit',
        style: TextStyle(color: AppColorList.WhiteText),
      ),
      icon: Icon(
        Icons.send,
        color: AppColorList.WhiteText, 
        size: 20
      ),
      
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorList.AppButtonColor,
        iconColor: AppColorList.WhiteText,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(fontSize: AppFontSize.size2),
      ),
      onPressed: () {
        if (formKey.currentState!.validate()) {
          controller.CreateTicket();
        }
      },
    ),
  );
}