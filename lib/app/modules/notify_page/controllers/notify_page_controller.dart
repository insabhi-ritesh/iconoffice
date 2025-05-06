import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import '../../../models/notification.dart';


class NotifyPageController extends GetxController {
  var notifications = <NotificationItem>[].obs;
  var isLoading = true.obs;
  final box = GetStorage();

  Timer? _autoRefreshTimer;


  void loadNotifications() async {
    final dataFuture = fetchNotifications(); // Your API/data fetch
    final delayFuture = Future.delayed(const Duration(seconds: 3));

    await Future.wait([dataFuture, delayFuture]);
    isLoading.value = false;
  }

  Future<void> fetchNotifications() async {

    var partnerId =box.read('partnerId');
    isLoading.value = true;

    try {
      final url = Uri.parse('${Constant.BASE_URL}${ApiEndPoints.GET_NOTIFICATION}?partner_id=$partnerId');
      log("Fetching notifications from: $url");

      final response = await http.get(url);
      log("Response: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res['success'] == true && res['data'] != null) {
          var notificationList = res['data'] as List;
          notifications.value = notificationList
              .map((item) => NotificationItem.fromJson(item))
              .toList();
        } else {
          Get.snackbar("No Data", res['error'] ?? "No notifications available.");
        }
      } else {
        Get.snackbar("Error", "Failed to fetch notifications. Code: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching notifications: $e");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Start auto-refreshing notifications every 10 minutes
  void startAutoFetchNotifications() {
    _autoRefreshTimer?.cancel(); // Cancel previous timer if any
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      log("Auto-refreshing notifications...");
      fetchNotifications();
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    startAutoFetchNotifications();
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshData() async {
    await fetchNotifications();
  }
}
