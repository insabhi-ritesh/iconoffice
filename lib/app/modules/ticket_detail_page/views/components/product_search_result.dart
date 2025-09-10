import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ticket_detail_page_controller.dart';

Widget buildProductSearchResults(TicketDetailPageController controller) {
  return Obx(() {
    // Hide dropdown when no search results
    if (controller.product_list.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.product_list.length,
      itemBuilder: (context, index) {
        final product = controller.product_list[index];
        return ListTile(
          title: Text(product.name ?? "Unnamed"),
          onTap: () {
            // Set selected product
            controller.productName.text = product.name ?? "";
            controller.productId.value = product.id ?? 0;

            // Clear dropdown and search query
            controller.product_list.clear();
            controller.searchQuery.value = controller.productName.text;

            // Close keyboard
            FocusScope.of(context).unfocus();
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
      ),
    );
  });
}
