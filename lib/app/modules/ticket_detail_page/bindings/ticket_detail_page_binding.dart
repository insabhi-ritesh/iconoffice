import 'package:get/get.dart';

import '../controllers/ticket_detail_page_controller.dart';

class TicketDetailPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketDetailPageController>(
      () => TicketDetailPageController(),
    );
  }
}
