import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controllers/ticket_detail_page_controller.dart';

Widget buildUserSearchResults(TicketDetailPageController controller) {
    return Obx(() {
      if (controller.userQuery.value.isEmpty || controller.user_list.isEmpty) {
        return const SizedBox(); // Return empty widget when no search input or no results
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.user_list.length,
        itemBuilder: (context, index) {
          final user = controller.user_list[index];
          return ListTile(
            title: Text(''),
            subtitle: Text(user.name),
            onTap: () {
              // Handle selection
              controller.resUser.text = user.name;
              controller.user_list.clear();
              controller.userQuery.value = '';
              FocusScope.of(context).unfocus(); // Close keyboard
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
        )
      );
    });
  }