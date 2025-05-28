import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../common/app_color.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  IconData? icon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColorList.AppBackGroundColor
    ),
    keyboardType: keyboardType,
    validator: validator,
  );
}