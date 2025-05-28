import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/modules/profile_page/controllers/profile_page_controller.dart';

import '../../../../common/fontSize.dart';
import '../../../../models/get_user_data.dart';
import '../../../../routes/app_pages.dart';
import '../profile_page_view.dart';

SafeArea profileBody(Uint8List? imageBytes, ResUser resUser, ProfilePageController logController, controller) {
    return SafeArea(
        child: Column(
          children: [
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
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    ProfileAvatar(imageBytes: imageBytes),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Profile Picture',
                        style: TextStyle(
                          fontSize: AppFontSize.size3,
                          fontWeight: AppFontWeight.font2,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileField(
                      icon: Icons.person_outline,
                      label: "Username",
                      value: resUser.name,
                    ),
                    ProfileField(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: resUser.email,
                    ),
                    ProfileField(
                      icon: Icons.email_outlined,
                      label: "Phone",
                      value: resUser.phone.isEmpty ? "No phone number added" : resUser.phone,
                    ),

                    if (!controller.is_portal_user.value)...[
                      ProfileField(
                        icon: Icons.lock_outline,
                        label: "Change Password",
                        value: "********",
                        onTap: () => Get.toNamed(Routes.UPDATE_PASSWORD),
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => logController.logout(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red[900],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        shadowColor: Colors.red[200],
                      ),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: AppFontSize.size4,
                          fontWeight: AppFontWeight.font3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }