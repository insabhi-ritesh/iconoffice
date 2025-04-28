import 'dart:convert';
import 'dart:developer';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/models/ticket_detail_data.dart';

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

 

  Future<void> GetTicketData  (String ticket_no) async {
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

  

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
