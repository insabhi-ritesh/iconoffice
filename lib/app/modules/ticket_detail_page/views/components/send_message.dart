
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/app_color.dart';
import '../../controllers/ticket_detail_page_controller.dart';

Padding sendMessageSection(
  RxList<PlatformFile> selectedFiles,
  TextEditingController messageController,
  TicketDetailPageController callController,
  ticket,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Attachments section (left side, OUTSIDE the container)
        // Obx(() => Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: AppColorList.AppButtonColor,
        //             foregroundColor: AppColorList.WhiteText,
        //             minimumSize: const Size(36, 36),
        //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //           ),
        //           onPressed: () async {
        //             FilePickerResult? result = await FilePicker.platform.pickFiles(
        //               allowMultiple: true,
        //             );
        //             if (result != null) {
        //               selectedFiles.addAll(result.files);
        //             }
        //           },
        //           child: const Icon(Icons.attach_file, size: 20),
        //         ),
        //         if (selectedFiles.isNotEmpty)
        //           Container(
        //             margin: const EdgeInsets.only(top: 6),
        //             constraints: const BoxConstraints(maxHeight: 70, minWidth: 60),
        //             width: 70,
        //             child: ListView(
        //               shrinkWrap: true,
        //               children: selectedFiles
        //                   .map((file) => Container(
        //                         margin: const EdgeInsets.only(bottom: 6),
        //                         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        //                         decoration: BoxDecoration(
        //                           border: Border.all(color: AppColorList.AppTextColor),
        //                           borderRadius: BorderRadius.circular(8),
        //                           color: AppColorList.AppBackGroundColor,
        //                         ),
        //                         child: Row(
        //                           mainAxisSize: MainAxisSize.min,
        //                           children: [
        //                             const Icon(Icons.insert_drive_file, size: 14),
        //                             const SizedBox(width: 2),
        //                             Flexible(
        //                               child: Text(
        //                                 file.name.length > 10
        //                                     ? file.name.substring(0, 8) + '...'
        //                                     : file.name,
        //                                 overflow: TextOverflow.ellipsis,
        //                                 style: const TextStyle(fontSize: 11),
        //                               ),
        //                             ),
        //                             GestureDetector(
        //                               onTap: () {
        //                                 selectedFiles.remove(file);
        //                               },
        //                               child: const Padding(
        //                                 padding: EdgeInsets.only(left: 2),
        //                                 child: Icon(Icons.close, size: 12),
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ))
        //                   .toList(),
        //             ),
        //           ),
        //       ],
        //     )),
        // const SizedBox(width: 10),
        // Message input and send button (inside the container)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    String msgText = messageController.text.trim();
                    // if (msgText.isNotEmpty) {
                    // Send message and attachments
                    await callController.sendMessage(
                      ticket.ticket_id,
                      msgText,
                      files: selectedFiles.toList(),
                    );
                    // messageController.clear();
                    // selectedFiles.clear();
                    FocusScope.of(context).unfocus();
                    // } else {
                    //   Get.snackbar("Empty", "Please type a message first");
                    // }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}