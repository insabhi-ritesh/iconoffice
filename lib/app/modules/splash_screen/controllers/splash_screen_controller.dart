import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/modules/login_page/controllers/login_page_controller.dart';
import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {

  final box = GetStorage();
  var isLogged = false.obs;

  @override
  void onInit() {
    super.onInit();
     Future.delayed(const Duration(seconds: 3), () {
      // Ensures navigation is called after build is done
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToNextScreen();
      });
    });
  }

  void navigateToNextScreen (){
    isLogged.value = box.read('isLogged') ?? false;

    if (isLogged.value) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN_PAGE);
    }
  }
}
