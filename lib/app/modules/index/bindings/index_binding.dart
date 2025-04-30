import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:insabhi_icon_office/app/modules/profile_page/controllers/profile_page_controller.dart';

import '../controllers/index_controller.dart';

class IndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndexController>(
      () => IndexController(),
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ProfilePageController>(() => ProfilePageController(), fenix: true);
  }
}
