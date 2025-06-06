import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/ticket_detail_page/views/components/send_message.dart' show sendMessageSection;
import 'package:insabhi_icon_office/app/modules/ticket_detail_page/views/components/view_message.dart';

import '../../../../Constants/constant.dart';
import '../../../../common/app_color.dart';
import '../../../pdf_sign/views/pdf_sign_view.dart';
import '../../../pdf_sign/views/pdf_viewer_page.dart';
import '../../controllers/ticket_detail_page_controller.dart';
import 'timesheet_form.dart';

Widget sectionBox(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorList.ContainerBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorList.ContainerShadow,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [content],
      ),
    );
  }

Widget buildTimesheet(List<dynamic> timesheets, TicketDetailPageController controller, BuildContext context, String ticketNo1) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      timesheets.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timesheets.length,
              itemBuilder: (context, index) {
                final t = timesheets[index];
                return ListTile(
                  title: Text('${t.timesheetDate ?? ''} - ${t.productId ?? ''}'),
                  subtitle: Text('Description: ${t.timesheetDescription ?? ''}\nHours: ${t.hours ?? ''}'),
                );
              },
            )
          : const ListTile(title: Text('No Timesheet Entries')),
      const SizedBox(height: 12),
      buildTimesheetForm(controller, context, ticketNo1, controller.selectedState.value),
    ],
  );
}

Widget buildAttachments(List pdfDocs,TicketDetailPageController controller, BuildContext context, var ticket) {
    return pdfDocs.isNotEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pdfDocs.map<Widget>((pdfDoc) {
            return ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(pdfDoc.name),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Get.to(() => PdfViewerPage(url: '${Constant.BASE_URL}${pdfDoc.url}', name: pdfDoc.name, isLocal: false,)),
              ),
              onTap: () async {
                final url = '${Constant.BASE_URL}${pdfDoc.url}';
            //     'pdfPath' : pdfPath,
            // 'pdfName' : pdfName,
            // "ticket_number" : id,
                // final fileName = pdfDoc.name.replaceAll(' ', '_');
                final localPath = await controller.downloadPdf(url, pdfDoc.name, context);
                if (localPath != null) {
                  Get.to(() => PdfSignView(), arguments: {'pdfPath': localPath, 'pdfName': pdfDoc.name, 'ticket_number': ticket.ticketNo1});
                }
              },
            );
          }
        ).toList(),
      )
    : const ListTile(title: Text('No Document Attachments'));
  }

Widget buildMessageSection(ticket, controller, BuildContext context) {
    final callController = Get.find<TicketDetailPageController>();
    final TextEditingController messageController = TextEditingController();
    final RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;

    // Scroll to top when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.message.isNotEmpty && controller.messageScrollController.hasClients) {
        controller.messageScrollController.animateTo(
          0.9,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Obx(() {
      return Container(
        height: 340,
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.3,
            color: AppColorList.AppTextColor,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
          color: AppColorList.AppBackGroundColor,
        ),
        child: Column(
          children: [
            // Message List
            viewMessage(controller),
            const SizedBox(height: 8),
            // Input box and send button with attachments on the left
            sendMessageSection(selectedFiles, messageController, callController, ticket, context),
          ],
        ),
      );
    });
  }




Widget buildListOrEmpty(List<dynamic> list) {
  return list.isNotEmpty
    ? ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
            final spare = list[index];
            return ListTile(
              title: Text('${spare.productName1 ?? ''} - ${spare.Partstate1 ?? ''}'),
              subtitle: Text('Description: ${spare.qtyUsed ?? ''}'),
            );
          },
        )
      : const ListTile(title: Text('No Spare part used')
    );
}