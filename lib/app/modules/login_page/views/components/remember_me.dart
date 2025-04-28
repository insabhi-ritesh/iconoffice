
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import '../../controllers/login_page_controller.dart';

class RememberMeCheckbox extends StatelessWidget {
  final LoginPageController controller;

  const RememberMeCheckbox({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              controller.rememberMe.value = !controller.rememberMe.value;
            },
            child: Obx(() => Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: controller.rememberMe.value ? AppColorList.AppButtonColor : AppColorList.WhiteText,
                    // Colors.green : Colors.white,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: controller.rememberMe.value
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                )),
          ),
          const SizedBox(width: 10),
          const Text('Remember me', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
