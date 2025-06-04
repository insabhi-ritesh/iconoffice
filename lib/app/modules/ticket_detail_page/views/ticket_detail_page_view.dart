import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_color.dart';
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
        return Scaffold(
          appBar: AppBar(
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
        );
      },
    );
  }

  Widget ticketHeader(BuildContext context, TicketDetailPageController controller, var ticket) {
    final currentStateIndex = getSelectedStateIndex(ticket.state1);
    return ticketHeaderBody(context, ticket, controller, currentStateIndex);
  }
}
