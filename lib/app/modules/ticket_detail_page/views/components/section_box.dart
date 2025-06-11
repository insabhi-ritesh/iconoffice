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

Widget buildAttachments(
  List pdfDocs,
  TicketDetailPageController controller,
  BuildContext context,
  var ticket,
  {RxBool? isLoading}
) {
  // Use a loading state if provided, otherwise create a local one.
  final RxBool loading = isLoading ?? false.obs;

  return pdfDocs.isNotEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pdfDocs.map<Widget>((pdfDoc) {
            // Defensive: Ensure pdfDoc has required fields
            final String name = pdfDoc.name ?? 'Unnamed';
            final String url = pdfDoc.url ?? '';
            final int? attachmentId = pdfDoc.attachment_id ?? _extractIdFromUrl(url);

            return Obx(() => loading.value
                ? const Center(child: CircularProgressIndicator())
                : ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => Get.to(() => PdfViewerPage(
                                url: '${Constant.BASE_URL}$url',
                                name: name,
                                isLocal: false,
                              )),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          tooltip: 'Delete Attachment',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Attachment'),
                                content: const Text('Are you sure you want to delete this attachment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && attachmentId != null) {
                              loading.value = true;
                              try {
                                await controller.deleteAttachment(attachmentId, ticket.ticketNo1);
                                // Optionally, remove the deleted attachment from pdfDocs here if needed.
                              } finally {
                                loading.value = false;
                              }
                            } else if (attachmentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Attachment ID not found. Cannot delete.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      final localPath = await controller.downloadPdf('${Constant.BASE_URL}$url', name, context);
                      if (localPath != null) {
                        Get.to(() => PdfSignView(), arguments: {
                          'pdfPath': localPath,
                          'pdfName': name,
                          'ticket_number': ticket.ticketNo1
                        });
                      }
                    },
                  ));
          }).toList(),
        )
      : const ListTile(title: Text('No Document Attachments'));
}

/// Helper to extract attachment ID from a URL like '/web/content/12568?download=true'
int? _extractIdFromUrl(String url) {
  final regExp = RegExp(r'/web/content/(\d+)');
  final match = regExp.firstMatch(url);
  return match != null ? int.tryParse(match.group(1)!) : null;
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