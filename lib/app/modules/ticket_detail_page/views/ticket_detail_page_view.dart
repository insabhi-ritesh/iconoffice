
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_color.dart';
import '../../home/views/components/priority.dart';
import '../controllers/ticket_detail_page_controller.dart';

class TicketDetailPageView extends StatelessWidget {
  const TicketDetailPageView({Key? key}) : super(key: key);

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
          ),
          body: Obx(() {
            if (controller.ticket_details.isEmpty) {
              return const Center(child: CircularProgressIndicator());
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
                        ticketInfoRow('Ticket Reference', ticket.tref1?.trim() ?? '---'),
                        ticketInfoRow('Serial No', ticket.serialNo1?.trim() ?? '---'),
                        // ticketInfoRow('Ticket Created', ticket. ?? '---'),
                        // ticketInfoRow('Created By', ticket.createdBy ?? '---'),
                        ticketInfoRow('Team Leader', ticket.teamLeader1 ?? '---'),
                        // ticketInfoRow('Priority', ticket.priority1?.toString() ?? '---'),
                        ticketInfoRow('State', ticket.state1 ?? '---'),
                        // ticketInfoRow('Close Date', ticket.cl ?? '---'),
                        // ticketInfoRow('Total Hours Spent', ticket.totalHours?.toString() ?? '---'),
                        // ticketInfoRow('Email Ticket', ticket.tem ?? '---'),
                        ticketInfoRow('Is Ticket Closed', (ticket.state1?.toLowerCase() == 'closed') ? 'Yes' : 'No'),
                        ticketInfoRow('Fault Area', ticket.faultArea1 ?? '---'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // === Expandable Sections ===
                  sectionBox(
                    'Spare Parts',
                    (ticket.spareParts1 != null && ticket.spareParts1!.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ticket.spareParts1!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(ticket.spareParts1![index].toString()),
                              );
                            },
                          )
                        : const ListTile(title: Text('No Spare Parts Available')),
                  ),

                  sectionBox(
                    'Timesheet',
                    (ticket.timesheets1 != null && ticket.timesheets1!.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ticket.timesheets1!.length,
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
                    (ticket.temailFrom1 != null && ticket.temailFrom1!.isNotEmpty)
                        ? ListTile(title: Text(ticket.temailFrom1!))
                        : const ListTile(title: Text('No Email Details Available')),
                  ),

                  sectionBox(
                    'Resolution',
                    (ticket.resolution1 != null && ticket.resolution1!.isNotEmpty)
                        ? ListTile(title: Text(ticket.resolution1!))
                        : const ListTile(title: Text('No Resolution Information')),
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
