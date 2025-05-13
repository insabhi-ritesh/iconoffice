import 'package:get/get.dart';

import '../controllers/portal_ticket_form_controller.dart';

class PortalTicketFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PortalTicketFormController>(
      () => PortalTicketFormController(),
    );
  }
}
