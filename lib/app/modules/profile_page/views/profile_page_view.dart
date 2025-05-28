
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import '../controllers/profile_page_controller.dart';
import 'components/profileBody.dart';
import 'components/profile_app_bar.dart';
import 'components/skeleton.dart';

class ProfilePageView extends GetView<ProfilePageController> {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final logController = Get.find<ProfilePageController>();
    return Scaffold(
      appBar: profileAppBar(),
      body: Obx(() {
        if (controller.user.isEmpty) {
          // Show skeleton loader instead of error text
          return const ProfileSkeleton();
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
        return profileBody(imageBytes, resUser, logController, controller);
      }),
    );
  }
}



// ... (ProfileAvatar and ProfileField remain unchanged)
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
