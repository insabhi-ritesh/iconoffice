import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/modules/signature_and_pdf/bindings/signature_and_pdf_binding.dart';
import 'package:insabhi_icon_office/app/modules/signature_and_pdf/controllers/signature_and_pdf_controller.dart';
import 'package:insabhi_icon_office/app/modules/signature_and_pdf/views/signature_and_pdf_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../controllers/ticket_detail_page_controller.dart';
import 'section_box.dart';

Widget ticketSections(ticket, controller, BuildContext context) {
  final cont = Get.find<TicketDetailPageController>();

  return Column(
    children: [
      if (!cont.is_portal_user.value) ...[
        sectionBox('Spare Parts', buildListOrEmpty(ticket.spareParts1)),
        sectionBox(
          'Timesheet',
          buildTimesheet(
            ticket.timesheets1,
            controller,
            context,
            ticket.ticketNo1,
          ),
        ),
        sectionBox(
          'Document attachments',
          buildAttachments(ticket.pdfDocuments, controller, context, ticket),
        ),
      ],
      sectionBox('Messages', buildMessageSection(ticket, controller, context)),

      // ── Signature Section ──────────────────────────────────────────
      sectionBox('Signature', _SignatureSectionContent(ticket: ticket)),
    ],
  );
}

class _SignatureSectionContent extends StatelessWidget {
  final dynamic ticket;
  const _SignatureSectionContent({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final ticketNo = ticket?.ticketNo1?.toString() ?? 'unknown';
    final signedKey = 'signed_pdf_path_$ticketNo';

    final signedPath = RxString('');

    // Load from storage on first build
    final storedPath = storage.read<String>(signedKey);
    if (storedPath != null && File(storedPath).existsSync()) {
      signedPath.value = storedPath;
    } else {
      // Reinstall fallback: scan folder silently, no UI indication
      final saveDir = Directory('/storage/emulated/0/Download/SignedDocuments');
      if (saveDir.existsSync()) {
        final files =
            saveDir
                .listSync()
                .whereType<File>()
                .where((f) => f.path.contains('signed_${ticketNo}_'))
                .toList();
        if (files.isNotEmpty) {
          files.sort((a, b) => b.path.compareTo(a.path));
          final recovered = files.first.path;
          storage.write(signedKey, recovered);
          signedPath.value = recovered;
        }
      }
    }

    return Column(
      children: [
        // ── "Add Signature Document" row ──
        GestureDetector(
          onTap: () async {
            await Get.to(
              () => SignatureAndPdfView(),
              binding: SignatureAndPdfBinding(),
              arguments: ticket,
            );

            // Resumes after Navigator.pop — re-read storage to update card
            final updated = storage.read<String>(signedKey);
            if (updated != null && File(updated).existsSync()) {
              signedPath.value = updated;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

        // ── Signed PDF card (shows after sign & save) ──
        Obx(() {
          if (signedPath.value.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const Divider(height: 1),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    // Tappable area for preview
                    Expanded(
                      child: InkWell(
                        onTap:
                            () => Get.to(
                              () => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Signed Document'),
                                ),
                                body: SfPdfViewer.file(File(signedPath.value)),
                              ),
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              signedPath.value
                                  .split(Platform.pathSeparator)
                                  .last,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Tap to preview signed document',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Delete icon ──
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await storage.remove(signedKey);
                        signedPath.value = '';

                        try {
                          final sigController =
                              Get.find<SignatureAndPdfController>();
                          await sigController.clearSavedPdf(ticketNo);
                        } catch (_) {
                          final pdfKey = 'saved_pdf_path_$ticketNo';
                          await storage.remove(pdfKey);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
