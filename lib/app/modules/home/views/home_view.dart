
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'components/app_bar.dart';
import 'components/float_action_button.dart';
import 'components/home_body.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          appBar: homeAppBar(),
          body: HomeBody(controller),
          floatingActionButton: FloatActionButton(),
        );
      },
    );
  }
}
