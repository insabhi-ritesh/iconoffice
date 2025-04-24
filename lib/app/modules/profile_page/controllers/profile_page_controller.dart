import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../Constants/constant.dart';
import '../../../models/get_user_data.dart';
import '../../../routes/app_pages.dart';

class ProfilePageController extends GetxController {
  //TODO: Implement ProfilePageController

  final box = GetStorage();
  var user = <ResUser>[].obs;


  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    GetUserProfileData();
  }

  Future<void> GetUserProfileData  () async {
    var partnerId =box.read('partnerId');

    try {
      var response = await http.get(
        Uri.parse('${Constant.BASE_URL}${ApiEndPoints.USER_PROFILE_API}?partner_id=$partnerId'),
        // body: {
        //   'partner_id': partnerId.toString()
        // },
      );

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

  void reDirectUpdatePassword(){
    Get.toNamed(Routes.UPDATE_PASSWORD);
  }
}
