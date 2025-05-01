import 'package:get/get.dart';

import '../controllers/pdf_sign_controller.dart';

class PdfSignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfSignController>(
      () => PdfSignController(),
    );
  }
}
