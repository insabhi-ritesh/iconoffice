import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:insabhi_icon_office/app/modules/pdf_sign/views/pdf_sign_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../common/app_color.dart';
import '../../../common/fontSize.dart';
import '../../home/views/components/priority.dart';
import '../controllers/ticket_detail_page_controller.dart';
import 'ticket_details_loader/ticket_details_loader.dart';

class TicketDetailPageView extends StatelessWidget {
  const TicketDetailPageView({super.key});

  static const List<String> stateKeys = ['assigned', 'work_in', 'closed'];
  static const List<String> stateLabels = ['Assigned', 'Working', 'Closed'];

  int getSelectedStateIndex(String? state) {
    if (state == null) return 0;
    final idx = stateKeys.indexOf(state.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  Color getStateButtonColor(String stateKey, bool isSelected) {
    // if (!isSelected) return Colors.grey.shade300;
    switch (stateKey) {
      case 'assigned':
        return Colors.green;
      case 'work_in':
        return Colors.yellow.shade700;
      case 'closed':
        return Colors.red;
      default:
        return Colors.blue;
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

            return SingleChildScrollView(
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
            );
          }),
        );
      },
    );
  }

  Widget _ticketHeader(BuildContext context, TicketDetailPageController controller, var ticket) {
    final currentStateIndex = getSelectedStateIndex(ticket.state1);
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.ticketNo1 ?? '---', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              PriorityStars(priority: int.tryParse(ticket.priority1 ?? '0') ?? 0),
            ],
          ),
          const SizedBox(height: 8),
          if ((ticket.ticketTitle1 ?? '').isNotEmpty)
            Text(ticket.ticketTitle1!, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          if (ticket.state1 != "closed")
            Obx(() {
              return Row(
                children: List.generate(stateKeys.length, (index) {
                  final stateKey = stateKeys[index];
                  final isSelected = controller.selectedState.value == stateKey;
                  final isFuture = index > currentStateIndex;
                  final isPast = index < currentStateIndex;
                  final isEnabled = isFuture && !isSelected;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? getStateButtonColor(stateKey, true)
                            : isPast
                                ? Colors.grey.shade400
                                : getStateButtonColor(stateKey, false),
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                        minimumSize: const Size(85, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isEnabled
                          ? () async => await controller.updateTicketState(ticket.ticketNo1, stateKey)
                          : null,
                      child: Text(stateLabels[index], style: const TextStyle(fontSize: AppFontSize.size3, fontWeight: AppFontWeight.font3)),
                    ),
                  );
                }),
              );
            })
        ],
      ),
    );
  }

  Widget _ticketInfoBox(ticket) {
    return Container(
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
      child: Column(
        children: [
          ticketInfoRow('Email', ticket.temailFrom1 ?? '---'),
          ticketInfoRow('Company', ticket.customer1 ?? '---'),
          ticketInfoRow('Customer', ticket.tpartnerName1 ?? '---'),
          ticketInfoRow('Ticket Reference', ticket.tref1.trim() ?? '---'),
          ticketInfoRow('Serial No', ticket.serialNo1.trim() ?? '---'),
          ticketInfoRow('Team Leader', ticket.teamLeader1 ?? '---'),
          ticketInfoRow('State', ticket.state1 ?? '---'),
          ticketInfoRow('Is Ticket Closed', (ticket.state1.toLowerCase() == 'closed') ? 'Yes' : 'No'),
          ticketInfoRow('Fault Area', ticket.faultArea1 ?? '---'),
        ],
      ),
    );
  }

  Widget _ticketSections(ticket, controller, BuildContext context) {
    return Column(
      children: [
        sectionBox('Spare Parts', _buildListOrEmpty(ticket.spareParts1, 'No Spare Parts Available')),
        sectionBox('Timesheet', _buildTimesheet(ticket.timesheets1)),
        sectionBox('Ticket Email Detail', _textOrEmpty(ticket.temailFrom1)),
        sectionBox('Resolution', _textOrEmpty(ticket.resolution1)),
        sectionBox('Document attachments', _buildAttachments(ticket.pdfDocuments, controller, context, ticket)),
      ],
    );
  }

  Widget ticketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
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

  Widget _buildListOrEmpty(List<dynamic> list, String emptyText) {
    return list.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) => ListTile(title: Text(list[index].toString())),
          )
        : ListTile(title: Text(emptyText));
  }

  Widget _buildTimesheet(List<dynamic> timesheets) {
    return timesheets.isNotEmpty
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
        : const ListTile(title: Text('No Timesheet Entries'));
  }

  Widget _textOrEmpty(String? text) {
    return text?.isNotEmpty == true ? ListTile(title: Text(text!)) : const ListTile(title: Text('No Data'));
  }

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
            }).toList(),
          )
        : const ListTile(title: Text('No Document Attachments'));
  }
}

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String name;

  const PdfViewerPage({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final fullUrl = url.startsWith('http') ? url : '${Constant.BASE_URL}$url';
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SfPdfViewer.network(fullUrl),
    );
  }
}