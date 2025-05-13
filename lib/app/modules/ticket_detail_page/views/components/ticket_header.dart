import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/home/views/components/priority.dart';

import '../../../../common/app_color.dart';
import '../../../../common/fontSize.dart';
import '../../controllers/ticket_detail_page_controller.dart';


const List<String> stateKeys = ['assigned', 'work_in', 'closed'];
const List<String> stateLabels = ['Assigned', 'Work in Progress', 'Closed'];

  int getSelectedStateIndex(String? state) {
    if (state == null) return 0;
    final idx = stateKeys.indexOf(state.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  Color getStateButtonColor(String stateKey, bool isSelected) {
    // if (!isSelected) return Colors.grey.shade300;
    switch (stateKey) {
      case 'assigned':
        return Colors.green;
      case 'work_in':
        return Colors.yellow.shade700;
      case 'closed':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

Container ticketHeaderBody(BuildContext context, ticket, TicketDetailPageController controller, int currentStateIndex) {
    
    final cont_portal = Get.find<TicketDetailPageController>();
    
    return Container(
    width: MediaQuery.of(context).size.width * 0.9,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColorList.ContainerBackground,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColorList.ContainerShadow,
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.ticketNo1 ?? '---', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            PriorityStars(priority: int.tryParse(ticket.priority1 ?? '0') ?? 0),
          ],
        ),
        const SizedBox(height: 8),
        if ((ticket.ticketTitle1 ?? '').isNotEmpty)
          Text(ticket.ticketTitle1!, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        if (!cont_portal.is_portal_user.value
          && (ticket.state1 == "assigned" 
          || ticket.state1 == "work_in"
            )
          )
          Obx(() {
            return Row(
              children: List.generate(stateKeys.length, (index) {
                final stateKey = stateKeys[index];
                final isSelected = controller.selectedState.value == stateKey;
                final isFuture = index > currentStateIndex;
                final isPast = index < currentStateIndex;
                final isEnabled = isFuture && !isSelected;

                Widget button = ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? getStateButtonColor(stateKey, true)
                        : isPast
                            ? Colors.grey.shade400
                            : getStateButtonColor(stateKey, false),
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: isSelected ? 16 : 2,
                    shadowColor: isSelected ? Colors.green : Colors.black26,
                  ),
                  onPressed: isEnabled
                      ? () async => await controller.updateTicketState(ticket.ticketNo1, stateKey)
                      : null,
                  child: Center(
                    child: Text(
                      stateLabels[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppFontSize.size5,
                        fontWeight: AppFontWeight.font3,
                      ),
                    ),
                  ),
                );

                Widget buttonWrapper = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: isSelected
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: button,
                        )
                      : button,
                );

                return Expanded(child: buttonWrapper);
              }),
            );
          }
        )
      ],
    ),
  );
  }