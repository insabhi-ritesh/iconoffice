import 'package:get/get.dart';

import '../modules/feedback/bindings/feedback_binding.dart';
import '../modules/feedback/views/feedback_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/index/bindings/index_binding.dart';
import '../modules/index/views/index_view.dart';
import '../modules/login_page/bindings/login_page_binding.dart';
import '../modules/login_page/views/login_page_view.dart';
import '../modules/notify_page/bindings/notify_page_binding.dart';
import '../modules/notify_page/views/notify_page_view.dart';
import '../modules/pdf_sign/bindings/pdf_sign_binding.dart';
import '../modules/pdf_sign/views/pdf_sign_view.dart';
import '../modules/portal_ticket_form/bindings/portal_ticket_form_binding.dart';
import '../modules/portal_ticket_form/views/portal_ticket_form_view.dart';
import '../modules/portal_view/bindings/portal_view_binding.dart';
import '../modules/portal_view/views/portal_view_view.dart';
import '../modules/profile_page/bindings/profile_page_binding.dart';
import '../modules/profile_page/views/profile_page_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/ticket_detail_page/bindings/ticket_detail_page_binding.dart';
import '../modules/ticket_detail_page/views/ticket_detail_page_view.dart';
import '../modules/ticket_list_page/bindings/ticket_list_page_binding.dart';
import '../modules/ticket_list_page/views/ticket_list_page_view.dart';
import '../modules/update_password/bindings/update_password_binding.dart';
import '../modules/update_password/views/update_password_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_PAGE,
      page: () => const LoginPageView(),
      binding: LoginPageBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFY_PAGE,
      page: () => const NotifyPageView(),
      binding: NotifyPageBinding(),
    ),
    GetPage(
      name: _Paths.TICKET_LIST_PAGE,
      page: () => const TicketListPageView(),
      binding: TicketListPageBinding(),
    ),
    GetPage(
      name: _Paths.TICKET_DETAIL_PAGE,
      page: () => TicketDetailPageView(),
      binding: TicketDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_PAGE,
      page: () => const ProfilePageView(),
      binding: ProfilePageBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.INDEX,
      page: () => const IndexView(),
      binding: IndexBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_PASSWORD,
      page: () => const UpdatePasswordView(),
      binding: UpdatePasswordBinding(),
    ),
    GetPage(
      name: _Paths.PDF_SIGN,
      page: () => const PdfSignView(),
      binding: PdfSignBinding(),
    ),
    GetPage(
      name: _Paths.PORTAL_VIEW,
      page: () => const PortalViewView(),
      binding: PortalViewBinding(),
    ),
    GetPage(
      name: _Paths.PORTAL_TICKET_FORM,
      page: () => PortalTicketFormView(),
      binding: PortalTicketFormBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK,
      page: () => const FeedbackView(),
      binding: FeedbackBinding(),
    ),
  ];
}
