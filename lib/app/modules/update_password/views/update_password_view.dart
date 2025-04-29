import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../controllers/update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColorList.AppButtonColor,
        child: SafeArea(
          child: Column(
            children: [
              // Top container matching ProfilePageView
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
                      'Update Password',
                      style: TextStyle(
                        fontSize: AppFontSize.size1,
                        fontWeight: AppFontWeight.font3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Content area matching ProfilePageView
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
                        // Old Password Field
                        Text(
                          'Old Password',
                          style: TextStyle(
                            fontSize: AppFontSize.size3,
                            fontWeight: AppFontWeight.font2,
                            color: Colors.black87, // Darker text to match ProfileField value
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: controller.oldPasswordController,
                          label: 'Old Password',
                        ),
                        const SizedBox(height: 20),
                        // New Password Field
                        Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: AppFontSize.size3,
                            fontWeight: AppFontWeight.font2,
                            color: Colors.black87, // Darker text to match ProfileField value
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: controller.newPasswordController,
                          label: 'New Password',
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password Field
                        Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: AppFontSize.size3,
                            fontWeight: AppFontWeight.font2,
                            color: Colors.black87, // Darker text to match ProfileField value
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: controller.confirmPasswordController,
                          label: 'Confirm Password',
                        ),
                        const SizedBox(height: 200), // Increased gap above Submit button
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.changePassword();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColorList.AppButtonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              shadowColor: AppColorList.AppButtonColor.withOpacity(0.3),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: AppFontSize.size4,
                                fontWeight: AppFontWeight.font3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

  // Helper method to build text fields with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
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
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: AppFontSize.size4,
            fontWeight: AppFontWeight.font3,
            color: Colors.grey[600],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}