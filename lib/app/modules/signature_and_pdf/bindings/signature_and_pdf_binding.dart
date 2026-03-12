import 'package:get/get.dart';

import '../controllers/signature_and_pdf_controller.dart';

class SignatureAndPdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignatureAndPdfController>(
      () => SignatureAndPdfController(),
    );
  }
}