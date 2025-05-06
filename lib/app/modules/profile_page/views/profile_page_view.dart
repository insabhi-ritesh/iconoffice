
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:insabhi_icon_office/app/routes/app_pages.dart';
import 'package:shimmer/shimmer.dart';
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
          // padding: const EdgeInsets.all(16.0),
          // decoration: BoxDecoration(
          //   color: AppColorList.AppButtonColor,
          //   // borderRadius: const BorderRadius.only(
          //   //   bottomLeft: Radius.circular(20),
          //   //   bottomRight: Radius.circular(20),
          //   // ),
          // ),
          child: Text(
            'Personal Information',
              style: TextStyle(
                fontSize: AppFontSize.size1,
                fontWeight: AppFontWeight.font3,
                color: Colors.white,
              ),
          ),
        ),
      ),
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
    );
  }
}


class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  Widget _skeletonBox({double width = double.infinity, double height = 20, BorderRadius? borderRadius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // Skeleton for avatar
                  Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: _skeletonBox(width: 80, height: 16, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 20),
                  // Skeleton fields
                  const _ProfileFieldSkeleton(),
                  const _ProfileFieldSkeleton(),
                  const _ProfileFieldSkeleton(),
                  const _ProfileFieldSkeleton(),
                  const SizedBox(height: 30),
                  // Skeleton for button
                  Center(
                    child: _skeletonBox(width: 160, height: 40, borderRadius: BorderRadius.circular(25)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldSkeleton extends StatelessWidget {
  const _ProfileFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    height: 14,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 18,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
