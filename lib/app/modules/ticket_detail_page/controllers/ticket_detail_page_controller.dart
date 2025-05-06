import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/models/ticket_detail_data.dart';
import 'package:path_provider/path_provider.dart';

import '../../../Constants/constant.dart';
import '../../../models/ticket_details.dart';

class TicketDetailPageController extends GetxController {
  //TODO: Implement TicketDetailPageController

  final box = GetStorage();
  var ticket_details = <TicketDetail>[].obs; 

  late String ticketNumber;

  @override
  void onInit() {
    ticketNumber = Get.arguments as String;

    super.onInit();
    GetTicketData(ticketNumber);
  }

  Future<String?> downloadPdf(String url, String fileName, BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      // If file already exists, return path
      if (await file.exists()) {
        return filePath;
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Download file
      final dio = Dio();
      await dio.download(url, filePath);

      // Hide progress dialog
      Navigator.of(context, rootNavigator: true).pop();

      return filePath;
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      Get.snackbar('Download Failed', 'Could not download PDF: $e');
      return null;
    }
  }

 

  Future<void> GetTicketData  (String ticketNo) async {
    var partnerId =box.read('partnerId');

    try {
      var response = await http.get(
        Uri.parse('${Constant.BASE_URL}${ApiEndPoints.GET_TICKET_DATA}?partner_id=$partnerId&ticket_number=$ticketNumber'),
        // body: {
        //   'partner_id': partnerId.toString()
        // },
      );

      log(response.body);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        // log(res);
        if (res['data'] != null) {
          for (var element in res['data']) {
            var data = TicketDetail.fromJson(element);
            ticket_details.add(data);
          }
        } else {
          Get.snackbar("Error", "Failed to fetch orders");
        }
      }
    } catch  (e) {
      log("error message: $e");
      print("Error fetching user profile data.");
    }
  }
}
