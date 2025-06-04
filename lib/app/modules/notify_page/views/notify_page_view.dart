import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import '../controllers/notify_page_controller.dart';
import 'components/app_bar.dart';
import 'components/notification_body.dart';

class NotifyPageView extends GetView<NotifyPageController> {
  const NotifyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotifyPageController());

    return Scaffold(
      body: Container(
        color: AppColorList.AppButtonColor,
        child: SafeArea(
          child: Column(
            children: [
              appBar(),
              notificationBody(controller),
            ],
          ),
        ),
      ),
    );
  }  
}
