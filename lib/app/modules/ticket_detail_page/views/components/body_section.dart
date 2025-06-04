import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/ticket_detail_page_controller.dart';
import 'section_box.dart';

Widget ticketSections(ticket, controller, BuildContext context) {
    final cont = Get.find<TicketDetailPageController>();
    return Column(
      children: [
        if(!cont.is_portal_user.value) ...[
          sectionBox(
            'Spare Parts', 
            buildListOrEmpty(
              ticket.spareParts1
            ),
          ),
          sectionBox(
            'Timesheet', 
            buildTimesheet(
              ticket.timesheets1, 
              controller, 
              context, 
              ticket.ticketNo1
            ),
          ),
          sectionBox(
            'Document attachments', 
            buildAttachments(
              ticket.pdfDocuments, 
              controller, 
              context, 
              ticket
            )
          ),
        ],
        sectionBox(
          'Messages', 
          buildMessageSection(
            ticket, 
            controller, 
            context
            )
          ),
      ],
    );
  }
