import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:insabhi_icon_office/app/modules/pdf_sign/views/pdf_sign_view.dart';
import '../../../common/app_color.dart';
import '../../pdf_sign/views/pdf_viewer_page.dart';
import '../controllers/ticket_detail_page_controller.dart';
import 'components/send_message.dart';
import 'components/ticket_header.dart';
import 'components/ticket_info_box.dart';
import 'components/timesheet_form.dart';
import 'components/view_message.dart';
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
    // if (!isSelected) return Colors.grey.shade300;
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
                    _ticketHeader(context, controller, ticket),
                    const SizedBox(height: 16),
                    _ticketInfoBox(ticket),
                    const SizedBox(height: 24),
                    const Divider(),
                    _ticketSections(ticket, controller, context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
              onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
              );
              if (result != null && result.files.isNotEmpty) {

                await controller.previewFile(context, result.files.first);
                fabSelectedFiles.addAll(result.files);
                showAttachmentBottomSheet(context);
              }
            },
              child: Icon(
                Icons.attach_file,
                color: AppColorList.WhiteText,
                size: 32, // <-- increase this value for a bigger icon
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ticketHeader(BuildContext context, TicketDetailPageController controller, var ticket) {
    final currentStateIndex = getSelectedStateIndex(ticket.state1);
    return ticketHeaderBody(context, ticket, controller, currentStateIndex);
  }

  Widget _ticketInfoBox(ticket) {
    return ticketInfoBox(ticket);
  }

  Widget _ticketSections(ticket, controller, BuildContext context) {
    final cont = Get.find<TicketDetailPageController>();
    return Column(
      children: [
        if(!cont.is_portal_user.value) ...[
        
        sectionBox('Spare Parts', _buildListOrEmpty(ticket.spareParts1)),
        sectionBox('Timesheet', _buildTimesheet(ticket.timesheets1, controller, context, ticket.ticketNo1)),
        // sectionBox('Ticket Email Detail', _textOrEmpty(ticket.temailFrom1)),
        // sectionBox('Resolution', _textOrEmpty(ticket.resolution1)),
        sectionBox('Document attachments', _buildAttachments(ticket.pdfDocuments, controller, context, ticket)),
        // sectionBox('Send Message', _buildListOrEmpty(ticket.spareParts1, 'No Spare Parts Available')),
        ],
        sectionBox('Messages', _buildMessageSection(ticket, controller, context)),
      ],
    );
  }

  

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

  Widget _buildListOrEmpty(List<dynamic> list) {
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

  Widget _buildTimesheet(List<dynamic> timesheets, TicketDetailPageController controller, BuildContext context, String ticketNo1) {
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


  // Widget _textOrEmpty(String? text) {
  //   return text?.isNotEmpty == true ? ListTile(title: Text(text!)) : const ListTile(title: Text('No Data'));
  // }

  Widget _buildAttachments(List pdfDocs, controller, BuildContext context, var ticket) {
    return pdfDocs.isNotEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pdfDocs.map<Widget>((pdfDoc) {
            return ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(pdfDoc.name),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Get.to(() => PdfViewerPage(url: '${Constant.BASE_URL}${pdfDoc.url}', name: pdfDoc.name)),
              ),
              onTap: () async {
                final url = '${Constant.BASE_URL}${pdfDoc.url}';
                final fileName = pdfDoc.name.replaceAll(' ', '_');
                final localPath = await controller.downloadPdf(url, fileName, context);
                if (localPath != null) {
                  Get.to(() => PdfSignView(), arguments: {'pdfPath': localPath, 'pdfName': pdfDoc.name, 'ticketNumber': ticket.ticketNo1});
                }
              },
            );
          }
        ).toList(),
      )
    : const ListTile(title: Text('No Document Attachments'));
  }

  


  // ... inside TicketDetailPageView ...

  void showAttachmentBottomSheet(BuildContext context) {
    final controller = Get.find<TicketDetailPageController>();
    // Get the current ticket (you may need to pass this as a parameter if not available here)
    final ticket = controller.ticket_details.isNotEmpty ? controller.ticket_details[0] : null;

    Get.bottomSheet(
      Obx(() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorList.AppBackGroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Selected Attachments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (fabSelectedFiles.isEmpty)
              const Text("No files selected."),
            if (fabSelectedFiles.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView(
                  shrinkWrap: true,
                  children: fabSelectedFiles
                      .map((file) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColorList.AppTextColor),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColorList.ContainerBackground,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.insert_drive_file, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    file.name.length > 18
                                        ? file.name.substring(0, 16) + '...'
                                        : file.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    fabSelectedFiles.remove(file);
                                  },
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Get.back();
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Send"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorList.AppButtonColor,
                    foregroundColor: AppColorList.WhiteText,
                  ),
                  onPressed: fabSelectedFiles.isEmpty || ticket == null
                      ? null
                      : () async {
                          // Optionally show a loading indicator
                          Get.back();
                          Get.snackbar("Uploading", "Sending attachments...");
                          await controller.sendMessage(
                            ticket.ticket_id,
                            "", // No message text, just attachments
                            files: fabSelectedFiles.toList(),
                          );
                          fabSelectedFiles.clear();
                          // Optionally refresh ticket/messages here if not handled in controller
                          Get.snackbar("Success", "Attachments sent!");
                        },
                ),
              ],
            ),
          ],
        ),
      )),
      isScrollControlled: true,
    );
  }

    
  Widget _buildMessageSection(ticket, controller, BuildContext context) {
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
}
