// import 'dart:async' show Timer;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform_file.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:insabhi_icon_office/app/models/messages_model.dart';
import 'package:insabhi_icon_office/app/models/ticket_detail_data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../../../Constants/constant.dart';
import '../../../common/app_color.dart';
import '../../../common/fontSize.dart';
import '../../../models/timesheet.dart';
import '../../../routes/app_pages.dart';
import '../../pdf_sign/views/pdf_viewer_page.dart';


class TicketDetailPageController extends GetxController with GetTickerProviderStateMixin{

  var timesheetInputs = <TimesheetInput>[].obs;
  var message = <HelpdeskMessage>[].obs;
  var searchQuery = ''.obs;
  var userQuery = ''.obs;
  var form = false.obs;
  final ScrollController messageScrollController = ScrollController();

  // Timer? _messagePollingTimer;

  // ... rest of your code

  // void startMessagePolling(int ticketId) {
  //   _messagePollingTimer?.cancel();
  //   _messagePollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
  //     GetMessagesFromTicket(ticketId);
  //   });
  // }


  void addNewTimesheet() {
    timesheetInputs.add(TimesheetInput(productId: '', date: DateTime.now()));
    form.value = true;
  }

  void removeTimesheet() {
    form.value = false;
    timesheetInputs.removeAt(0);
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
  var is_portal_user = true.obs;
  late String ticketNumber;
  var selectedState =''.obs;
  var selectedDate = Rxn<DateTime>(); 
  

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  @override
  void onInit() {

    is_portal_user.value = box.read('is_portal_user') ?? false;

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

      if (await file.exists()) {
        return filePath;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final dio = Dio();
      await dio.download(url, filePath);

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
          if (newState == 'closed'){
            Get.offAllNamed(Routes.HOME);
          } else {
            await GetTicketData(ticket_number);
          }
        } else {
          showPopUp();
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

  
  
  
  
  Future<void> submitTimesheets(String ticketId, DateTime? date, String State) async {
    var ticket_id = ticketId;
    var productId = productName.text;
    var time_description = productName.text;
    var hour = hours.text;
    var user = resUser.text;
    var enable = isEnabled.value;
    var dateStr = selectedDate.value?.toIso8601String();
    var id = productId;

    if (dateStr == null){
      selectedDate.value = DateTime.now();
      dateStr = selectedDate.value?.toIso8601String();
    }

    if (State == 'closed') {
      Get.snackbar('Error', 'Cannot able to create the timesheet for closed ticket');
      log("Ticket is closed $State");
      return;
    }
    try {
      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.CREATE_HELPDESK_TIME_SHEET}');
      final body = {
        'ticket': ticket_id,
        'product': productId,
        'descrip': time_description,
        'hours': hour,
        'date': dateStr,
        'user': user,
        'enable': enable,
        'id': id,
      };

      log("Create timesheet: $URL");
      log("Request body: $body");

      var res = await http.post(
        URL,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log(res.body);
      if (res.statusCode == 200) {
        await GetTicketData(ticketNumber);
        final data = jsonDecode(res.body);
        if (data['result']['success']) {
          Get.snackbar('Success', 'Timesheet submitted successfully');
          _clearTimesheetForm(); 
          removeTimesheet();
        } else {
          Get.snackbar('Error', data['message'] ?? 'Something went wrong');
        }
      } else {
        Get.snackbar('Error', 'Failed to submit timesheet');
        _clearTimesheetForm(); 
          removeTimesheet();
      }
    } catch (e) {
      log("This is the error : $e");
      Get.snackbar('Error', 'Failed to submit timesheet');
    }
  }

  void _clearTimesheetForm() {
    productName.clear();
    hours.clear();
    resUser.clear();
    selectedDate.value = null;
    isEnabled.value = false;
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
      log("This is the url to fetch the users data: $Url");
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
    is_portal_user.value = box.read('is_portal_user') ?? false;
    print(is_portal_user.value);

    try {

      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.GET_TICKET_DATA}?partner_id=$partnerId&ticket_number=$ticketNumber');
      log('Fetcht the ticket data: $URL');
      var response = await http.get(URL);

      // Uncomment this line to log the response body
      // log(response.body);

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        ticket_details.clear();
        if (res['data'] != null) {
          for (var element in res['data']) {
            var data = TicketDetail.fromJson(element);
            ticket_details.add(data);
          }
          await GetMessagesFromTicket(ticket_details[0].ticket_id);
          // Uncomment this function to get the messages from the ticket frequently.
          // startMessagePolling(ticket_details[0].ticket_id);
        } else {
          Get.snackbar("Error", "Failed to fetch orders");
        }
      }
    } catch  (e) {
      log("error message: $e");
    }
  }

  Future<void> GetMessagesFromTicket (int ticket_id) async {
    try {
      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.RECEIVE_MESSAGE}?ticket_id=$ticket_id');
      log('This is the Url to fetch the messages from the ticket helpdesk: $URL');
      var response = await http.get(URL);

      // Uncomment this line to log the response body
      // log(response.body);
      
      if (response.statusCode == 200){
        
        message.clear();
        var res = jsonDecode(response.body);
        if (res['data'] != null) {
          for (var element in res['data']) {
            var data = HelpdeskMessage.fromJson(element);
            message.add(data);
          }
        }
      }
    } catch (e){
      log("error message: $e");
      Get.snackbar("Update", 'No messages available');
    }
  }

  Future<void> sendMessage(int ticket_id, String text, {required List<PlatformFile> files}) async {
    var partnerId = box.read('partnerId');
    var author_name = box.read('name');
    try {
      var URL = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.SEND_MESSAGE}');

      var request = http.MultipartRequest('POST', URL);

      request.fields['ticket_id'] = ticket_id.toString();
      request.fields['partner_id'] = partnerId?.toString() ?? '';
      request.fields['name'] = author_name?.toString() ?? '';
      request.fields['message'] = text;

      for (var file in files) {
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'documents', 
              file.path!,
              filename: file.name,
            ),
          );
        }
      }

      log("Sending message with files to: $URL");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Uncomment this line to log the response body
      // log("Response status code: ${response.statusCode}");
      // log(response.body);

      if (response.statusCode == 200) {
        await GetMessagesFromTicket(ticket_id);
        await GetTicketData(ticketNumber);
      } else {
        Get.snackbar("Error", "Failed to send message: ${response.statusCode}");
      }
    } catch (e) {
      log("error message: $e");
      Get.snackbar("Error", "Failed to send message");
    }
  }

  Future<void> refreshData (String ticketNo) async{
    await GetTicketData(ticketNo);
  }

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  void scrollToBottom() {
    if (messageScrollController.hasClients) {
      messageScrollController.animateTo(
        messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    bounceController.dispose();
    super.onClose();
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
            const Text(
              'Error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.size2, fontWeight: AppFontWeight.font3,),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please fill the timesheet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSize.size3,
              fontWeight: AppFontWeight.font3),
              
            ),

            const SizedBox(height: 20),
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColorList.AppColor, size: AppFontSize.sizeLarge
            ),
            // ElevatedButton(onPressed: (){
            //     Get.back();
            //   }, child: 
            //     Text('Go Back',
            //       style: TextStyle(
            //         fontSize: AppFontSize.size3,
            //         fontWeight: AppFontWeight.font3,
            //         color: AppColorList.AppText
            //       ),
            //     )
            //   )
          ],
        ),
      ),
      barrierDismissible: false,
    );
    Future.delayed(const Duration(seconds: 5), () {
      Get.back();
    });
  }

  Future<void> previewFile(BuildContext context, PlatformFile file) async {
    final ext = file.extension?.toLowerCase();
    if (ext == 'pdf') {
      // For PDF, open with PdfViewerPage (local file)
      await Get.to(() => PdfViewerPage(
        url: file.path ?? '',
        name: file.name,
        isLocal: true,
      ));
    }
    else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'pdf'].contains(ext)) {
      // For images, show a dialog with Image.file
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Image.file(File(file.path!)),
          ),
        ),
      );
    } else {
      // For other files, just show the name and size
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Preview Not Available'),
          content: Text('File: ${file.name}\nSize: ${file.size} bytes'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
