import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Expanded viewMessage(controller) {
    return Expanded(
            child: controller.message.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
                    controller: controller.messageScrollController,
                    itemCount: controller.message.length,
                    itemBuilder: (context, index) {
                      final msg = controller.message[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.author,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(controller.parseHtmlString(msg.body)),
                              const SizedBox(height: 6),
                              Text(
                                msg.date,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              if (msg.attchements != null && msg.attchements.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Attachments:",
                                        style: TextStyle(fontWeight: FontWeight.w600)),
                                    ...msg.attchements.map<Widget>((att) {
                                      return InkWell(
                                        onTap: () async {
                                          final url = Uri.parse(att.url);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode.externalApplication);
                                          } else {
                                            Get.snackbar('Error', 'Could not open file');
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.attach_file, size: 18),
                                              Flexible(
                                                child: Text(
                                                  att.name,
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
  }