
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../routes/app_pages.dart';

class Constant {
  static OdooClient? odooRpc;
  //-----------Live Url------//
  static String BASE_URL = 'http://192.168.0.113:8070';

  static String odooUrl = BASE_URL;
}

class ApiEndPoints {
  static String LOGIN_API = '/api/app/login';
  static String USER_PROFILE_API = '/api/app/profile';
  static String RESET_PASSWORD = '/api/app/reset_password';
  static String UPDATE_PASSWORD = '/mobile/update/password';
}

void signOut({String? message}) async {
  await GetStorage().erase();

  Get.offAllNamed(Routes.LOGIN_PAGE, arguments: {'message': message});
}
