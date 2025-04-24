import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_color.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColorList.AppColor,
          appBar: AppBar(
            title: const Text('Ticket List'),
            backgroundColor: AppColorList.AppButtonColor,
            // centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person,
                  color: AppColorList.AppTextColor,
                ),
                onPressed: () {
                  Get.toNamed(Routes.PROFILE_PAGE);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: controller.tickets.length,
              itemBuilder: (context, index) {
                final ticket = controller.tickets[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(ticket['title']),
                    subtitle: Text('Status: ${ticket['status']}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.toNamed(Routes.TICKET_DETAIL_PAGE);
                    },
                  ),
                );
              },
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Get.toNamed(Routes.PROFILE_PAGE);
          //   },
          //   child: Icon(Icons.person),
          // ),
        );
      },
    );
  }
}
