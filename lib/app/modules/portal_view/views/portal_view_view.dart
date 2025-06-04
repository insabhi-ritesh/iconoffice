import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/portal_view_controller.dart';
import 'components/float_action_button.dart';
import 'components/portal_appbar.dart';
import 'components/portal_body.dart';

class PortalViewView extends GetView<PortalViewController> {
  const PortalViewView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortalViewController>(
      builder: (controller) {
      return Scaffold(
        appBar: portalAppBar(),
        body: portalBody(controller),
        floatingActionButton: floatActionButton(),
      );
      }
    );
  }  
}




