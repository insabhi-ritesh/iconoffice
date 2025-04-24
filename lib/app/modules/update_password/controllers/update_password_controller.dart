import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:insabhi_icon_office/app/modules/login_page/controllers/login_page_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UpdatePasswordController extends GetxController {
  //TODO: Implement UpdatePasswordController

  final box = GetStorage();

  final HomeController homeController = 
  Get.find<HomeController>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    log(oldPassword);
    log(newPassword);
    log(confirmPassword);

    try {
      final username = box.read('email');
      log(username);
      box.remove('password');
      // var response = await http.post(
      //   Uri.parse('${Constant.BASE_URL}${ApiEndPoints.LOGIN_API}'),
      //   body: {
      //     'login': username,
      //     'password': oldPassword,
      //   },
      // );
      // print(response.statusCode);

      // if (response.statusCode == 200) {
      if (newPassword != confirmPassword) {
        Get.snackbar('Try Failed', 'Passwords do not match');
        return;
      }

      try {
        final login = box.read('login');
        final partnerId = box.read('partner_id');
        log(login);
        print("0001");
        final response = await http.post(
          Uri.parse(
              '${Constant.BASE_URL}${ApiEndPoints.UPDATE_PASSWORD}?partner_id=$partnerId'),
          body: {
            'login': login,
            'new_password': newPassword,
          },
        );
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          if (responseBody['success']) {
            Get.snackbar('Success', 'Password changed successfully');
            showPopUp();
            homeController.logout();
          } else {
            Get.snackbar("Error", 'Failed to change password');
          }
        } else {
          Get.snackbar("Error", 'Invalid old password');
        }
      } catch (e) {
        log(e.toString());
        Get.back();
      }
      // }
    } catch (e) {
      log(e.toString());
    }
  }

  void showPopUp() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image at the top
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/images/reset_image.svg', // Make sure this image exists in your assets folder
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            // Title and message
            const Text(
              'Reset Password \nSuccessful',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.w500, 
                color: AppColorList.AppColor,
                
                ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please wait...\nYou will be directed to the homepage',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w300),
            ),

            const SizedBox(height: 20),

            // Loader at the bottom
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColorList.AppColor, size: 80
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

}
