import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../../../common/app_color.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'components/priority.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColorList.AppColor,
          // appBar: AppBar(
          //   title: Container(
          //     padding: EdgeInsets.all(16.0),
          //     decoration: BoxDecoration(
          //         color: AppColorList.AppButtonColor,
          //         borderRadius: const BorderRadius.only(
          //           bottomLeft: Radius.circular(20),
          //           bottomRight: Radius.circular(20),
          //         ),
          //       ),
          //     child: Text('Ticket List',
          //       style: TextStyle(
          //         color: AppColorList.WhiteText,
          //       ),
          //     ),
          //   ),
          //   backgroundColor: AppColorList.AppButtonColor,
          //   centerTitle: true,
          //   actions: [
          //     IconButton(
          //       icon:  Icon(Icons.notification_important_sharp,
          //         color: AppColorList.WhiteText,
          //       ),
          //       onPressed: () {
          //         Get.toNamed(Routes.NOTIFY_PAGE);
          //       },
          //     ),
          //   ],
          // ),

          appBar: AppBar(
            backgroundColor: AppColorList.AppButtonColor,
            elevation: 0,
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back, color: Colors.white),
            //   onPressed: () => Get.back(),
            // ),
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
                  color: AppColorList.WhiteText,
                ),
              ),
            ),
            centerTitle: true,
            // Uncomment actions if needed
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
                if (controller.tickets.isEmpty) {
                  return  Center(
                    child: CircularProgressIndicator()
                  );
                }
                
                return ListView.builder(
                  itemCount: controller.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = controller.tickets[index];
                    if (ticket == null) {
                      return const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    }
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
                                fontWeight: AppFontWeight.font3
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              height: 25,
                              width: 63,
                              decoration: BoxDecoration(
                                border: 
                                Border.all(width: 0.5),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                children: [
                                  // Text('Priority:'),
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
                            // Ticket title with fallback
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Ticket Title: ',
                                    style: TextStyle(fontWeight: AppFontWeight.font4),
                                  ),
                                  TextSpan(
                                    text: ticket.ticketTitle?.isNotEmpty == true
                                      ? ticket.ticketTitle
                                      : 'No Title Available',
                                    style: TextStyle(fontWeight: AppFontWeight.font3),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            // Partner name with fallback
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Partner: ',
                                    style: TextStyle(fontWeight: AppFontWeight.font4),
                                  ),
                                  TextSpan(
                                    text: ticket.tpartnerName?.isNotEmpty == true
                                      ? ticket.tpartnerName
                                      : 'No Partner Available',
                                    style: TextStyle(fontWeight: AppFontWeight.font3),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            // Status with fallback
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(ticket.state).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Status: ${ticket.state?.isNotEmpty == true ? ticket.state : "No Status Available"}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: _getStatusColor(ticket.state),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          // children: [
                          //   RichText(
                          //     text: TextSpan(
                          //       style: DefaultTextStyle.of(context).style,
                          //       children: [
                          //         const TextSpan(text: 'Ticket No: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          //         TextSpan(text: '${ticket.ticketNo}'),
                          //       ],
                          //     ),
                          //   ),
                          //   RichText(
                          //     text: TextSpan(
                          //       style: DefaultTextStyle.of(context).style,
                          //       children: [
                          //         const TextSpan(text: 'Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          //         TextSpan(text: '${ticket.priority}'),
                          //       ],
                          //     ),
                          //   ),
                          //   RichText(
                          //     text: TextSpan(
                          //       style: DefaultTextStyle.of(context).style,
                          //       children: [
                          //         const TextSpan(text: 'Partner: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          //         TextSpan(text: '${ticket.tpartnerName}'),
                          //       ],
                          //     ),
                          //   ),
                          //   RichText(
                          //     text: TextSpan(
                          //       style: DefaultTextStyle.of(context).style,
                          //       children: [
                          //         const TextSpan(text: 'Reference: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          //         TextSpan(text: '${ticket.tref}'),
                          //       ],
                          //     ),
                          //   ),
                          //   RichText(
                          //     text: TextSpan(
                          //       style: DefaultTextStyle.of(context).style,
                          //       children: [
                          //         const TextSpan(text: 'Fault Area: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          //         TextSpan(text: '${ticket.faultArea}'),
                          //       ],
                          //     ),
                          //   ),
                          //   Container(
                          //     margin: const EdgeInsets.only(top: 4),
                          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //     decoration: BoxDecoration(
                          //       color: _getStatusColor(ticket.state).withOpacity(0.2),
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: Text(
                          //       'Status: ${ticket.state}',
                          //       style: TextStyle(
                          //         color: _getStatusColor(ticket.state),
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //   ),
                          // ],

                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                           Get.toNamed(Routes.TICKET_DETAIL_PAGE, arguments: ticket.ticketNo);
                        },
                      ),
                    );
                  },
                );
              }
              ) 
            
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
                size: 32, // <-- increase this value for a bigger icon
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
    case 'open':
      return Colors.green;
    case 'in progress':
      return Colors.orange;
    case 'closed':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
