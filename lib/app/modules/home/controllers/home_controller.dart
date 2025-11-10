import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insabhi_icon_office/app/Constants/constant.dart';
import 'package:http/http.dart' as http;
import 'package:insabhi_icon_office/app/Constants/firebase_api.dart';
import 'package:insabhi_icon_office/app/models/ticket_details.dart';
import '../../../common/pagination.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final box = GetStorage();
  var tickets = <Ticket>[].obs;
  ScrollController scrollController = ScrollController();
  var originalTickets = <Ticket>[]; // Backup of all tickets
  var currentFilter = 'All'.obs; // Track the current filter

  // Pagination state
  int currentPage = 1;
  final int pageSize = 15; // Adjust as per your API
  var isLoading = false.obs;
  var isLastPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    PaginationController(
      scrollController: scrollController,
      onScrollEnd: onScrollEnd,
    );
    fetchTickets(isRefresh: true);
  }

  Future<void> fetchTickets({bool isRefresh = false}) async {
    isLoading.value = true;
    if (isRefresh) {
      currentPage = 1;
      isLastPage.value = false;
      tickets.clear();
      if (currentFilter.value == 'All') {
        originalTickets.clear();
      }
    }

    var partnerId = box.read('partnerId');
    try {
      final statusParam = currentFilter.value != 'All'
          ? statusMap[currentFilter.value] ?? ''
          : '';
      final url = Uri.parse(
        '${Constant.BASE_URL}${ApiEndPoints.GET_TICKET_DATA}?partner_id=$partnerId&page=$currentPage&limit=$pageSize${statusParam.isNotEmpty ? "&status=$statusParam" : ""}',
      );
      log("Ticket Data collecting url: $url");
      var response = await http.get(url);

      log(response.body);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['data'] != null) {
          List<Ticket> newTickets = [];
          for (var element in res['data']) {
            var data = Ticket.fromJson(element);
            newTickets.add(data);
          }
          if (newTickets.length < pageSize) {
            isLastPage.value = true;
          }
          if (isRefresh) {
            tickets.value = newTickets;
            if (currentFilter.value == 'All') {
              originalTickets.addAll(newTickets);
            }
          } else {
            tickets.addAll(newTickets);
          }
          currentPage++;
        } else {
          isLastPage.value = true;
          if (isRefresh) {
            Get.snackbar("Error", "No tickets found for ${currentFilter.value}");
          }
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

  void searchTickets(String query) {
    if (query.isEmpty) {
      filterTicketsByStatus(currentFilter.value);
      return;
    }
    final filteredTickets = originalTickets.where((ticket) {
      final ticketNoLower = ticket.ticketNo.toLowerCase();
      final customerNameLower = ticket.tpartnerName.toLowerCase();
      final queryLower = query.toLowerCase();

      final matchesTicketNo = ticketNoLower.contains(queryLower);
      final matchesCustomerName = customerNameLower.contains(queryLower);

      final matchesQuery = matchesTicketNo || matchesCustomerName;
      final matchesStatus = currentFilter.value == 'All' || ticket.state == statusMap[currentFilter.value];
      return matchesQuery && matchesStatus;
    }).toList();
    tickets.assignAll(filteredTickets);
  }

  final statusMap = {
    'New': 'new',
    'Assigned': 'assigned',
    'Work in Progress': 'work_in',
  };

  void filterTicketsByStatus(String label) {
    currentFilter.value = label;
    tickets.clear();
    isLastPage.value = false;
    currentPage = 1;
    fetchTickets(isRefresh: true);
  }

  Future<void> refreshData() async {
    fetchTickets(isRefresh: true,);
  }

  void onScrollEnd() {
    if (!isLastPage.value && !isLoading.value) {
      fetchTickets();
    }
  }

  Future<void> logout() async {
    await GetStorage().erase();
    Get.offAllNamed(Routes.LOGIN_PAGE);
    await FirebaseApi().startNotification();
  }
}
