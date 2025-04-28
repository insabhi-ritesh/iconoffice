import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/app_color.dart';
import '../controllers/notify_page_controller.dart';

class NotifyPageView extends GetView<NotifyPageController> {
  const NotifyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: AppColorList.AppButtonColor,
        // centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Change this according to your data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text('Notification Title ${index + 1}'),
              subtitle: Text('This is the description of notification ${index + 1}.'),
              // trailing: Icon(Icons.arrow_forward_ios, size: 16),
              // onTap: () {
              //   // Handle item tap if needed
              // },
            ),
          );
        },
      ),
    );
  }
}
