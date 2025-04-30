import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../controllers/login_page_controller.dart';
import 'components/login_form.dart';
import 'components/remember_me.dart';

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