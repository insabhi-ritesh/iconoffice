import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import '../../../models/notification.dart';


class NotifyPageController extends GetxController {
  var notifications = <NotificationItem>[].obs;
  var isLoading = true.obs;

  Timer? _autoRefreshTimer;

  Future<void> fetchNotifications() async {
    isLoading.value = true;

    try {
      final url = Uri.parse('${Constant.BASE_URL}/api/app/get-notifications');
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
    fetchNotifications();
    startAutoFetchNotifications();
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel(); // Clean up timer
    super.onClose();
  }

  Future<void> refreshData() async {
    await fetchNotifications();
  }
}
