import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import 'package:insabhi_icon_office/app/modules/home/controllers/home_controller.dart';
import 'package:insabhi_icon_office/app/modules/login_page/controllers/login_page_controller.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_page_controller.dart';

class ProfilePageView extends GetView<ProfilePageController> {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final logController = Get.find<HomeController>();
    return Obx(() {
      if (controller.user.isEmpty) {
        return const Center(child: CircularProgressIndicator());
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

      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppColorList.AppColor,
        ),
        backgroundColor: AppColorList.AppTextField,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProfileAvatar(imageBytes: imageBytes),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColorList.ContainerBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorList.ContainerShadow,
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: AppColorList.LogOutColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileField(label: "Username :", value: resUser.name),
                    const SizedBox(height: 10),
                    ProfileField(label: "Email :", value: resUser.email),
                    const SizedBox(height: 10),
                    ProfileField(label: "Phone :", value: resUser.phone),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                Get.toNamed(Routes.UPDATE_PASSWORD);
                },
                child: buildOptionCard(context, "Change Password"),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  logController.logout();
                },
                child: buildOptionCard(context, "LogOut")),
            ],
          ),
        ),
      );
    }
  );
}

Widget buildOptionCard(BuildContext context, String title) {
  return Container(
    padding: const EdgeInsets.all(10),
    height: 50,
    width: MediaQuery.of(context).size.width * 0.9,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: AppColorList.ContainerBackground,
      boxShadow: [
        BoxShadow(
          color: AppColorList.ContainerShadow,
          spreadRadius: 2,
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
        
      ],
       border: Border.all(
                  color: AppColorList.LogOutColor,
                  width: 1,
                ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppFontSize.size4,
            fontWeight: AppFontWeight.font3,
          ),
        ),
        const Icon(Icons.arrow_right_alt_outlined),
      ],
    ),
  );
}

}
class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: AppFontWeight.font3,
                fontSize: AppFontSize.size4,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, 
                color: AppColorList.LogOutColor
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppFontSize.size4,
                fontWeight: AppFontWeight.font3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class ProfileAvatar extends StatelessWidget {
  final Uint8List? imageBytes;

  const ProfileAvatar({super.key, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: AppColorList.LogOutColor),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        radius: 80,
        backgroundImage: imageBytes != null
            ? MemoryImage(imageBytes!)
            : const AssetImage('assets/icon/profile.jpg') as ImageProvider,
      ),
    );
  }
}