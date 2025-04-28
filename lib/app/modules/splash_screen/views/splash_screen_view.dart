import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
      builder: (controller) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Image.asset(
              'assets/images/logo.jpeg',
              height: 180,
              width: 190,
              alignment: Alignment.center,
            ),
          ),

          // ElevatedButton(onPressed: () {
          //   controller.navigateToNextScreen();
          // }, child: Text("Get Started")),
          Center(
            child: LinearProgressIndicator(
              color: AppColorList.AppColor,
            ),
          )
        ],
      ),
    );
      }
    
    );
  }
}
