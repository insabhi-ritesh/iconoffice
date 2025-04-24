import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  List<Map<String, dynamic>> tickets = [
    {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
     {'title': 'Ticket #1001', 'status': 'Open'},
    {'title': 'Ticket #1002', 'status': 'In Progress'},
    {'title': 'Ticket #1003', 'status': 'Closed'},
  ];

  

  @override
  void onInit() {
    super.onInit(); 
  }

  Future<void> logout () async {
    await GetStorage().erase();
    Get.offAllNamed(Routes.LOGIN_PAGE);
  }
}
