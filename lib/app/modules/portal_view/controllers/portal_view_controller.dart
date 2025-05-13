import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../Constants/constant.dart';
import '../../../models/ticket_details.dart';

class PortalViewController extends GetxController {
  //TODO: Implement PortalViewController

  var isLoading = false.obs;
  final box = GetStorage();
  var isLogged = false.obs;
  var isLastPage = false.obs;
  // int currentPage = 1;
  // final int pageSize = 50;
  var tickets = <Ticket>[].obs;

  
  @override
  void onInit() {
    super.onInit();
    getPortalTicket();
  }

  Future<void> getPortalTicket() async {
    
    isLoading.value = true;
    // if (isRefresh) {
    //   currentPage = 1;
    //   isLastPage.value = false;
    //   tickets.clear();
    // } else {
    //   if (isLoading.value || isLastPage.value) return;

    // }

    var partnerId = box.read('partnerId');
    try {
      // tickets.clear();
      final url = Uri.parse(
        '${Constant.BASE_URL}${ApiEndPoints.GET_TICKET_DATA}?partner_id=$partnerId',
      );
      log("Ticket Data collecting url: $url");
      var response = await http.get(url);

      log(response.body);
      if (response.statusCode == 200) {
        tickets.clear();
        var res = jsonDecode(response.body);
        if (res['data'] != null) {
          List<Ticket> newTickets = [];
          for (var element in res['data']) {
            var data = Ticket.fromJson(element);
            newTickets.add(data);
          }
          // if (newTickets.length < pageSize) {
          //   isLastPage.value = true;
          // }
          tickets.addAll(newTickets);
          // currentPage++;
        } else {
          isLastPage.value = true;
          // if (isRefresh) {
          //   Get.snackbar("Error", "No tickets found");
          // }
        }
      } else {
        Get.snackbar("Error", "Failed to fetch tickets");
      }
    } catch (e) {
      log("error message: $e");
      Get.snackbar("Error", "Error fetching tickets");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {

    getPortalTicket();
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
