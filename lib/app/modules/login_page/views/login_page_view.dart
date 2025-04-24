import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';

import '../../../routes/app_pages.dart';
import '../controllers/login_page_controller.dart';

class LoginPageView extends GetView<LoginPageController> {
  const LoginPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorList.AppColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with elevation
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Material(
                    elevation: 20.0,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset("assets/images/logo.jpeg"),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Welcome to Icon Office Mobile App",
                  style: TextStyle(
                    fontSize: AppFontSize.size3,
                    fontWeight: AppFontWeight.font1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Username field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Username",
                    style: TextStyle(
                      fontWeight: AppFontWeight.font1,
                      fontSize: AppFontSize.size3
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.UserName,
                  decoration: InputDecoration(
                    labelText: 'Enter your username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: AppColorList.AppTextField,
                  ),
                ),

                const SizedBox(height: 10),

                // Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: AppFontWeight.font1,
                      fontSize: AppFontSize.size3
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.Password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: AppColorList.AppTextField,
                  ),
                ),

                const SizedBox(height: 40),

                // Login button
                Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            AppColorList.AppButtonColor,
                          ),
                        ),
                        onPressed: () {
                          if (controller.UserName.text.isNotEmpty && controller.Password.text.isNotEmpty) {
                            controller.login(controller.UserName.text.trim(), controller.Password.text.trim().toString());
                          } else {
                            Get.snackbar("Error", "Please enter both username and password.");
                          }
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: AppFontSize.size1,
                            fontWeight: AppFontWeight.font1,
                            color: AppColorList.AppTextColor,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}