import 'dart:convert';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';

import '../../../routes/app_pages.dart';

class LoginPageController extends GetxController with GetSingleTickerProviderStateMixin {
  //TODO: Implement LoginPageController
  var UserName = TextEditingController();
  var Password = TextEditingController();
  var isLoading = false.obs;
  final box = GetStorage();
  var isLogged = false.obs;
  late AnimationController animationController;
  late Animation<double> animation;
  var rememberMe = false.obs;
  var Switch_page = false.obs;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0,end: 30).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    
  }

  Future<void> login(String UserName, String Password, bool remember ) async {
    isLoading.value = true;
    if(UserName.isEmpty || Password.isEmpty) {
      Get.snackbar('Error', 'Username and password cannot be empty.');
      return;
    }

    try {

    var response = await http.post(
        Uri.parse('${Constant.BASE_URL}${ApiEndPoints.LOGIN_API}'),
        body: {
          'login': UserName,
          'password': Password,
        },
      );

      log(response.body);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res["success"] == true) {
          await sendToken();
          isLoading.value = false;
          var name = res["data"]["name"];
          var login = res["data"]["login"];
          var password = res["data"]["password"];
          var email = res["data"]["email"];
          var phone = res["data"]["phone"];
          var partnerId = res["data"]["partner_id"];
          var userId = res["data"]["user_id"];
          bool portal_user = res["data"]["is_portal"];
          box.write('name', name);
          box.write('login', login);
          box.write('password', password);
          box.write('email', email);
          box.write('phone', phone);
          box.write('user_ID', userId);
          box.write('is_portal_user', portal_user);
          if (remember == true){
            var isLogging = true;
            box.write('isLogged', isLogging);
          }
          
          box.write('partnerId', partnerId);
          // int id = box.read('partnerId');
          var print = box.read('isLogged');
          log("Permit list: $print");
          Get.snackbar('Success', 'Login successful!');
          log('Login Successfully with status code: ${response.statusCode}');

          bool Switch_page = box.read('is_portal_user') ?? false;

          if (Switch_page == true) {
            Get.offAllNamed(Routes.PORTAL_VIEW);
          }else {
            Get.offAllNamed(Routes.HOME);
          }
        } else {
          isLoading.value = false;
          Get.snackbar("Error", "Wrong login and password");
          log("Login failed with response: ${response.body}");
        }
      } else {
        isLoading.value = false;
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
        Get.snackbar("Error", "Wrong login and password");
      }
    } catch (e){
      isLoading.value = false;
      log("Login Error $e");
      Get.snackbar('Error', 'Login failed. Please try again.');
    }
  }

  Future<void> sendToken() async {
    final token = box.read('Token');
    final partnerId = box.read('partnerId');

    if (token == null || partnerId == null) {
      log('Token or partner_id is null, skipping sendToken.');
      return;
    }

    final url = '${Constant.BASE_URL}${ApiEndPoints.SAVE_TOKEN}?partner_id=$partnerId&token=$token';
    log(url);

    try {
      final response = await http.post(Uri.parse(url));
      log(response.body);

      if(response.statusCode == 200) {
        log('This is the response code: $response');
      }
    } catch (e) {
      log('sendToken error: $e');
    }
  }

  Future<void> logout () async {
    await GetStorage().erase();

    Get.offAllNamed(Routes.LOGIN_PAGE);
  }

}
