import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ticket_list_page_controller.dart';

class TicketListPageView extends GetView<TicketListPageController> {
  const TicketListPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TicketListPageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TicketListPageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
