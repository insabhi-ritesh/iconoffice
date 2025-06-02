import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_color.dart';
import '../controllers/ticket_detail_page_controller.dart';
import 'components/body_section.dart';
import 'components/float_action_button.dart';
import 'components/ticket_header.dart';
import 'components/ticket_info_box.dart';
import 'ticket_details_loader/ticket_details_loader.dart';


class TicketDetailPageView extends StatelessWidget {
  TicketDetailPageView({super.key});

  static const List<String> stateKeys = ['assigned', 'work_in', 'closed'];
  static const List<String> stateLabels = ['Assigned', 'Work in Progress', 'Closed'];

  final RxList<PlatformFile> fabSelectedFiles = <PlatformFile>[].obs;

  int getSelectedStateIndex(String? state) {
    if (state == null) return 0;
    final idx = stateKeys.indexOf(state.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  Color getStateButtonColor(String stateKey, bool isSelected) {
    switch (stateKey) {
      case 'assigned':
        return AppColorList.Star1;
      case 'work_in':
        return AppColorList.yellow_shade;
      case 'closed':
        return AppColorList.Star3;
      default:
        return AppColorList.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketDetailPageController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Service Ticket Detail', style: TextStyle(color: AppColorList.WhiteText)),
            backgroundColor: AppColorList.AppButtonColor,
            iconTheme: IconThemeData(color: AppColorList.WhiteText),
          ),
          body: Obx(() {
            if (controller.ticket_details.isEmpty) return TicketDetailSkeleton();
            final ticket = controller.ticket_details[0];

            return RefreshIndicator(
              onRefresh: () async {
                await controller.refreshData(ticket.ticketNo1);           
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ticketHeader(context, controller, ticket),
                    const SizedBox(height: 16),
                    ticketInfoBox(ticket),
                    const SizedBox(height: 24),
                    const Divider(),
                    ticketSections(ticket, controller, context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }),
          floatingActionButton: tickerFloatActionButton(controller.ticketNumber),
        );
      },
    );
  }

  

  Widget ticketHeader(BuildContext context, TicketDetailPageController controller, var ticket) {
    final currentStateIndex = getSelectedStateIndex(ticket.state1);
    return ticketHeaderBody(context, ticket, controller, currentStateIndex);
  }

  // Widget _ticketInfoBox(ticket) {
  //   return ticketInfoBox(ticket);
  // }

//   void showAttachmentBottomSheet(BuildContext context) {
//     final controller = Get.find<TicketDetailPageController>();
//     // Get the current ticket (you may need to pass this as a parameter if not available here)
//     final ticket = controller.ticket_details.isNotEmpty ? controller.ticket_details[0] : null;

//     Get.bottomSheet(
//       Obx(() => Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColorList.AppBackGroundColor,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Selected Attachments",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             if (fabSelectedFiles.isEmpty)
//               const Text("No files selected."),
//             if (fabSelectedFiles.isNotEmpty)
//               SizedBox(
//                 height: 120,
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: fabSelectedFiles
//                       .map((file) => Container(
//                             margin: const EdgeInsets.only(bottom: 6),
//                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: AppColorList.AppTextColor),
//                               borderRadius: BorderRadius.circular(8),
//                               color: AppColorList.ContainerBackground,
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(Icons.insert_drive_file, size: 18),
//                                 const SizedBox(width: 6),
//                                 Expanded(
//                                   child: Text(
//                                     file.name.length > 18
//                                         ? file.name.substring(0, 16) + '...'
//                                         : file.name,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 13),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.close, size: 16),
//                                   onPressed: () {
//                                     fabSelectedFiles.remove(file);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ))
//                       .toList(),
//                 ),
//               ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   child: const Text("Close"),
//                   onPressed: () {
//                     Get.back();
//                   },
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.send),
//                   label: const Text("Send"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColorList.AppButtonColor,
//                     foregroundColor: AppColorList.WhiteText,
//                   ),
//                   onPressed: fabSelectedFiles.isEmpty || ticket == null
//                       ? null
//                       : () async {
//                           // Optionally show a loading indicator
//                           Get.back();
//                           Get.snackbar("Uploading", "Sending attachments...");
//                           await controller.sendMessage(
//                             ticket.ticket_id,
//                             "", // No message text, just attachments
//                             files: fabSelectedFiles.toList(),
//                           );
//                           fabSelectedFiles.clear();
//                           // Optionally refresh ticket/messages here if not handled in controller
//                           Get.snackbar("Success", "Attachments sent!");
//                         },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       )),
//       isScrollControlled: true,
//     );
//   }
}
