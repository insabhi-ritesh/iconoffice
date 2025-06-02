import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ticket_detail_page_controller.dart';

Widget buildProductSearchResults(TicketDetailPageController controller) {
    return Obx(() {
      if (controller.searchQuery.value.isEmpty || controller.product_list.isEmpty) {
        return const SizedBox(); // Return empty widget when no search input or no results
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.product_list.length,
        itemBuilder: (context, index) {
          final product = controller.product_list[index];
          return ListTile(
            title: Text(''),
            subtitle: Text(product.name),
            onTap: () {
              // Handle selection
              controller.productName.text = product.name;
              controller.productId.value = product.id;
              controller.product_list.clear();
              controller.searchQuery.value = '';
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
