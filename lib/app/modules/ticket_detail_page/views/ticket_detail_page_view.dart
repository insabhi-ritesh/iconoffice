import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ticket_detail_page_controller.dart';

class TicketDetailPageView extends GetView<TicketDetailPageController> {
  const TicketDetailPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TicketDetailPageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TicketDetailPageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
