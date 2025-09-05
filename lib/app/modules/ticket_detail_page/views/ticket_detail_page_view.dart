import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import '../../../common/app_color.dart';
import '../../../routes/app_pages.dart';
import '../controllers/ticket_detail_page_controller.dart';
import 'components/body_section.dart';
import 'components/float_action_button.dart';
import 'components/ticket_header.dart';
import 'components/ticket_info_box.dart';
import 'ticket_details_loader/ticket_details_loader.dart';

class TicketDetailPageView extends StatelessWidget {
  TicketDetailPageView({super.key});

  static const List<String> stateKeys = ['assigned', 'work_in', 'closed'];
  static const List<String> stateLabels = ['Assigned', 'Work in Progress', 'Closed'];

  final RxList<PlatformFile> fabSelectedFiles = <PlatformFile>[].obs;

  int getSelectedStateIndex(String? state) {
    if (state == null) return 0;
    final idx = stateKeys.indexOf(state.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  Color getStateButtonColor(String stateKey, bool isSelected) {
    switch (stateKey) {
      case 'assigned':
        return AppColorList.Star1;
      case 'work_in':
        return AppColorList.yellow_shade;
      case 'closed':
        return AppColorList.Star3;
      default:
        return AppColorList.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketDetailPageController>(
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            try {
              Get.find<HomeController>().fetchTickets(isRefresh: true);
              Get.offAllNamed(Routes.HOME);
              return false;
            } catch (e) {
              log('Error refreshing ticket list on back: $e');
              return true;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  try {
                    Get.find<HomeController>().fetchTickets(isRefresh: true);
                  } catch (e) {
                    log('Error refreshing ticket list on back: $e');
                  }
                  Get.offAllNamed(Routes.HOME);
                },
              ),
              title: Text('Service Ticket Detail', style: TextStyle(color: AppColorList.WhiteText)),
              backgroundColor: AppColorList.AppButtonColor,
              iconTheme: IconThemeData(color: AppColorList.WhiteText),
            ),
            body: Obx(() {
              if (controller.ticket_details.isEmpty) return TicketDetailSkeleton();
              final ticket = controller.ticket_details[0];

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshData(ticket.ticketNo1);
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ticketHeader(context, controller, ticket),
                      const SizedBox(height: 16),
                      ticketInfoBox(ticket, context),
                      const SizedBox(height: 24),
                      const Divider(),
                      ticketSections(ticket, controller, context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }),
            floatingActionButton: tickerFloatActionButton(controller.ticketNumber),
          ),
        );
      },
    );
  }

  Widget ticketHeader(BuildContext context, TicketDetailPageController controller, var ticket) {
    final currentStateIndex = getSelectedStateIndex(ticket.state1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ticketHeaderBody(context, ticket, controller, currentStateIndex),
        const SizedBox(height: 16),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Assigned to',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: controller.selectedUserId.value,
                  items: controller.assignedUsers.map((user) {
                    return DropdownMenuItem<int>(
                      value: user.id,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedUserId.value = value; // Only update selectedUserId
                  },
                  isExpanded: true,
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: controller.selectedUserId.value != null
                        ? () => controller.updateAssignedUser(ticket.ticketNo1, controller.selectedUserId.value!)
                        : null, // Disable button if no user is selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorList.AppButtonColor,
                      foregroundColor: AppColorList.WhiteText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Assign'),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}