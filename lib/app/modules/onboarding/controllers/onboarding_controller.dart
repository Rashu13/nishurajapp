import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  void skipToHome() {
    Get.offNamed(AppRoutes.HOME);
  }

  void navigateToHome() {
    Get.offNamed(AppRoutes.HOME);
  }
}
