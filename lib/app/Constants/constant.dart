
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../routes/app_pages.dart';

class Constant {
  static OdooClient? odooRpc;
  //-----------Live Url------//
  static String BASE_URL = 'http://45.124.52.122:8069';
  // static String BASE_URL = 'http://192.168.0.110:8017';

  static String odooUrl = BASE_URL;
}

class ApiEndPoints {
  static String LOGIN_API = '/api/app/login';
  static String USER_PROFILE_API = '/api/app/profile';
  static String RESET_PASSWORD = '/api/app/reset_password';
  static String UPDATE_PASSWORD = '/mobile/update/password';
  static String GET_TICKET_DATA = '/api/app/helpdesk/tickets';
}

void signOut({String? message}) async {
  await GetStorage().erase();

  Get.offAllNamed(Routes.LOGIN_PAGE, arguments: {'message': message});
}
