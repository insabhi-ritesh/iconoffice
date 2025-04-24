import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IndexController extends GetxController {
  late TabController tapController;
  var time = DateTime.now();
  var currentIndex = 0.obs;

  PageController pageController = PageController();
  // var currentIndex = 0.obs;
  //TODO: Implement IndexController

  // final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
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
