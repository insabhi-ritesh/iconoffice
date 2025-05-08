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
import '../../../models/timesheet.dart';
import '../../../routes/app_pages.dart';

class TicketDetailPageController extends GetxController with GetTickerProviderStateMixin{
  //TODO: Implement TicketDetailPageController

  var timesheetInputs = <TimesheetInput>[].obs;
  var searchQuery = ''.obs;
  var userQuery = ''.obs;
  var form = false.obs;

  void addNewTimesheet() {
    timesheetInputs.add(TimesheetInput(productId: '', date: DateTime.now()));
    form.value = true;
  }

  void removeTimesheet(int index) {
    form.value = false;
    timesheetInputs.removeAt(index);
  }

  late AnimationController bounceController;
  late Animation<Offset> bounceAnimation;

  final box = GetStorage();
  var ticket_details = <TicketDetail>[].obs; 
  var product_list = <GetProduct>[].obs;
  var user_list = <UsersList>[].obs;


  var description= TextEditingController();
  var hours = TextEditingController();
  var datetime = TextEditingController();
  var Password = TextEditingController();
  var productName = TextEditingController();
  var resolution = TextEditingController();
  var resUser = TextEditingController();
  var productId = 0.obs;
  var isEnabled = false.obs;

  late String ticketNumber;
  var selectedState =''.obs;
  var selectedDate = Rxn<DateTime>(); // Nullable Rx<DateTime>

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  @override
  void onInit() {
     bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    bounceAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(
      parent: bounceController,
      curve: Curves.easeInOut,
    ));

    ticketNumber = Get.arguments as String;

    super.onInit();
    debounce(searchQuery, (_) => getProductData(searchQuery.value), time: Duration(milliseconds: 500));
    debounce(userQuery, (_) => getUserName(userQuery.value), time: Duration(milliseconds: 500));

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

  Future<void> updateTicketState(String ticket_number, String newState) async {
    try {
      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.UPDATE_STATE}?ticket_no=$ticket_number&new_state=$newState');
      log('Update the ticket state: $URL');
      final response = await http.post(URL);
      log(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          selectedState.value = newState;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Something went wrong');
        }
      } else {
        Get.snackbar('Error', 'Failed to update ticket state');
      }
    }
    catch (e){
      Get.snackbar('Error', 'Failed to update ticket state');
    }
  }

  
  
  
  Future<void> submitTimesheets(String ticketId, DateTime? date) async {
    var ticket_id = ticketId;
    var productId = productName.text;
    var time_description = productName.text;
    var hour = hours.text;
    var user = resUser.text;
    var enable = isEnabled.value;
    var date = selectedDate.value?.toIso8601String(); 
    var id = productId;
    try {
      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.CREATE_HELPDESK_TIME_SHEET}?ticket=$ticket_id&product=$productId&descrip=$time_description&hours=$hour&date=$date&user=$user&enable=$enable&id=$id');
      log("Create timesheet: $URL");

      var res = await http.post(
        URL
      );

      log(res.body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success']) {
          Get.snackbar('Success', 'Timesheet submitted successfully');
          await GetTicketData(ticketNumber);
        } else {
          Get.snackbar('Error', data['message'] ?? 'Something went wrong');
        }
      } else {
        Get.snackbar('Error', 'Failed to submit timesheet');
      }
    } catch (e) {
      log("This is the error : $e");
      Get.snackbar('Error', 'Failed to submit timesheet');
    }
  }



  Future<void> getProductData (String search_product) async{
    if(product_list.isNotEmpty){
      product_list.clear();
    }
    try {
      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.GET_SEARCH_PRODUCT}?query=$search_product');
      log("Fetch product data: $URL");
      var response = await http.get(URL);
      log(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          if (data['results'] != null) {
            for (var pro in data['results']) {
              var data = GetProduct.fromJson(pro);
              product_list.add(data);
          }
        } else {
          Get.snackbar('Error', data['message'] ?? 'Something went wrong');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch product data');
      }
    } 
    }catch (e){
      Get.snackbar('Error', 'Failed to get product data');
    }
  }

  Future<void> getUserName( String query) async {
    
    try {
      var Url = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.SEARCH_USER}?query=$query');
      log("This is the url to fetch the users data");
      var response = await http.get(Url);

      log(response.body);
      if (response.statusCode == 200) {
        user_list.clear();
        final data = jsonDecode(response.body);
        if (data['success']) {
          if (data['results'] != null) {
            for (var user in data['results']) {
              var data = UsersList.fromJson(user);
              user_list.add(data);
            }
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch user data');
      }
    } catch (e) {
      log("This is the error : $e");
    }



  }

  Future<void> GetTicketData  (String ticketNo) async {
    var partnerId =box.read('partnerId');

    try {

      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.GET_TICKET_DATA}?partner_id=$partnerId&ticket_number=$ticketNumber');
      log('Fetcht the ticket data: $URL');
      var response = await http.get(URL);

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
  void onClose() {
    bounceController.dispose();
    super.onClose();
  }
}
