
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:insabhi_icon_office/app/modules/pdf_sign/views/pdf_sign_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../common/app_color.dart';
import '../../home/views/components/priority.dart';
import '../controllers/ticket_detail_page_controller.dart';
import 'ticket_details_loader/ticket_details_loader.dart';

class TicketDetailPageView extends StatelessWidget {
  const TicketDetailPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketDetailPageController>(
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColorList.AppColor,
          appBar: AppBar(
            title: Text('Service Ticket Detail',
              style: TextStyle(
                color: AppColorList.WhiteText
              ),
            ),
            backgroundColor: AppColorList.AppButtonColor,
            iconTheme: IconThemeData(
              color: AppColorList.WhiteText, // <-- Set your desired color here
            ),
          ),  
          body: Obx(() {
            if (controller.ticket_details.isEmpty) {
            //   return const Center(child: CircularProgressIndicator());
            // } else if (controller.islo) {
              return TicketDetailSkeleton();
            }

            // For now, show the first ticket
            final ticket = controller.ticket_details[0];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Ticket Header ===
                  Container(
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
                          children: [
                            Text(
                              ticket.ticketNo1 ?? '---',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            PriorityStars(
                              priority: int.parse(ticket.priority1),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.ticketTitle1 ?? '---',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // === Ticket Info ===
                  Container(
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
                        // ticketInfoRow('Assigned To', ticket.assiTo1?.toString() ?? '---'),
                        ticketInfoRow('Email', ticket.temailFrom1 ?? '---'),
                        ticketInfoRow('Company', ticket.customer1 ?? '---'),
                        ticketInfoRow('Customer', ticket.tpartnerName1 ?? '---'),
                        ticketInfoRow('Ticket Reference', ticket.tref1.trim() ?? '---'),
                        ticketInfoRow('Serial No', ticket.serialNo1.trim() ?? '---'),
                        // ticketInfoRow('Ticket Created', ticket. ?? '---'),
                        // ticketInfoRow('Created By', ticket.createdBy ?? '---'),
                        ticketInfoRow('Team Leader', ticket.teamLeader1 ?? '---'),
                        // ticketInfoRow('Priority', ticket.priority1?.toString() ?? '---'),
                        ticketInfoRow('State', ticket.state1 ?? '---'),
                        // ticketInfoRow('Close Date', ticket.cl ?? '---'),
                        // ticketInfoRow('Total Hours Spent', ticket.totalHours?.toString() ?? '---'),
                        // ticketInfoRow('Email Ticket', ticket.tem ?? '---'),
                        ticketInfoRow('Is Ticket Closed', (ticket.state1.toLowerCase() == 'closed') ? 'Yes' : 'No'),
                        ticketInfoRow('Fault Area', ticket.faultArea1 ?? '---'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // === Expandable Sections ===
                  sectionBox(
                    'Spare Parts',
                    (ticket.spareParts1.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ticket.spareParts1.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(ticket.spareParts1[index].toString()),
                              );
                            },
                          )
                        : const ListTile(title: Text('No Spare Parts Available')),
                  ),

                  sectionBox(
                    'Timesheet',
                    (ticket.timesheets1.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ticket.timesheets1.length,
                            itemBuilder: (context, index) {
                              final timesheet = ticket.timesheets1[index];
                              return ListTile(
                                title: Text(
                                  '${timesheet.timesheetDate ?? ''} - ${timesheet.productId ?? ''}',
                                ),
                                subtitle: Text(
                                  'Description: ${timesheet.timesheetDescription ?? ''}\n'
                                  'Hours: ${timesheet.hours ?? ''}',
                                ),
                              );
                            },
                          )
                        : const ListTile(title: Text('No Timesheet Entries')),
                  ),

                  sectionBox(
                    'Ticket Email Detail',
                    (ticket.temailFrom1.isNotEmpty)
                        ? ListTile(title: Text(ticket.temailFrom1))
                        : const ListTile(title: Text('No Email Details Available')),
                  ),

                  sectionBox(
                    'Resolution',
                    (ticket.resolution1.isNotEmpty)
                        ? ListTile(title: Text(ticket.resolution1))
                        : const ListTile(title: Text('No Resolution Information')),
                  ),

                 sectionBox(
                  'Document attachments',
                  (ticket.pdfDocuments.isNotEmpty)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ticket.pdfDocuments.map((pdfDoc) {
                            return ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                              title: Text(pdfDoc.name),
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () {
                                  final url = '${Constant.BASE_URL}${pdfDoc.url}';
                                  Get.to(() => PdfViewerPage(url: url, name: pdfDoc.name));
                                },
                              ),
                              onTap: () async {
                                final url = '${Constant.BASE_URL}${pdfDoc.url}';
                                final fileName = pdfDoc.name.replaceAll(' ', '_');
                                final localPath = await controller.downloadPdf(url, fileName, context);
                                if (localPath != null) {
                                  Get.to(() => PdfSignView(), arguments: {'pdfPath': localPath, 'pdfName': pdfDoc.name, 'ticketNumber':ticket.ticketNo1});
                                }
                              },
                            );
                          }).toList(),
                        )
                      : const ListTile(title: Text('No Document Attachments')),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget ticketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
          ),
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [content],
      ),
    );
  }
}



class PdfViewerPage extends StatelessWidget {
  final String url;
  final String name;

  const PdfViewerPage({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    // If url is relative, prepend BASE_URL
    final fullUrl = url.startsWith('http') ? url : '${Constant.BASE_URL}$url';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SfPdfViewer.network(fullUrl),
    );
  }
}
