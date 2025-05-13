
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:insabhi_icon_office/app/common/app_color.dart';
import 'package:insabhi_icon_office/app/common/fontSize.dart';
import 'package:insabhi_icon_office/app/modules/portal_view/controllers/portal_view_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../routes/app_pages.dart';

class PortalTicketFormController extends GetxController {
  // Controllers for each field
  final userEmailController = TextEditingController();
  final ticketTitleController = TextEditingController();
  final createdByController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerReferenceController = TextEditingController();
  final serialNoController = TextEditingController();
  final modelNoController = TextEditingController();
  final faultAreaController = TextEditingController();
  final descriptionController = TextEditingController();

  final box = GetStorage();

  // Selected files (documents)
  final selectedFiles = <PlatformFile>[].obs;

  // Set selected files
  void setSelectedFiles(List<PlatformFile> files) {
    selectedFiles.assignAll(files);
  }

  // Remove a selected file
  void removeSelectedFile(PlatformFile file) {
    selectedFiles.remove(file);
  }

  // Dropdown
  var selectedOption = RxnString();

  final dropdownOptions = [
    'ACT',
    'NSW',
    'NT',
    'QLD',
    'SA',
    'TAS',
    'VIC',
    'WA',
  ];

  Future<void> CreateTicket() async {
    var partnerId = box.read('partnerId');

    try {
      var URL = Uri.parse('${Constant.BASE_URL}/api/app/helpdesk/ticket/create');
      log('Posting ticket data: $URL');

      var request = http.MultipartRequest('POST', URL);

      // Add form fields
      request.fields['partner_id'] = partnerId?.toString() ?? '';
      request.fields['user_email'] = userEmailController.text;
      request.fields['ticket_title'] = ticketTitleController.text;
      request.fields['created_by'] = createdByController.text;
      request.fields['customer_name'] = customerNameController.text;
      request.fields['customer_reference'] = customerReferenceController.text;
      request.fields['serial_no'] = serialNoController.text;
      request.fields['model_no'] = modelNoController.text;
      request.fields['fault_area'] = faultAreaController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['state'] = selectedOption.value ?? '';

      // Add files
      for (var file in selectedFiles) {
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'documents', // field name for backend
              file.path!,
              filename: file.name,
            ),
          );
        }
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log(response.body);

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        log("Created ticket data: $resData");
        if (resData['success'] == true) {
          Get.snackbar('Success', 'Ticket created successfully');
          showPopUp();
          _clearForm();
          // Get.find<PortalViewController>().getPortalTicket();
          // Get.back();
        } else {
          Get.snackbar('Error', resData['message'] ?? 'Failed to create ticket');
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      log("Error while creating the ticket:$e");
      Get.snackbar('Error', 'Failed to connect to the Server');
    }
  }

  @override
  void onInit() {
    super.onInit();
    final email = box.read('email');
    final name = box.read('name');
    if (email != null) {
      userEmailController.text = email;
    }
    if (name != null){
      createdByController.text = name;
    }

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // Dispose controllers
    userEmailController.dispose();
    ticketTitleController.dispose();
    createdByController.dispose();
    customerNameController.dispose();
    customerReferenceController.dispose();
    serialNoController.dispose();
    modelNoController.dispose();
    faultAreaController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _clearForm() {
    userEmailController.clear();
    ticketTitleController.clear();
    createdByController.clear();
    customerNameController.clear();
    customerReferenceController.clear();
    serialNoController.clear();
    modelNoController.clear();
    faultAreaController.clear();
    descriptionController.clear();
    selectedOption.value = null;
    selectedFiles.clear();
  }

  void showPopUp() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image at the top
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/icons/Group.svg', 
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            // Title and message
            const Text(
              'Ticket created successfully',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.size2, fontWeight: AppFontWeight.font3,),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please wait...\nYou will be directed to the homepage',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.size3,
              fontWeight: AppFontWeight.font3),
              
            ),

            const SizedBox(height: 20),

            // Loader at the bottom
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColorList.AppColor, size: AppFontSize.sizeLarge
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.offAllNamed(Routes.PORTAL_VIEW);
    });
  }
}
