import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/fontSize.dart';
import '../../../home/views/components/priority.dart';
import '../../controllers/notify_page_controller.dart';
import 'notify_loader.dart';

Expanded notificationBody(NotifyPageController controller) {
  return Expanded(
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
          return NotifySkeletonLoader();
        } else if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              'No notifications available',
              style: TextStyle(fontSize: AppFontSize.size1, 
              fontWeight: AppFontWeight.font3),
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
  );
}