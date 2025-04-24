
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {

  final box = GetStorage();
  var isLogged = false.obs;

  @override
  void onInit() {
    super.onInit();
    // navigateToNextScreen();
  }

  void navigateToNextScreen (){
    isLogged.value = box.read('isLogged') ?? false;

    if (isLogged.value) {
      Get.toNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.LOGIN_PAGE);
    }
  }
}
