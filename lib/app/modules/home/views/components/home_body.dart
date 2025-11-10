import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:insabhi_icon_office/app/modules/home/views/components/priority.dart';
import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../../../routes/app_pages.dart';
import 'color_label.dart';
import 'ticket_list_skeleton.dart';

Widget HomeBody(HomeController controller) {
  // Controller for the search input
  final TextEditingController searchController = TextEditingController();

  return RefreshIndicator(
    onRefresh: () async {
      await controller.refreshData();
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar at the top
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by ticket no. or customer name', 
                hintStyle: TextStyle(fontSize: 13, color: const Color.fromARGB(255, 43, 42, 42).withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_alt),
                  onSelected: (String value) {
                    controller.filterTicketsByStatus(value);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'All',
                      child: Text('All'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'New',
                      child: Text('New'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Work in Progress',
                      child: Text('Work in Progress'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Assigned',
                      child: Text('Assigned'),
                    ),
                  ],
                ),
                filled: true,
                fillColor: AppColorList.AppButtonColor.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Trigger search in the controller
                controller.searchTickets(value);
              },
            ),
          ),
          // Expanded to ensure ListView takes remaining space
          Expanded(
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
                    return const SingleChildScrollView(
                      child: Center(
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
                            padding: const EdgeInsets.all(3),
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
                                ),
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
                                  text: ticket.ticketTitle.isNotEmpty
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
                                  text: ticket.tpartnerName.isNotEmpty
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
                              color: getStatusColor(ticket.state).withOpacity(0.2),
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
        ],
      ),
    ),
  );
}