import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import 'package:insabhi_icon_office/app/modules/home/views/components/priority.dart';
import '../controllers/notify_page_controller.dart';

class NotifyPageView extends GetView<NotifyPageController> {
  const NotifyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotifyPageController());

    return Scaffold(
      body: Container(
        color: AppColorList.AppButtonColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColorList.AppButtonColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: AppFontSize.size1,
                        fontWeight: AppFontWeight.font3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.notifications.isEmpty) {
                      return const Center(
                        child: Text(
                          'No notifications available',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = controller.notifications[index];
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
                                    notification.ticketNo.isNotEmpty
                                        ? notification.ticketNo
                                        : 'No Ticket No',
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
                                          priority: int.tryParse(notification.priority) ?? 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                notification.name.isNotEmpty
                                    ? "Ref: ${notification.name}"
                                    : "No reference",
                                style: const TextStyle(
                                  fontWeight: AppFontWeight.font3,
                                ),
                              ),
                              onTap: () {
                                // You can navigate or show details here
                              },
                            ),
                          );
                        },
                      );
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
