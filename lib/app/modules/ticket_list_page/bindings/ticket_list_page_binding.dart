import 'package:get/get.dart';

import '../controllers/ticket_list_page_controller.dart';

class TicketListPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketListPageController>(
      () => TicketListPageController(),
    );
  }
}
