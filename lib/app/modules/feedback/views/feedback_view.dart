import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';

import '../controllers/feedback_controller.dart';

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColorList.AppButtonColor,
        child: SafeArea(
          child: Column(
            children: [
              // ─────── Top bar ───────
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColorList.AppButtonColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: AppFontSize.size1,
                        fontWeight: AppFontWeight.font3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ─────── Main content ───────
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ───── Name ─────
                        Text('Name',
                            style: TextStyle(
                                fontSize: AppFontSize.size3,
                                fontWeight: AppFontWeight.font2,
                                color: Colors.black87)),
                        const SizedBox(height: 10),
                        _buildTextField(
                            controller: controller.nameController,
                            hint: 'Enter your name'),

                        const SizedBox(height: 20),

                        // ───── Email ─────
                        Text('Email',
                            style: TextStyle(
                                fontSize: AppFontSize.size3,
                                fontWeight: AppFontWeight.font2,
                                color: Colors.black87)),
                        const SizedBox(height: 10),
                        _buildTextField(
                            controller: controller.emailController,
                            hint: 'Enter your email'),

                        const SizedBox(height: 20),

                        // ───── Attachment ─────
                        Text('Attachment',
                            style: TextStyle(
                                fontSize: AppFontSize.size3,
                                fontWeight: AppFontWeight.font2,
                                color: Colors.black87)),
                        const SizedBox(height: 10),
                        _buildAttachmentCard(),

                        const SizedBox(height: 20),

                        // ───── Description ─────
                        Text('Description',
                            style: TextStyle(
                                fontSize: AppFontSize.size3,
                                fontWeight: AppFontWeight.font2,
                                color: Colors.black87)),
                        const SizedBox(height: 10),
                        _buildDescriptionField(
                            controller: controller.descriptionController),

                        const SizedBox(height: 40),

                        // ───── Submit button ─────
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.submitFeedback,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColorList.AppButtonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25)),
                                  elevation: 5,
                                  shadowColor: AppColorList.AppButtonColor
                                      .withOpacity(0.3),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Submit',
                                        style: TextStyle(
                                            fontSize: AppFontSize.size4,
                                            fontWeight: AppFontWeight.font3)),
                              ),
                            )),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───── Re-usable text field (now receives a controller) ─────
  Widget _buildTextField(
      {required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColorList.AppButtonColor.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColorList.AppButtonColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: AppFontSize.size4,
            color: Colors.grey[600],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // ───── Attachment card (calls controller.selectFile) ─────
  Widget _buildAttachmentCard() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColorList.AppButtonColor.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColorList.AppButtonColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ListTile(
            leading:
                Icon(Icons.attach_file, color: AppColorList.AppButtonColor),
            title: const Text('Choose File',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(controller.selectedFileName.value),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.selectFile,
          ),
        ));
  }

  // ───── Description field (recevies controller) ─────
  Widget _buildDescriptionField(
      {required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColorList.AppButtonColor.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColorList.AppButtonColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 6,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: 'Write your feedback / issue description here...',
          hintStyle: TextStyle(
            fontSize: AppFontSize.size4,
            color: Colors.grey[600],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}