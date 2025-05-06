import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_page_controller.dart';
import 'components/login_form.dart';

class LoginPageView extends GetView<LoginPageController> {
  const LoginPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColorList.AppBackGroundColor,
      body: SafeArea(
        child: loginForm(controller),
      ),
    );
  }
}