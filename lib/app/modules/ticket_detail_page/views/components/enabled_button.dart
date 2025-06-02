
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/ticket_detail_page/controllers/ticket_detail_page_controller.dart';
import '../../../../common/app_color.dart';

class IsEnabledButton extends StatelessWidget {
  final TicketDetailPageController controller;
  const IsEnabledButton(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              controller.isEnabled.value = !controller.isEnabled.value;
            },
            child: Obx(() => 
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: controller.isEnabled.value ? AppColorList.AppButtonColor : AppColorList.WhiteText,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: controller.isEnabled.value
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Billable', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
