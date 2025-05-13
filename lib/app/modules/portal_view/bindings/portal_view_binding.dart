import 'package:get/get.dart';

import '../controllers/portal_view_controller.dart';

class PortalViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PortalViewController>(
      () => PortalViewController(),
    );
  }
}
