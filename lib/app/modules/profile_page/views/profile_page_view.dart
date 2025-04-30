import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:insabhi_icon_office/app/routes/app_pages.dart';
import '../controllers/profile_page_controller.dart';

class ProfilePageView extends GetView<ProfilePageController> {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final logController = Get.find<HomeController>();
    return Scaffold(            
      appBar: AppBar(
        backgroundColor: AppColorList.AppButtonColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColorList.AppButtonColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Text(
            'Personal Information',
            style: TextStyle(
              color: AppColorList.WhiteText,
            ),
          ),
        ),
        // centerTitle: true,
        // Uncomment actions if needed
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.notification_important_sharp, color: AppColorList.WhiteText),
        //     onPressed: () {
        //       Get.toNamed(Routes.NOTIFY_PAGE);
        //     },
        //   ),
        // ],
      ),

      body: Container(
        color: AppColorList.AppButtonColor,
        child: Obx(() {
          if (controller.user.isEmpty) {
            return const SafeArea(
              // child: Center(child: CircularProgressIndicator()),
              child: Text("Sorry, unable to retrieve the profile data.",),
            );
          }

          final resUser = controller.user.first;
          Uint8List? imageBytes;
          if (resUser.image.isNotEmpty) {
            try {
              imageBytes = base64Decode(resUser.image);
            } catch (_) {
              imageBytes = null;
            }
          }

          return SafeArea(
            child: Column(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(16.0),
                //   decoration: BoxDecoration(
                //     color: AppColorList.AppButtonColor,
                //     borderRadius: const BorderRadius.only(
                //       bottomLeft: Radius.circular(20),
                //       bottomRight: Radius.circular(20),
                //     ),
                //   ),
                //   child: Row(
                //     children: [
                //       IconButton(
                //         icon: const Icon(Icons.arrow_back, color: Colors.white),
                //         onPressed: () => Get.back(),
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         resUser.name,
                //         style: TextStyle(
                //           fontSize: AppFontSize.size1,
                //           fontWeight: AppFontWeight.font3,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                        ProfileField(
                          icon: Icons.lock_outline,
                          label: "Change Password",
                          value: "********",
                          onTap: () => Get.toNamed(Routes.UPDATE_PASSWORD),
                        ),
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
        }),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final Uint8List? imageBytes;

  const ProfileAvatar({super.key, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColorList.AppButtonColor.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageBytes != null
              ? MemoryImage(imageBytes!)
              : const AssetImage('assets/icon/profile.jpg') as ImageProvider,
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
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
          border: Border.all(color: AppColorList.AppButtonColor.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColorList.AppButtonColor, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppFontSize.size3,
                      fontWeight: AppFontWeight.font2,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: AppFontSize.size4,
                      fontWeight: AppFontWeight.font3,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, color: AppColorList.AppButtonColor, size: 18),
          ],
        ),
      ),
    );
  }
}
