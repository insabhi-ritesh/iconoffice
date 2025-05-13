import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../Constants/constant.dart';
import '../../../Constants/firebase_api.dart';
import '../../../models/get_user_data.dart';
import '../../../routes/app_pages.dart';

class ProfilePageController extends GetxController {
  //TODO: Implement ProfilePageController

  final box = GetStorage();
  var user = <ResUser>[].obs;
  var is_portal_user = true.obs;


  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    
    // is_portal_user.value = box.read('is_portal_user');
    GetUserProfileData();
  }

  Future<void> GetUserProfileData  () async {
    var partnerId =box.read('partnerId');
    is_portal_user.value = box.read('is_portal_user') ?? false;
    print(is_portal_user);

    try {
      var response = await http.get(
        Uri.parse('${Constant.BASE_URL}${ApiEndPoints.USER_PROFILE_API}?partner_id=$partnerId'),
      ).timeout(Duration(seconds: 10));


      log(response.body);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        // log(res);
        if (res['data'] != null) {
          for (var element in res['data']) {
            var data = ResUser.fromJson(element);
            user.add(data);
          }
        // log(res['data']);
        } else {
          Get.snackbar("Error", "Failed to fetch orders");
        }
      }
    } catch  (e) {
      log("error message: $e");
      print("Error fetching user profile data.");
    }
  }

  Future<void> logout() async {
    await GetStorage().erase();
    Get.offAllNamed(Routes.LOGIN_PAGE);
    await FirebaseApi().startNotification();
  }

  void reDirectUpdatePassword(){
    Get.toNamed(Routes.UPDATE_PASSWORD);
  }
}
