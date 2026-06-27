import '../modules/auth/views/login_view.dart';
import 'package:get/get.dart';
import 'package:serv/app/modules/table_management/views/table_management_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/table_management/bindings/table_management_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/menu/views/menu_detail_view.dart';
import '../modules/order/views/order_view.dart';
import '../modules/order/views/order_track_view.dart';
import '../modules/order_status/views/order_status_view.dart';
import '../modules/order_status/bindings/order_status_binding.dart';
import '../modules/billing/views/billing_view.dart' as billing;
import '../modules/billing/bindings/billing_binding.dart';
import '../modules/customization/views/customization_view.dart';
import '../modules/customization/bindings/customization_binding.dart';
import '../modules/order_summary/views/order_summary_view.dart';
import '../modules/order_summary/bindings/order_summary_binding.dart';
import '../modules/bill_generation/views/bill_generation_view.dart';
import '../modules/bill_generation/bindings/bill_generation_binding.dart';
import '../modules/bill_detail/views/bill_detail_view.dart';
import '../modules/bill_detail/bindings/bill_detail_binding.dart';
import '../modules/payment_method/views/payment_method_view.dart';
import '../modules/payment_method/bindings/payment_method_binding.dart';
import '../modules/payment_successful/views/payment_successful_view.dart';
import '../modules/payment_successful/bindings/payment_successful_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/controllers/settings_controller.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.TABLE_MANAGEMENT,
      page: () => const TableManagementView(),
      binding: TableManagementBinding(),
    ),
    GetPage(
      name: AppRoutes.MENU,
      page: () => const MenuView(),
    ),
    GetPage(
      name: AppRoutes.MENU_DETAIL,
      page: () => const MenuDetailView(),
    ),
    GetPage(
      name: AppRoutes.ORDER,
      page: () => const OrderView(),
    ),
    GetPage(
      name: AppRoutes.ORDER_TRACK,
      page: () => const OrderTrackView(),
    ),
    GetPage(
      name: AppRoutes.BILLING,
      page: () => const billing.BillingView(),
      binding: BillingBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDER_STATUS,
      page: () => const OrderStatusView(),
      binding: OrderStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMIZATION,
      page: () => const CustomizationView(),
      binding: CustomizationBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDER_SUMMARY,
      page: () => const OrderSummaryView(),
      binding: OrderSummaryBinding(),
    ),
    GetPage(
      name: AppRoutes.BILL_GENERATION,
      page: () => const BillGenerationView(),
      binding: BillGenerationBinding(),
    ),
    GetPage(
      name: AppRoutes.BILL_DETAIL,
      page: () => const BillDetailView(),
      binding: BillDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.PAYMENT_METHOD,
      page: () => const PaymentMethodView(),
      binding: PaymentMethodBinding(),
    ),
    GetPage(
      name: AppRoutes.PAYMENT_SUCCESSFUL,
      page: () => const PaymentSuccessfulView(),
      binding: PaymentSuccessfulBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
  ];
}
