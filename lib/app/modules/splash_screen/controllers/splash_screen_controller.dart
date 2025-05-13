import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {

  final box = GetStorage();
  var isLogged = false.obs;
  var portal_user = false.obs;

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

    
  void navigateToNextScreen() {
    final bool isLoggedIn = box.read('isLogged') ?? false;
    final bool isPortalUser = box.read('is_portal_user') ?? false;

    isLogged.value = isLoggedIn;
    portal_user.value = isPortalUser;

    if (isLoggedIn && isPortalUser) {
      Get.offAllNamed(Routes.PORTAL_VIEW);
      return;
    }
    if (isLoggedIn && !isPortalUser) {
      Get.offAllNamed(Routes.HOME);
      return;
    }
    Get.offAllNamed(Routes.LOGIN_PAGE);
  }
}
