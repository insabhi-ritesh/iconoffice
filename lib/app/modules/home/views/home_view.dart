
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../../../common/app_color.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'components/priority.dart';
import 'components/ticket_list_skeleton.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColorList.AppButtonColor,
            elevation: 0,
            title: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColorList.AppButtonColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                'Ticket List',
                style: TextStyle(
                  fontSize: AppFontSize.size1,
                  fontWeight: AppFontWeight.font3,
                  color: Colors.white,
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.notification_important_sharp, color: AppColorList.WhiteText),
                onPressed: () {
                  Get.toNamed(Routes.NOTIFY_PAGE);
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.isLoading.value && controller.tickets.isEmpty) {
                  return TicketListSkeleton(itemCount: 5);
                } else if (controller.tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Data Available",
                      style: TextStyle(
                        fontSize: AppFontSize.size1,
                        fontWeight: AppFontWeight.font3,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.isLastPage.value
                      ? controller.tickets.length
                      : controller.tickets.length + 1,
                  controller: controller.scrollController,
                  itemBuilder: (context, index) {
                    if (index == controller.tickets.length) {
                      // Show loading indicator at the bottom
                      return SingleChildScrollView(
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    final ticket = controller.tickets[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket.ticketNo,
                              style: TextStyle(
                                fontSize: AppFontSize.size2,
                                fontWeight: AppFontWeight.font3,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              height: 25,
                              width: 63,
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  PriorityStars(
                                    priority: int.parse(ticket.priority),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Ticket Title: ',
                                    style: TextStyle(fontWeight: AppFontWeight.font4),
                                  ),
                                  TextSpan(
                                    text: ticket.ticketTitle.isNotEmpty == true
                                        ? ticket.ticketTitle
                                        : 'No Title Available',
                                    style: TextStyle(fontWeight: AppFontWeight.font3),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Partner: ',
                                    style: TextStyle(fontWeight: AppFontWeight.font4),
                                  ),
                                  TextSpan(
                                    text: ticket.tpartnerName.isNotEmpty == true
                                        ? ticket.tpartnerName
                                        : 'No Partner Available',
                                    style: TextStyle(fontWeight: AppFontWeight.font3),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(ticket.state).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Status: ${getStatusLabel(ticket.state)}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: AppColorList.AppText,
                                  fontWeight: AppFontWeight.font3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Get.toNamed(Routes.TICKET_DETAIL_PAGE, arguments: ticket.ticketNo);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ),
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
              onPressed: () {
                Get.toNamed(Routes.PROFILE_PAGE);
              },
              child: Icon(
                Icons.person_2_rounded,
                color: AppColorList.WhiteText,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}

Color _getStatusColor(String? status) {
  if (status == null || status.isEmpty) return Colors.grey;
  switch (status.toLowerCase()) {
    case 'new':
      return Colors.blue;
    case 'assigned':
      return Colors.green;
    case 'work_in':
      return AppColorList.Warning;
    case 'cancel':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String getStatusLabel(String? state) {
  switch (state) {
    case 'new':
      return 'New';
    case 'assigned':
      return 'Assigned';
    case 'work_in':
      return 'Work In Progress';
    case 'need_info':
      return 'Need Info';
    case 'reopened':
      return 'Reopened';
    case 'solution':
      return 'Solution';
    case 'closed':
      return 'Closed';
    case 'cancel':
      return 'Cancelled';
    default:
      return 'No Status Available';
  }
}
