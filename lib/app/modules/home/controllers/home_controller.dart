import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:http/http.dart' as http;
import 'package:insabhi_icon_office/app/models/ticket_details.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final box = GetStorage();
  var tickets = <Ticket>[].obs; 

 

  Future<void> GetTicketData  () async {
    var partnerId =box.read('partnerId');

    try {

      final Url = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.GET_TICKET_DATA}?partner_id=$partnerId');
      log("Ticket Data collecting url: $Url");
      var response = await http.get(
        Url
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
            var data = Ticket.fromJson(element);
            tickets.add(data);
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
  void onInit() {
    super.onInit(); 
    GetTicketData();
  }

  Future<void> refreshData() async {
    await GetTicketData();
  } 

  Future<void> logout () async {
    await GetStorage().erase();
    Get.offAllNamed(Routes.LOGIN_PAGE);
  }
}
