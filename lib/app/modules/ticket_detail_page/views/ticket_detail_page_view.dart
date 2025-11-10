import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
            resizeToAvoidBottomInset: true,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      reverse: true,
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
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
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
    final TextEditingController searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ticketHeaderBody(context, ticket, controller, currentStateIndex),
        const SizedBox(height: 16),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<int>(
                      isExpanded: true,
                      value: controller.selectedUserId.value,
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        offset: const Offset(0, 8),
                        maxHeight: 300, // Fixed dropdown height
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: searchController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              controller.userQuery.value = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Search user...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          final name = (item.value != null)
                              ? controller.assignedUsers
                                  .firstWhereOrNull((u) => u.id == item.value)
                                  ?.name
                                  ?.toLowerCase()
                              : '';
                          return name?.contains(searchValue.toLowerCase()) ?? false;
                        },
                      ),
                      hint: const Text('Search user'),
                      items: controller.assignedUsers.map((user) {
                        return DropdownMenuItem<int>(
                          value: user.id,
                          child: Text(user.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedUserId.value = value;
                        searchController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: controller.selectedUserId.value != null
                        ? () => controller.updateAssignedUser(ticket.ticketNo1, controller.selectedUserId.value!)
                        : null,
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
