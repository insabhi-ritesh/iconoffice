import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';

Obx ChooseDocument(controller) {
  return Obx(() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ElevatedButton.icon(
        icon: Icon(Icons.attach_file),
        label: Text("Choose Documents"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorList.AppButtonColor,
          foregroundColor: AppColorList.WhiteText,
        ),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
          );
          if (result != null) {
            controller.setSelectedFiles(result.files);
          }
        },
      ),
      const SizedBox(height: 8),
      if (controller.selectedFiles.isNotEmpty)
        ...controller.selectedFiles.map((file) => Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColorList.AppTextColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text(file.name),
                subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    controller.removeSelectedFile(file);
                  },
                ),
              ),
        )),
      if (controller.selectedFiles.isEmpty)
        Text(
          "No documents selected.",
          style: TextStyle(color: AppColorList.AppText,
            fontSize: AppFontSize.size3,
            fontWeight: AppFontWeight.font3
          ),
        ),
    ],
  ));
}