import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/signature_and_pdf/bindings/signature_and_pdf_binding.dart';
import 'package:insabhi_icon_office/app/modules/signature_and_pdf/views/signature_and_pdf_view.dart';

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

        // ────────────────────────────────
        // NEW: Signature section – added here (right after Messages)
        // ────────────────────────────────
        sectionBox(
          'Signature',
          GestureDetector(
            onTap: () {
              Get.to(
                () => SignatureAndPdfView(),
                binding: SignatureAndPdfBinding(),
                arguments: ticket,   // pass the ticket object to the new page
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Signature Document',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.blueAccent),
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }