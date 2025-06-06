
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../routes/app_pages.dart';

class Constant {
  static OdooClient? odooRpc;
  
  //-----------Live Url------//
  static String BASE_URL = 'http://45.124.52.122:8069';
  // static String BASE_URL = 'https://iconofficesolutions.com.au/';
  // static String BASE_URL = 'http://192.168.0.111:8017';
  // static String BASE_URL = 'http://192.168.0.167:7099';

  static String odooUrl = BASE_URL;
}

class ApiEndPoints {
  static const String LOGIN_API = '/api/app/login';
  static const String USER_PROFILE_API = '/api/app/profile';
  static const String RESET_PASSWORD = '/api/app/reset_password';
  static const String UPDATE_PASSWORD = '/mobile/update/password';
  static const String GET_TICKET_DATA = '/api/app/helpdesk/tickets';
  static const String SAVE_TOKEN = '/api/save/device/token';
  static const String UPLOAD_PDF = '/api/app/helpdesk/upload_signed_pdf';
  static const String GET_NOTIFICATION = '/api/app/get-notifications';
  static const String GET_SEARCH_PRODUCT = '/api/app/helpdesk/search_product';
  static const String UPDATE_STATE = '/api/app/helpdesk/update_state';
  static const String SEARCH_USER = '/api/app/helpdesk/search_user';
  static const String CREATE_HELPDESK_TIME_SHEET = '/api/app/helpdesk/timesheet';
  static const String SEND_MESSAGE = '/app/api/helpdesk/send_message';
  static const String RECEIVE_MESSAGE = '/app/api/helpdesk/receive_message';
  static const String CREATE_HELPDESK_TICKET = '/api/app/helpdesk/ticket/create';
}

void signOut({String? message}) async {
  await GetStorage().erase();

  Get.offAllNamed(Routes.LOGIN_PAGE, arguments: {'message': message});
}
